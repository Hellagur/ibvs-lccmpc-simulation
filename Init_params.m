%% Initialize parameters
function [param, hist] = Init_params(method, s_ct0, r_tc0, w_ti0, n_laguerre, epsilon)
%INIT_PARAMS  Initialize system, model, and MPC parameters for image-based
% rendezvous and visual servo control simulation.
%
% This function constructs the parameter structures required by the
% image-based MPC framework, including orbital dynamics, spacecraft
% properties, camera model, disturbance configuration, and optimization
% problem setup.
%
% INPUTS:
%   s_ct0  - Initial Modified Rodrigues Parameters (MRP) of the chaser
%             relative to the target body frame {T}.
%   r_tc0  - Initial relative position of the chaser in {T}-frame [m].
%   w_ti0  - (Optional) Target angular velocity in inertial frame {I} [rad/s].
%
% OUTPUTS:
%   param  - Structure containing all physical, geometric, and model parameters.
%   hist   - Structure for storing simulation histories and intermediate data.
%
% -------------------------------------------------------------------------

    %% Target orbital parameters
    % Define orbital constants and reference orbital elements
    param.mu    = 398600.4418e9;                % Earth's gravitational parameter [m^3/s^2]
    param.J2    = 1082.63e-6;                   % Second zonal harmonic coefficient
    param.Re    = 6371e3;                       % Earth's mean radius [m]
    param.we    = 7.2921e-5;                    % Earth's rotation rate [rad/s]
    param.a     = param.Re + 685e3;             % Target orbit semi-major axis [m]
    param.e     = 0.00155;                      % Eccentricity
    param.i     = deg2rad(60);                  % Inclination [rad]
    param.O     = deg2rad(30);                  % Right ascension of ascending node [rad]
    param.o     = 0;                            % Argument of perigee [rad]
    param.f     = 0;                            % True anomaly [rad]
    param.n     = sqrt(param.mu/param.a^3);     % Mean motion [rad/s]
    param.utc   = [2025, 10, 01, 12, 0, 0];     % Initial UTC time

    %% Atmospheric parameters and space weather
    param.cD    = 2.0;                          % Drag coefficient
    param.matFile = aeroReadSpaceWeatherData('support/SW-Last5Years.csv');

    %% Target spacecraft properties
    param.Jt    = [17023.3,397.1,-2171.4;
                    397.1,124825.7,344.2;
                -2171.4,344.2,129112.2];        % Target inertia matrix [kg·m^2]
    param.mt    = 7827.8;                       % Target mass [kg]
    param.Areat = 4;                            % Target cross-sectional area [m^2]
    param.xi    = [0.5; 0.4;-1;
                0.5;-0.4;-1;
                -0.5;-0.4;-1;
                -0.5; 0.4;-1];                  % Feature point coordinates in {T} [m]
    param.d_t   = 2;                            % Distance from CoM to CP [m]

    %% Service spacecraft properties
    param.Js    = [30.0,  0.8,  0.5;
                    0.8, 32.5,  1.0;
                    0.5,  1.0, 35.0];           % Service spacecraft inertia matrix [kg·m^2]
    param.Jsv   = inv(param.Js);
    param.ms    = 100;                          % Service spacecraft mass [kg]
    param.Areas = 1;                            % Cross-sectional area [m^2]
    param.fm    = 5.0 / param.ms;               % Maximum linear acceleration [m/s^2]
    param.tm    = 0.2;                          % Maximum torque [N·m]
    param.ts    = 0.5;                          % Sampling period [s]
    param.d_s   = 1;                            % Distance from CoM to CP [m]

    % Input constraint matrices (upper/lower bounds on actuation)
    param.Au    = [eye(6);-eye(6)];
    param.bu    = [param.fm*ones(3,1); param.tm*ones(3,1);
                   param.fm*ones(3,1); param.tm*ones(3,1)];
    
    % Camera installation matrix, from {S} frame to {C} frame
    param.R_cs  = angle2dcm(pi/2, pi/2, 0, 'ZXY');
    param.R_sc  = param.R_cs';
    param.r_sc  = [0.3;0.0;0.0];                % camera's location in {S} frame

    %% Camera and image sensor parameters
    param.fl    = 20e-3/(10e-6);                % Focal length in pixel units [px]
    param.f0    = 20e-3/(10e-6);                % Nominal focal length [px]
    param.u0    = 0;                            % Principal point [px]
    param.n0    = 0;
    param.um    = 640;                          % Image half dimensions [px]
    param.nm    = 512;
    param.vm    = 0.5;                          % Velocity constraint
    param.wm    = deg2rad(5);
    param.Kf    = [param.f0, 0, param.u0; 0, param.f0, param.n0];

    % State and rate constraints in image space
    param.As    = [eye(8); -eye(8)];
    param.bs    = [repmat([param.um; param.nm], 4, 1); repmat([param.um; param.nm], 4, 1)];
    param.Avc   = [eye(6); -eye(6)];
    param.bvc   = repmat([param.vm*ones(3,1); param.wm*ones(3,1)], 2, 1);
    param.Ax    = blkdiag(param.As, param.Avc);
    param.bx    = [param.bs; param.bvc];

    %% Helper matrix functions
    % Define inline functions for skew-symmetric, attitude, and image Jacobians.
    % S(v) * w = v × w skew matrix 
    param.Sfun  = @(v) [  0,    -v(3),  v(2);
                        v(3),      0,  -v(1);
                       -v(2),    v(1),    0 ];
    % dsdt = C(s)*w kinematics matrix of modified Rodrigues parameters
    param.Cfun  = @(s) [ ...
                1 + s(1)^2 - s(2)^2 - s(3)^2,       2*(s(1)*s(2) - s(3)),           2*(s(1)*s(3) + s(2));
                    2*(s(1)*s(2) + s(3)),       1 - s(1)^2 + s(2)^2 - s(3)^2,       2*(s(2)*s(3) - s(1));
                    2*(s(1)*s(3) - s(2)),           2*(s(2)*s(3) + s(1)),       1 - s(1)^2 - s(2)^2 + s(3)^2 ] / 4;
    % M(u,n,z) maps 3D point velocity in image space to 2×3 matrix for projection
    param.Mfun  = @(u_val, n_val, z_val) [ ...
                param.f0,          0,    -(u_val - param.u0);
                0,          param.f0,    -(n_val - param.n0) ] / z_val;
    % N(u,n) builds part of the image‐point dynamics (2×3)
    param.Nfun  = @(u_val, n_val) [ ...
                (u_val-param.u0)*(n_val-param.n0),   - (param.f0^2 + (u_val-param.u0)^2),   param.f0*(n_val-param.n0);
                (param.f0^2 + (n_val-param.n0)^2),   - (u_val-param.u0)*(n_val-param.n0),  -param.f0*(u_val-param.u0) ] / param.f0;
    % L(u,n,z) image jacobian
    param.Lfun  = @(u_val, n_val, z_val) [ ...
                - param.Mfun(u_val, n_val, z_val), ...
                param.Nfun(u_val, n_val)];

    % Feature-related and attitude helper functions
    % r(R_cl,R_ct,r_l,xi_i) r_i = -R_cl * r_l - R_cs * r_sc + R_ct * xi_i
    param.rfun  = @(R_cl,R_ct,r_l,xi_i) - R_cl*r_l - param.R_cs*param.r_sc + R_ct*xi_i;
    % w(R_ct,w_tl,xi_i) w_i = R_ct * S(w_tl) * xi_i
    param.wfun  = @(R_ct,w_tl,xi_i) R_ct*param.Sfun(w_tl)*xi_i;

    % Camera angular and linear velocity helper functions
    % wc(w_sl) w_cl = R_cs * w_sl
    % vc(R_cl, v_l, w_cl) v_cl = R_cl * v_l - S(R_cs * r_sc)*w_cl
    param.wcfun = @(w_sl) param.R_cs * w_sl;
    param.vcfun = @(R_cl,v_l,w_cl) R_cl*v_l - param.Sfun(param.R_cs*param.r_sc)*w_cl;

    %% Clohessy–Wiltshire (CW) dynamic matrices
    % Linearized gravity gradient term
    param.A1    = [3*param.n^2, 0, 0; 0, 0, 0; 0, 0, -param.n^2];
    % Coriolis coupling term
    param.A2    = [0, 2*param.n, 0; -2*param.n, 0, 0; 0, 0, 0];

    param.A3fun = @(R_sl) A3fun(param, R_sl);
    param.A4fun = @(R_sl, w_sl) A4fun(param, R_sl, w_sl);
    param.A5fun = @(R_sl, w_si, w_li) A5fun(param, R_sl, w_si, w_li);
    param.A6fun = @(R_sl, w_sl, w_si, w_li) A6fun(param, R_sl, w_sl, w_si, w_li);
    param.A7fun = @(w_cl) A7fun(param, w_cl);
    param.Wfun  = @(R_sl, w_li, r_l) Wfun(param, R_sl, w_li, r_l);
    param.Gc    = Gcfun(param);

    %% Jacobian and model functions
    [Lsfun, F1fun, F1sfun, F1vfun, F1zfun] = Dyn_jacobian(param);
    param.Lsfun = Lsfun; 
    param.F1fun = F1fun;
    param.F1sfun= F1sfun;
    param.F1vfun= F1vfun;
    param.F1zfun= F1zfun;

    %% Initial conditions
    % Compute initial orbital, attitude, and relative states of both spacecraft
    % including target ECI state, LVLH transformation, and image feature states.
    % Note: If target's initial angular velocity is changed, the weight matrices 
    % Q and P also need to be adjusted simultaneously.

    s_ti0       = [0;0;0];                      % Target's initial MRPs
    if nargin < 4 || isempty(w_ti0)
        w_ti0   = deg2rad([-1.5;-1.5;1.5]);     % Target's initial angular velocity [rad/s]
    end
    % Target's position and velocity in {I}
    [r_t0,v_t0] = rv_OE2ECI(param.mu, param.a, param.e, param.i, param.O, param.o, param.f);

    s_ctd       = [0;0;0];                      % Camera's desired relative MRPs
    r_tcd       = [0;0;-5];                     % Camera's desired relative position in {T} [m]

    if nargin < 2 || isempty(s_ct0)
        s_ct0   = [0.08;0.11;0.03];             % Camera's initial relative MRPs
    end

    if nargin < 3 || isempty(r_tc0)
        r_tc0   = [-4;3;-20];                   % Camera's initial relative position in {T} [m]
    end

    R_ti0       = mrp2dcm(s_ti0);               % Initial DCM from {I} to {T}
    R_li0       = dcm_ECI2LVLH_rv(r_t0, v_t0);  % Initial DCM from {I} to {L}
    R_lt0       = R_li0*R_ti0';                 % Initial DCM from {T} to {L}
    
    R_ctd       = mrp2dcm(s_ctd);               % Desired DCM from {T} to {C}
    R_cld       = R_ctd*R_lt0';                 % Desired DCM from {L} to {C}
    R_lsd       = R_cld' * param.R_cs;          % Desired DCM from {S} to {L}

    R_ct0       = mrp2dcm(s_ct0);               % Initial DCM from {T} to {C}
    R_cl0       = R_ct0*R_lt0';                 % Initial DCM from {L} to {C}
    R_ci0       = R_cl0 * R_li0;                % Initial DCM from {I} to {C}

    R_si0       = param.R_sc * R_ci0;           % Initial DCM from {I} to {S}
    R_sl0       = R_si0 * R_li0';               % Initial DCM from {L} to {S}
    R_ls0       = R_sl0';

    r_ld        = R_lt0*r_tcd-R_lsd*param.r_sc; % Chaser's desired relative position in {L} [m]
    r_l0        = R_lt0*r_tc0-R_ls0*param.r_sc; % Chaser's initial relative position in {L} [m]
    v_l0        = [0;0;0];                      % Chaser's initial relative velocity in {L} [m/s]

    s_si0       = dcm2mrp(R_si0);               % Chaser's initial MRPs
    w_si0       = [0; 0; 0];                    % Chaser's initial angular velocity [rad/s]
    % Chaser's position and velocity in {I}
    [r_s0,v_s0] = rv_LVLH2ECI(r_t0, v_t0, r_l0, v_l0);

    s_sl0       = dcm2mrp(R_sl0);               % Chaser's initial relative MRPs
    w_li0       = [0; 0; norm(cross(r_t0, v_t0))/norm(r_t0)^2];
    w_sl0       = w_si0 - R_sl0*w_li0;          % Chaser's initial relative angular velocity [rad/s]

    rd          = zeros(12,1);                  % Feature's desired relative position in {C} [m]
    rc          = zeros(12,1);                  % Feature's initial relative position in {C} [m]
    idr         = @(i) 3*(i-1) + 1 : 3*i;
    for i = 1:4
        rd(idr(i)) = param.rfun(R_cld,R_ctd,r_ld,param.xi(idr(i)));
        rc(idr(i)) = param.rfun(R_cl0,R_ct0,r_l0,param.xi(idr(i)));
    end

    sd          = zeros(8,1);                   % Initial image feature coordinates
    s0          = zeros(8,1);                   % Desired image feature coordinates
    ids         = @(i) 2*(i-1) + 1 : 2*i;
    for i = 1:4
        sd(ids(i)) = param.Kf*rd(idr(i))/rd(3*i);
        s0(ids(i)) = param.Kf*rc(idr(i))/rc(3*i);
    end
    param.sd    = sd;
    param.s0    = s0;

    L0          = [ param.Lfun(s0(1),s0(2),rc(3));
                    param.Lfun(s0(3),s0(4),rc(6));
                    param.Lfun(s0(5),s0(6),rc(9));
                    param.Lfun(s0(7),s0(8),rc(12))];

    w_cl0       = param.wcfun(w_sl0);
    v_cl0       = param.vcfun(R_cl0, v_l0, w_cl0);
    vc          = [v_cl0; w_cl0];               % Camera initial relative velocity
    ds0         = L0*vc;                        % Initial image feature velocity

    param.n_states      = 14;                   % The dimension of dynamic states
    param.n_ftStates    = 16;                   % The dimension of image features
    param.n_scStates    = 12;                   % The dimension of spacecraft
    param.n_controls    = 6;                    % The dimension of control inputs

    % Test Code 26/02/08
    % param.sd = [250, 500, 250, 100, -250, 100, -250, 500]';
    % param.sd = [620, 500, 620, 100, 120, 100, 120, 500]';

    %% Disturbance estimation setup
    param.lambda        = 0.98;                            % Forgetting factor
    param.mud           = zeros(param.n_states,1);         % Mean disturbance
    param.Rd            = zeros(param.n_states);           % Covariance
    param.alpha         = chi2inv(0.95,param.n_states);    % Quantiles of the chi-square distribution
    param.gk            = 0;                               % Initial normalization coefficient

    %% Actuator noise and bias modeling
    % Define statistical parameters for reaction wheels (RW) and thrusters (TH).

    % Standard deviation
    param.sigma_eRW     = 1e-3;                 % Misalignment of the RWs
    param.sigma_fRW     = 1e-3;                 % Scale factor bias
    param.sigma_bRW     = 1e-3;                 % Offset of the RWs
    param.sigma_vRW     = 1e-3;                 % Noise of the RWs
    param.sigma_eTH     = 1e-3;                 % Misalignment of thrusters
    param.sigma_fTH     = 1e-3;                 % Scale of the thrusters
    param.sigma_bTH     = 1e-3;                 % Offset of the thrusters
    param.sigma_vTH     = 1e-3;                 % Noise of the thrusters

    % ECRV time constant
    param.tau_eRW       = 1e8;
    param.tau_fRW       = 1e8;
    param.tau_bRW       = 1e8;
    param.tau_eTH       = 1e8;
    param.tau_fTH       = 1e8;
    param.tau_bTH       = 1e8;

    param.alpha_eRW     = exp(-param.ts/param.tau_eRW);
    param.alpha_fRW     = exp(-param.ts/param.tau_fRW);
    param.alpha_bRW     = exp(-param.ts/param.tau_bRW);
    param.alpha_eTH     = exp(-param.ts/param.tau_eTH);
    param.alpha_fTH     = exp(-param.ts/param.tau_fTH);
    param.alpha_bTH     = exp(-param.ts/param.tau_bTH);

    % Enable input disturbance
    param.en_inputDis   = true;

    %% Tuning parameters of the cost matrices
    % Feature position and velocity
    param.Ss_min        = [0.2; 0.045];
    param.Ss_max        = [0.5; 0.095];
    param.Ss_bias       = 0;
    param.Ss_alpha      = 0.70;
    param.fis_gamma     = readfis('gamma_adjuster.fis');

    %% Previous control input u_{k-1}
    param.up            = zeros(6,1);

    %% MPC setup
    % Define MPC prediction horizon
    param.Np            = 10;
    param.Nc            = 10;
    
    % Define number of laguerre basis
    if nargin < 5 || isempty(n_laguerre)
        param.n_laguerre = 3;
    else
        param.n_laguerre = n_laguerre;
    end

    % Define number of variables
    if nargin < 1 || strcmp(method, 'eta') || isempty(method)
        param.n_variables = param.n_controls * param.n_laguerre;
    else
        param.n_variables = param.n_controls * param.Nc;
    end

    % Define Laguerre basis functions
    if nargin < 1 || strcmp(method, 'eta') || isempty(method)
        if nargin < 6 || isempty(epsilon)
            param.epsilon = 0.90;
        else
            param.epsilon = epsilon;
        end
        param.Phi         = Gen_laguerre_matrix(param.n_laguerre, param.epsilon, param.Nc);
        param.T           = zeros(param.n_controls*param.Nc, param.n_variables);
        
        % Compute transform matrix T (\eta <-> \Delta u)
        nu = param.n_controls;
        for i = 1:param.Nc
            Li = kron(eye(nu), param.Phi(:,i)');
            row = (i-1)*nu + (1:nu);
            param.T(row,:) = Li;
        end
    end
    
    % Define weighting matrix
    if nargin < 1 || strcmp(method, 'eta') || isempty(method)
        param.R         = diag(1e0*ones(1, param.n_variables));
    else
        param.R         = diag(1e0*ones(1, param.n_controls));
    end

    %% Constraint stacking for MPC formulation
    param.Ax_           = kron(eye(param.Np), param.Ax);
    param.bx_           = repmat(param.bx, param.Np, 1);
    param.Au_           = kron(eye(param.Nc), param.Au);
    param.bu_           = repmat(param.bu, param.Nc, 1);

    %% Initial prediction trajectories
    param.x_opt         = zeros(param.n_states, param.Np);
    if nargin < 1 || strcmp(method, 'eta') || isempty(method)
        param.var_opt   = zeros(param.n_variables, 1);
    else
        param.var_opt   = zeros(param.n_controls, param.Nc);
    end

    %% Simulation data storage
    % Initialize arrays for storing state, control, and disturbance history.
    param.Tsteps        = 600;

    % ===== System Variables =====

    % Feature's states: [s ds] in R^16 (image plane)
    hist.xs             = zeros(param.n_ftStates, param.Tsteps+1);
    % Target and chaser's states: 
    % [sigma^T_{TI} omega^T_{TI} r^I_T v^I_T 
    %  sigma^S_{SI} omega^S_{SI} r^I_S v^I_S] in R^24
    hist.sc             = zeros(param.n_scStates*2, param.Tsteps+1);
    % Relative states: [sigma^S_{SL} omega^S_{SL} rho^L drho^L] in R^12
    hist.xl             = zeros(param.n_scStates, param.Tsteps+1);

    % Control inputs: [a^C tau^C] in R^6
    % T: Truth
    hist.u              = zeros(param.n_controls, param.Tsteps);
    hist.uT             = zeros(param.n_controls, param.Tsteps);

    % ===== Auxiliary Variables =====

    % Feature points position: [r1^C r2^C r3^C r4^C] in R^12
    hist.rc             = zeros(12, param.Tsteps+1);
    % Relative velocity: [R_{CL}*drho^L-(R_{CS}*r_sc)^\times*omege^C{CL}; omega^C_{CL}] in R^6
    hist.vc             = zeros(6, param.Tsteps+1);

    % disturbace: [d_s d_ds] in R^16, k=0, 1, ...
    % T: Truth, P: Predicted, E: Error
    hist.dT             = zeros(param.n_states, param.Tsteps+1);
    hist.dP             = zeros(param.n_states, param.Tsteps+1);
    hist.dE             = zeros(param.n_states, param.Tsteps+1);

    % Rotatin matrices
    hist.R_ti           = cell(1, param.Tsteps+1);
    hist.R_ci           = cell(1, param.Tsteps+1);
    hist.R_li           = cell(1, param.Tsteps+1);
    hist.R_cl           = cell(1, param.Tsteps+1);
    hist.R_si           = cell(1, param.Tsteps+1);
    hist.R_sl           = cell(1, param.Tsteps+1);

    % Angular velocity
    hist.w_li           = zeros(3, param.Tsteps+1);

    % Predicted depth: [Z1^C Z2^C Z3^C Z4^C] in R^4
    hist.zhat           = zeros(4, param.Tsteps+1);

    % The algorithm's time consumption
    hist.tcon           = zeros(1, param.Tsteps);

    % Disturbance for actuators
    hist.eRW            = param.sigma_eRW*randn(3, param.Tsteps+1);
    hist.fRW            = param.sigma_fRW*randn(3, param.Tsteps+1);
    hist.bRW            = param.sigma_bRW*randn(3, param.Tsteps+1);
    hist.vRW            = param.sigma_vRW*randn(3, param.Tsteps);
    hist.eTH            = param.sigma_eTH*randn(3, param.Tsteps+1);
    hist.fTH            = param.sigma_fTH*randn(3, param.Tsteps+1);
    hist.bTH            = param.sigma_bTH*randn(3, param.Tsteps+1);
    hist.vTH            = param.sigma_vTH*randn(3, param.Tsteps);

    % Record tuning parameters
    hist.Ss             = zeros(2, param.Tsteps+1);
    hist.gamma          = zeros(1, param.Tsteps+1);

    % ===== Set Initial Values =====
    hist.xs(:,1)        = [s0; ds0];
    hist.sc(:,1)        = [s_ti0; w_ti0; r_t0; v_t0; s_si0; w_si0; r_s0; v_s0];
    hist.xl(:,1)        = [s_sl0; w_sl0; r_l0; v_l0];
    hist.rc(:,1)        = rc;
    hist.vc(:,1)        = vc;
    hist.R_ti{1}        = R_ti0;
    hist.R_ci{1}        = R_ci0;
    hist.R_li{1}        = R_li0;
    hist.R_cl{1}        = R_cl0;
    hist.R_si{1}        = R_si0;
    hist.R_sl{1}        = R_sl0;
    hist.w_li(:,1)      = w_li0;
    hist.zhat(:,1)      = rc(3:3:end);
end

%% Helper function
function A3 = A3fun(param, R_sl)
    R_cs = param.R_cs;
    R_cl = R_cs * R_sl;

    A1 = param.A1;
    A3 = R_cl * A1 * R_cl';
end

function A4 = A4fun(param, R_sl, w_sl)
    R_cs = param.R_cs;
    R_cl = R_cs * R_sl;
    w_cl = R_cs * w_sl;

    A2 = param.A2;
    A4 = R_cl * A2 * R_cl' - param.Sfun(w_cl);
end

function A5 = A5fun(param, R_sl, w_si, w_li)
    Sfun = param.Sfun;
    R_cs = param.R_cs;
    R_sc = param.R_sc;
    Jsv  = param.Jsv;
    Js   = param.Js;

    A5 = - R_cs * Jsv * Sfun(w_si) * Js * R_sc ...
         + R_cs * Jsv * Sfun(Js * R_sl * w_li) * R_sc ...
         - Sfun(R_cs * R_sl * w_li);
end

function A6 = A6fun(param, R_sl, w_sl, w_si, w_li)
    Sfun = param.Sfun;
    R_cs = param.R_cs;
    r_sc = param.r_sc;

    A4 = A4fun(param, R_sl, w_sl);
    A5 = A5fun(param, R_sl, w_si, w_li);

    rc = R_cs * r_sc;
    A6 = [A4, A4*Sfun(rc) - Sfun(rc)*A5; zeros(3), A5];
end

function A7 = A7fun(param, w_cl)
    Sfun = param.Sfun;
    R_cs = param.R_cs;
    R_sc = param.R_sc;
    r_sc = param.r_sc;
    Jsv  = param.Jsv;
    Js   = param.Js;
    
    rc = R_cs * r_sc;
    A7 = [-Sfun(w_cl), Sfun(rc) * (R_cs * Jsv) * Sfun(R_sc * w_cl) * Js * R_sc - Sfun(w_cl) * Sfun(rc);
          zeros(3), -(R_cs * Jsv) * Sfun(R_sc * w_cl) * Js * R_sc];
end

function W = Wfun(param, R_sl, w_li, r_l)
    Sfun = param.Sfun;
    R_cs = param.R_cs;
    Jsv  = param.Jsv;
    Js   = param.Js;

    R_cl = R_cs * R_sl;
    rc   = R_cs * param.r_sc;
    A3   = A3fun(param, R_sl);
    del  = R_cs * Jsv * Sfun(R_sl * w_li) * Js * R_sl * w_li;

    W = [A3 * R_cl * r_l + Sfun(rc)*del; -del];
end

function Gc = Gcfun(param)
    Sfun = param.Sfun;
    R_cs = param.R_cs;
    r_sc = param.r_sc;
    Jsv  = param.Jsv;
    Gc   = [R_cs, -Sfun(R_cs * r_sc) * R_cs * Jsv; 
            zeros(3), R_cs * Jsv];
end