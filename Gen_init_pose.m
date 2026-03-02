function [s_ct0_all, r_tc0_all, w_ti0_all, image_all] = Gen_init_pose(N)    
    rng('shuffle');
    radius = -20; % radius in T-body frame
    w_max = 1.5; % maximum of angular velocity component
    alpha_max = pi/3; % maximum alpha for the spherical cap
    cos_alpha_max = cos(alpha_max);
    
    theta_max = pi/3; % max tilt angle for guided sampling, 
    % adjust based on acceptance rate (e.g., pi/6 ~30 deg)
    cos_theta_min = cos(theta_max);
    
    % Pre-allocate arrays
    s_ct0_all = zeros(3, N);
    r_tc0_all = zeros(3, N);
    w_ti0_all = zeros(3, N);
    image_all = zeros(8, N);
    
    parfor i = 1:N
        % Uniform sampling on the spherical cap
        u = rand() * (1 - cos_alpha_max);
        alpha = acos(1 - u);
        beta = 2 * pi * rand();
        
        % Chaser's position in Target-body frame
        r_tc0 = [radius * sin(alpha) * cos(beta);
                 radius * sin(alpha) * sin(beta);
                 radius * cos(alpha)];

        % Target's angular velocity in T-body frame
        w_ti0 = deg2rad(2 * w_max * rand(3, 1) - w_max);
        
        flag = 0;
        while (~flag)
            % NEW: Guided sampling for s_ct0
            norm_r = norm(r_tc0);
            d_t = -r_tc0 / norm_r; % Direction from chaser to target in T frame
            z = [0; 0; 1];
            
            % Compute align_R: map d_t to z
            [align_R] = vec2dcm(d_t, z);
            
            % Random roll around z
            phi = 2 * pi * rand();
            roll_rot = [cos(phi), -sin(phi), 0;
                        sin(phi), cos(phi), 0;
                        0, 0, 1];
            R_nom = roll_rot * align_R;
            
            % Random tilt: uniform on spherical cap
            u_tilt = cos_theta_min + (1 - cos_theta_min) * rand();
            theta = acos(u_tilt);
            psi = 2 * pi * rand();
            axis_tilt = [cos(psi); sin(psi); 0];
            tilt_rot = angleaxis2dcm(axis_tilt, theta);
            
            % Final R_ct
            R_ct = tilt_rot * R_nom;
            
            % Convert R_ct to MRP s_ct0
            s_ct0 = dcm2mrp(R_ct);
            
            % Clip if exceeds s_max (optional, if needed)
            % s_ct0 = max(min(s_ct0, s_max), -s_max);
            
            % Calculate initial parameters
            param = Gen_init_image_pos(s_ct0, r_tc0);
            
            % Calculate angle between Z-axes
            z_axis = [0; 0; 1];
            angleZ = dot(param.R_ti0' * z_axis, param.R_ci0' * z_axis);
            
            % Check conditions
            if all(param.s0([1, 3, 5, 7]) < param.um) ...
            && all(param.s0([1, 3, 5, 7]) > -param.um) ...
            && all(param.s0([2, 4, 6, 8]) < param.nm) ...
            && all(param.s0([2, 4, 6, 8]) > -param.nm) ...
            && angleZ > 0
                flag = 1;
            else
                flag = 0;
            end
        end
        
        % Store the valid set
        s_ct0_all(:, i) = s_ct0;
        r_tc0_all(:, i) = r_tc0;
        w_ti0_all(:, i) = w_ti0;
        image_all(:, i) = param.s0;
    end
end

% Helper function: skew symmetric matrix
function S = skew(v)
    S = [0, -v(3), v(2);
         v(3), 0, -v(1);
         -v(2), v(1), 0];
end

% Helper function: rotation matrix from axis-angle
function R = angleaxis2dcm(axis, angle)
    if norm(axis) == 0
        R = eye(3);
        return;
    end
    u = axis / norm(axis);
    K = skew(u);
    R = eye(3) + sin(angle) * K + (1 - cos(angle)) * K * K;
end

% Helper function: DCM that maps vec1 to vec2 (minimal rotation)
function R = vec2dcm(vec1, vec2)
    v1 = vec1 / norm(vec1);
    v2 = vec2 / norm(vec2);
    cross_prod = cross(v1, v2);
    s = norm(cross_prod);
    c = dot(v1, v2);
    
    if s < 1e-10
        if c > 0
            R = eye(3);
        else
            % Opposite vectors: arbitrary 180 deg rotation
            R = [-1, 0, 0; 0, -1, 0; 0, 0, 1]; % Example, can adjust
        end
        return;
    end
    
    u = cross_prod / s;
    K = skew(u);
    R = eye(3) + s * K + (1 - c) * K * K;
end

% Helper function: convert DCM to MRP
function s = dcm2mrp(R)
    trace = R(1,1) + R(2,2) + R(3,3);
    theta = acos((trace - 1)/2);
    
    if abs(theta) < 1e-10
        s = zeros(3,1);
        return;
    end
    
    sin_theta = sin(theta);
    if abs(sin_theta) < 1e-10
        s = zeros(3,1); % Handle singularity
        return;
    end
    
    u = [R(3,2) - R(2,3); R(1,3) - R(3,1); R(2,1) - R(1,2)] / (2 * sin_theta);
    s = tan(theta/4) * u;
end