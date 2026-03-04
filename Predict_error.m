%% PREDICT ERROR CALCULATION
function Ss = Predict_error(param)
% Calculate prediction errors from optimized states
%
% This function computes the average prediction errors over the horizon
% by analyzing the optimized state trajectories. It extracts position
% and angular velocity errors from the optimal solution.
%
% Inputs:
%   param - structure containing prediction horizon Np and optimal states x_opt
%
% Outputs:
%   Ss    - vector [v_err; w_err] containing average velocity and angular
%           velocity errors over the prediction horizon

    Np      = param.Np;
    x_opt   = param.x_opt;
    
    err_v   = x_opt(9:11,:);
    v_err   = sum(vecnorm(err_v)) / Np;
    
    err_w   = x_opt(12:end,:);
    w_err   = sum(vecnorm(err_w)) / Np;
    
    Ss      = [v_err; w_err];
end
