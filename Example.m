%% MAIN SIMULATION SCRIPT FOR CHANCE-CONSTRAINED IBVS-MPC
%
% This script performs a simulation of an image-based spacecraft rendezvous
% control scenario using a chance-constrained Model Predictive Control (CC-MPC)
% framework. It initializes system parameters, performs disturbance estimation,
% solves the MPC optimization problem iteratively, and visualizes results
% through multiple trajectory plots.
%
% The simulation supports various configurations:
%   - Control variable methods: 'eta', 'du', 'u'
%   - Cost parameter methods: 'adaptive', 'zero', 'one'
%   - Monte Carlo analysis with varying initial conditions
%   - Laguerre parameter studies
%
% Steps:
%   1. Generate initial pose (or load from file)
%   2. Generate fuzzy inference system for gamma adjustment
%   3. Initialize system, model, and MPC parameters
%   4. Run iterative MPC simulation loop
%   5. Plot results (if enabled)

clc; clear;

%% ============================================================
%  Main Simulation Script for Chance-Constrained IBVS-MPC
%  ------------------------------------------------------------
%  This script performs a simulation of an image-based
%  rendezvous control scenario using a chance-constrained
%  Model Predictive Control (CC-MPC) framework. It initializes
%  system parameters, performs disturbance estimation,
%  solves the MPC optimization problem iteratively, and
%  visualizes results through multiple trajectory plots.
% ============================================================

%% === Step 1: Generate initial pose (Optional) ===
% N = 500;
% [S_ct0, R_tc0, W_ti0, S0] = Gen_init_pose(N);

%% or load initial pose from .mat file (Optional)
load('Data/Monte_Carlo_Initial_Values/initial_values.mat');

%% === Step 2: Generate 'gamma_adjuster.fis' fuzzy file (Once) ===
run('Gen_fuzzy_file.m');

%% === Step 3: Initialize system, model, and MPC parameters ===
Info.Cv_method      = 'eta';            % three control-variable methods: 'eta', 'du', 'u'
Info.Cp_method      = 'adaptive';       % three cost-parameter methods: 'adaptive', 'zero', 'one'
Info.En_chanceCons  = true;             % enable to use chance constraints?
Info.En_default     = true;             % enable to use default initial values (s_ct0,r_tc0,w_ti0)?
Info.En_varNeps     = false;            % enable to vary parameters (N,epsilon)?
Info.En_rndShuffle  = false;            % enable rng('shuffle')?
Info.En_RT_figure   = true;             % enable to plot real-time figure?
Info.En_saveFile    = false;            % enable to save results?
Info.En_fileName    = false;            % enable to use Info.fileName?
Info.En_showPlot    = false;            % enable to plot figures?
Info.fileTotalNum   = 500;
Info.filePath       = fullfile('Data', 'Control_Variables_Compare', Info.Cv_method);
Info.fileName       = @(i) [num2str(i), '.mat'];


if Info.En_rndShuffle                   % Enable rng("shuffle")?
    rng("shuffle");
else
    rng(42, "twister");
end


if Info.En_varNeps                      % Enable to vary (N,epsilon)?
    nl_list     = 2:1:10;
    eps_list    = 0.05:0.05:0.95;
    [N, E]      = meshgrid(nl_list, eps_list);
    nl_eps      = [N(:), E(:)];

    Info.filePath       = fullfile('Data', 'Laguerre_Parameters_Compare');
    Info.fileName       = @(N,eps) ['N=',num2str(N),'_','eps=',num2str(eps),'.mat'];
    Info.fileTotalNum   = size(nl_eps, 1);
end


if Info.En_default                      % Enable default parameters?
    Info.filePath       = fullfile('Data', 'Cost_Parameters_Compare');
    Info.fileName       = @(gamma) ['gamma=', gamma, '.mat'];
    Info.fileTotalNum   = 1;
end

% set 'sd' in 'Init_param.m' to verify chance constraints.
% if Info.En_chanceCons
%     Info.filePath       = fullfile('Data', 'Laguerre_Parameters_Compare');
%     Info.fileName       = @(N,eps) ['N=',num2str(N),'_','eps=',num2str(eps),'.mat'];
% end

