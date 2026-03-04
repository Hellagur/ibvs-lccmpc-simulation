%% PLOT MONTE CARLO INITIAL POSE
function Plot_monte_carlo_init_pose(s_ct0_all, r_tc0_all, N)
% Plot Monte Carlo initial poses in target body frame
%
% This function visualizes the distribution of initial relative poses from
% Monte Carlo simulations in 3D space.
%
% Inputs:
%   s_ct0_all - MRP orientation of chaser relative to target (3×N)
%   r_tc0_all - position of chaser in target frame (3×N)
%   N         - number of samples
%
% Outputs:
%   None (displays figure)

    x = [1;0;0];
    y = [0;1;0];
    z = [0;0;1];

    fig = figure('Units','inches', ...
                 'Position',[1 1 8 6], ...
                 'PaperOrientation', 'landscape');
    view(3); hold on;

    colorX_c = [231 76  60]/255;
    colorY_c = [46 204 113]/255;
    colorZ_c = [52 152 219]/255;
    colorX_t = [255 0 0]/255;
    colorY_t = [0 255 0]/255;
    colorZ_t = [0 0 255]/255;

    plot3(0, 0, 0, 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'MarkerSize', 5);
    
    start = zeros(1,3);
    Plot_arrow3D(start, start + 5 * x', colorX_t, 1, 0.2, 0.6);
    Plot_arrow3D(start, start + 5 * y', colorY_t, 1, 0.2, 0.6);
    Plot_arrow3D(start, start + 5 * z', colorZ_t, 1, 0.2, 0.6);
    plot3(0,0,0,'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'MarkerSize', 5);

    for i = 1:N
        s_ct0 = s_ct0_all(:,i);
        r_tc0 = r_tc0_all(:,i);
        plot3(r_tc0(1), r_tc0(2), r_tc0(3), 'o', ...
            'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'MarkerSize', 3);
    
        R_ct0 = mrp2dcm(s_ct0);
        x_tc = R_ct0' * x; 
        y_tc = R_ct0' * y;
        z_tc = R_ct0' * z;
    
        start = r_tc0';
        Plot_arrow3D(start, start + 3 * x_tc', colorX_c, 0.5, 0.1, 0.5);
        Plot_arrow3D(start, start + 3 * y_tc', colorY_c, 0.5, 0.1, 0.5);
        Plot_arrow3D(start, start + 3 * z_tc', colorZ_c, 0.5, 0.1, 0.5);
    end

    sphereColor = [199 212 226]/255;
    f = @(x,y,z,r) x.^2 + y.^2 + z.^2 - r^2;
    hSphere = fimplicit3(@(x,y,z) f(x,y,z,5), [-5 5 -5 5 -5 5]);
    hSphere.FaceColor = sphereColor;
    hSphere.FaceAlpha = 0.15;
    hSphere.EdgeColor = 'none';

    R0 = 20;
    n  = [0; 0; -1];
    n  = n / norm(n);
    d  = 9;
    
    [theta, phi] = meshgrid(linspace(0, pi, 120), linspace(0, 2*pi, 240));
    x = R0 * sin(theta) .* cos(phi);
    y = R0 * sin(theta) .* sin(phi);
    z = R0 * cos(theta);
    
    mask = (n(1)*x + n(2)*y + n(3)*z) >= d;
    x(~mask) = nan;
    y(~mask) = nan;
    z(~mask) = nan;
    
    coneColor = [255 204 153]/255;
    hInitSphere = surf(x, y, z);
    hInitSphere.FaceColor = coneColor;
    hInitSphere.FaceAlpha = 0.15;
    hInitSphere.EdgeColor = 'none';

    grid on; axis equal;
    xlabel('$x_T\ (m)$', 'FontSize', 12, 'FontName', 'Times New Roman', 'Interpreter', 'latex');
    ylabel('$y_T\ (m)$', 'FontSize', 12, 'FontName', 'Times New Roman', 'Interpreter', 'latex');
    zlabel('$z_T\ (m)$', 'FontSize', 12, 'FontName', 'Times New Roman', 'Interpreter', 'latex');

    hxt = plot3(NaN,NaN,NaN, 'Color', colorX_t, 'LineWidth', 2, 'DisplayName', '$\hat{x}_T$');
    hyt = plot3(NaN,NaN,NaN, 'Color', colorY_t, 'LineWidth', 2, 'DisplayName', '$\hat{y}_T$');
    hzt = plot3(NaN,NaN,NaN, 'Color', colorZ_t, 'LineWidth', 2, 'DisplayName', '$\hat{z}_T$');
    hxc = plot3(NaN,NaN,NaN, 'Color', colorX_c, 'LineWidth', 2, 'DisplayName', '$\hat{x}_C$');
    hyc = plot3(NaN,NaN,NaN, 'Color', colorY_c, 'LineWidth', 2, 'DisplayName', '$\hat{y}_C$');
    hzc = plot3(NaN,NaN,NaN, 'Color', colorZ_c, 'LineWidth', 2, 'DisplayName', '$\hat{z}_C$');    
    
    legend([hxt, hyt, hzt, hxc, hyc, hzc], ...
        'Interpreter', 'latex', 'FontSize', 10, 'Location', 'northeast', 'Box', 'on');

    set(gca, 'FontSize', 12, 'FontName', 'Times New Roman');
end
