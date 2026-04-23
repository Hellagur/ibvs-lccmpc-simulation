function param = Gen_init_image_pos(s_ct0, r_tc0)
    % Define orbital constants and reference orbital elements
    param.mu    = 398600.4418e9;                % Earth's gravitational parameter [m^3/s^2]
    param.Re    = 6371e3;                       % Earth's mean radius [m]
    param.a     = param.Re + 685e3;             % Target orbit semi-major axis [m]
    param.e     = 0.00155;                      % Eccentricity
    param.i     = deg2rad(60);                  % Inclination [rad]
    param.O     = deg2rad(30);                  % Right ascension of ascending node [rad]
    param.o     = 0;                            % Argument of perigee [rad]
    param.f     = 0;                            % True anomaly [rad]

    param.xi    = [0.5; 0.4;-1;
                0.5;-0.4;-1;
                -0.5;-0.4;-1;
                -0.5; 0.4;-1];                  % Feature point coordinates in {T} [m]

    % Camera installation matrix, from {S} frame to {C} frame
    param.R_cs  = angle2dcm(pi/2, pi/2, 0, 'ZXY');
    param.R_sc  = param.R_cs';
    param.r_sc  = [0.3;0.0;0.0];                % camera's location in {S} frame

    param.fl    = 20e-3/(10e-6);                % Focal length in pixel units [px]
    param.f0    = 20e-3/(10e-6);                % Nominal focal length [px]
    param.u0    = 0;                            % Principal point [px]
    param.n0    = 0;
    param.um    = 640;                          % Image half dimensions [px]
    param.nm    = 512;
    param.Kf    = [param.f0, 0, param.u0; 0, param.f0, param.n0];

    % Feature-related and attitude helper functions
    % r(R_cl,R_ct,r_l,xi_i) r_i = -R_cl * r_l - R_cs * r_sc + R_ct * xi_i
    param.rfun  = @(R_cl,R_ct,r_l,xi_i) - R_cl*r_l - param.R_cs*param.r_sc + R_ct*xi_i;

    s_ti0       = [0;0;0];                      % Target's initial MRPs
    
    % Target's position and velocity in {I}
    [r_t0,v_t0] = rv_OE2ECI(param.mu, param.a, param.e, param.i, param.O, param.o, param.f);

    R_ti0       = mrp2dcm(s_ti0);               % Initial DCM from {I} to {T}
    R_li0       = dcm_ECI2LVLH_rv(r_t0, v_t0);  % Initial DCM from {I} to {L}
    R_lt0       = R_li0*R_ti0';                 % Initial DCM from {T} to {L}
    
    R_ct0       = mrp2dcm(s_ct0);               % Initial DCM from {T} to {C}
    R_cl0       = R_ct0*R_lt0';                 % Initial DCM from {L} to {C}
    R_ci0       = R_cl0 * R_li0;                % Initial DCM from {I} to {C}

    R_si0       = param.R_sc * R_ci0;           % Initial DCM from {I} to {S}
    R_sl0       = R_si0 * R_li0';               % Initial DCM from {L} to {S}
    R_ls0       = R_sl0';

    r_l0        = R_lt0*r_tc0-R_ls0*param.r_sc; % Chaser's initial relative position in {L} [m]
    
    rc          = zeros(12,1);                  % Feature's initial relative position in {C} [m]
    idr         = @(i) 3*(i-1) + 1 : 3*i;
    for i = 1:4
        rc(idr(i)) = param.rfun(R_cl0,R_ct0,r_l0,param.xi(idr(i)));
    end

    s0          = zeros(8,1);                   % Desired image feature coordinates
    ids         = @(i) 2*(i-1) + 1 : 2*i;
    for i = 1:4
        s0(ids(i)) = param.Kf*rc(idr(i))/rc(3*i);
    end
    param.s0    = s0;
    param.R_ti0 = R_ti0;
    param.R_ci0 = R_ci0;
end