%% === Step 4: Iterative MPC simulation loop ===
for i = 1:Info.fileTotalNum

    if Info.En_default                  % Enable default parameters?
        if Info.En_varNeps              % Enable varying N and epsilon?
            close all;
            [param, hist] = Init_params(Info.Cv_method, [], [], [], nl_eps(i,1), nl_eps(i,2));
        else
            [param, hist] = Init_params(Info.Cv_method);
        end
    else
        close all;
        [param, hist] = Init_params(Info.Cv_method, S_ct0(:,i), R_tc0(:,i), W_ti0(:,i));
    end
    
    % (1) Off-line: Create mosek solver.
    solver = Create_mosek_qp(param.n_variables);
    
    if Info.En_RT_figure                % Enable real-time figure?
        [h, xdata, ydata] = Set_RT_figure();
    end

    % (2) On-line: Compute simulation loop. 
    for k = 1:param.Tsteps

        if Info.En_RT_figure            % Enable real-time figure?
            % draw 1st point's depth trajectory
            [h, xdata, ydata] = Add_RT_xydata(h, xdata, ydata, k, hist.zhat(1,k));
        end
        
        tcon = tic;                     % Record start time.
    
        % (a) Disturbance estimation.
        [param.mud, param.Rd, param.gk] = Est_disturbance( ...
            hist.dT(:,k), param.mud, param.Rd, param.gk, param.lambda, k);
    
        % (b) Update system dynamic matrices.
        param = Dyn_ibvs(param, hist, k);
        [M, H, S, D] = Build_prediction_matrices(Info.Cv_method, param);
        
        % (c) Compute fuzzy-logic factor gamma.
        if strcmp(Info.Cp_method, 'zero')
            gamma = 0;
        elseif strcmp(Info.Cp_method, 'one')
            gamma = 1;
        else
            gamma = ts_fuzzy_gamma(param, hist, k);
        end
        
        hist.gamma(:,k+1) = gamma;

        % (d) Build QP objective and contraints.
        xk = [hist.xs(1:8,k); hist.vc(:,k)];
        [Hqp, fqp] = Build_qp_objective  (Info.Cv_method, param, xk, M, H, S, D, gamma);
        [Aqp, bqp] = Build_qp_constraints(Info.Cv_method, Info.En_chanceCons, param, xk, M, H, S, D);
    
        % (e) Update mosek solver and solve QP.
        solver = Update_qp(solver, Hqp, fqp, Aqp, bqp);
        [var_opt, sol_info, solver] = Solve_qp(solver);
    
        % (f) Apply control input.
        if strcmp(sol_info, 'ERROR') || (~strcmp(sol_info, 'OPTIMAL') ...
        && ~strcmp(sol_info, 'PRIMAL_AND_DUAL_FEASIBLE'))
            % Solve failed: Maintain previous-step control.
            hist.u(:,k) = param.up;
            var_opt = param.var_opt;    
        else
            % Solve succeed: Compute current-step control increment.
            if strcmp(Info.Cv_method, 'eta')
                delta_u = kron(eye(param.n_controls), param.Phi(:,1)') * var_opt;
                hist.u(:,k) = param.up + delta_u;
            elseif strcmp(Info.Cv_method, 'du')
                delta_u = var_opt(1:param.n_controls);
                hist.u(:,k) = param.up + delta_u;
            elseif strcmp(Info.Cv_method, 'u')
                hist.u(:,k) = var_opt(1:param.n_controls);
            end
        end
        
        % (g) Compute predicted trajectory.
        if strcmp(Info.Cv_method, 'eta')
            us = param.T * var_opt;
            ds = kron(ones(param.Np,1), param.mud);
            xs = M * xk + H * param.up + S * us + D * ds;
        elseif strcmp(Info.Cv_method, 'du')
            us = var_opt;
            ds = kron(ones(param.Np,1), param.mud);
            xs = M * xk + H * param.up + S * us + D * ds;
        elseif strcmp(Info.Cv_method, 'u')
            us = var_opt;
            ds = kron(ones(param.Np,1), param.mud);
            xs = M * xk + S * us + D * ds;
        end
        param.x_opt = reshape(xs, param.n_states, []);
        
        % (h) Compute prediction error (MSE).
        Ss = Predict_error(param);
        hist.Ss(:,k+1) = Ss;

        % (i) Record optimal solutions.
        param.up = hist.u(:,k);
        param.var_opt = var_opt;
    
        hist.tcon(k) = toc(tcon);       % Record end time.
    
        % (j) Propagate system dynamics.
        hist = Dyn_simulation(param, hist, k);
    end
    
    if Info.En_saveFile                 % Enable save file?
        if Info.En_varNeps && ~ Info.En_default % Enable file name for N and eps?
            fileName = Info.fileName(param.n_laguerre, param.epsilon);
        elseif Info.En_default
            fileName = Info.fileName(Info.Cp_method);
        else
            fileName = Info.fileName(i);
        end

        fileName = fullfile(Info.filePath, fileName);
        save(fileName, "param", "hist");
        disp(['counter = ', num2str(i)]);
    end


end

%% Plot figures
if Info.En_showPlot && Info.En_default
    %% 3D relative motion in LVLH frame ✅
    Plot_relative_motion_trajectory(param, hist, k+1, false);

    %% 2D projection (Y-X plane) of relative motion ✅
    Plot_relative_motion_trajectory2D(param, hist, k+1, false);

    %% Feature trajectories in the camera image plane ✅
    Plot_feature_states_trajectory(param, hist, k, false);

    %% Control input trajectories in the chaser body frame ✅
    Plot_control_inputs_trajectory(param, hist, k, false);

    %% Control inputs error ✅
    Plot_control_inputs_error(param, hist, k);

    %% Feature error trajectories (pixel domain) ✅
    Plot_feature_error_trajectory(param, hist, k);
end

if Info.En_showPlot && ~Info.En_default && ~Info.En_varNeps
    %% Initial pose ✅
    Plot_monte_carlo_init_pose(S_ct0, R_tc0, Info.fileTotalNum);
    
    %% Initial image postion ✅
    Plot_monte_carlo_init_image_plane(S0, Info.fileTotalNum);

    %% Pixel positon error trajectories ✅
    Plot_monte_carlo_feature_position_error2(Info.filePath, Info.fileTotalNum);

    %% Relative pose trajectories ✅
    Plot_monte_carlo_relative_pose_trajectories2(Info.filePath, Info.fileTotalNum);

    %% Terminal image error ✅
    Plot_monte_carlo_terminal_image_error_boxplot2(Info.filePath, Info.fileTotalNum);

    %% Terminal pose error ✅
    Plot_monte_carlo_terminal_pose_error_boxplot(Info.filePath, Info.fileTotalNum);

    %% Compare with three cases: u, du, eta ✅
    filePath = 'Data/Control_Variables_Compare/';
    Plot_monte_carlo_accumulated_energy3D([filePath, 'u'], [filePath, 'du'], [filePath, 'eta'], Info.fileTotalNum);

    %% Compare with three cases: gamma != 0, gamma = 0, gamma = 1
    filePath = 'Data/Cost_Parameters_Compare/';
    file1 = [filePath, 'gamma=adaptive.mat'];
    file2 = [filePath, 'gamma=0.mat'];
    file3 = [filePath, 'gamma=1.mat'];
    Plot_relative_pose_error_compare(file1, file2, file3);

    %% Accumulated energy ✅
    filePath = 'Data/Cost_Parameters_Compare/';
    file1 = [filePath, 'gamma=adaptive.mat'];
    file2 = [filePath, 'gamma=0.mat'];
    file3 = [filePath, 'gamma=1.mat'];
    Plot_accumulated_energy_compare(file1, file2, file3);

    %% feature trajectories ❌ using *_zoom.m
    filePath = 'Data/Chance_Constraints_Compare/';
    Plot_monte_carlo_feature_trajectories3([filePath, 'chance'], Info.fileTotalNum);
    Plot_monte_carlo_feature_trajectories3([filePath, 'no_chance'], Info.fileTotalNum);

    %% feature trajectories ✅
    filePath = 'Data/Chance_Constraints_Compare/';
    Plot_monte_carlo_feature_trajectories_zoom([filePath, 'chance'], Info.fileTotalNum);
    Plot_monte_carlo_feature_trajectories_zoom([filePath, 'no_chance'], Info.fileTotalNum);

end

%% Laguerre function with different nl-eps
if Info.En_showPlot && Info.En_varNeps
    filePath = Info.filePath;
    fileName = Info.fileName;
    
    %% Pixel error ✅
    Plot_laguerre_parameter_eps_pixel_error2(filePath, fileName, nl_eps, 601);
    
    %% Energy ✅
    Plot_laguerre_parameter_eps_control_energy2(filePath, fileName, nl_eps, 600);
    
    %% Pixel error heatmap ✅
    Plot_laguerre_parameter_heatmap(filePath, fileName, nl_eps, 601, 'error');
    
    %% Energy heatmap ✅
    Plot_laguerre_parameter_heatmap(filePath, fileName, nl_eps, 600, 'energy');
end
