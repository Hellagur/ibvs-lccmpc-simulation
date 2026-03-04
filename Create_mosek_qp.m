%% CREATE MOSEK QP SOLVER
function solver = Create_mosek_qp(nvar)
% Create MOSEK QP solver configuration structure
%
% This function initializes the MOSEK optimizer for solving quadratic
% programming problems in model predictive control. It sets up the problem
% structure with default parameters and configuration options.
%
% Inputs:
%   nvar   - number of optimization variables
%
% Outputs:
%   solver - structure containing MOSEK problem and parameter settings

    % Do not fix ncon, let update_qp handle it dynamically
    prob.c          = zeros(nvar,1);
    prob.a          = sparse(0, nvar);  % Initially empty
    prob.blc        = [];  % Set dynamically
    prob.buc        = [];
    prob.blx        = -inf(nvar,1);
    prob.bux        = inf(nvar,1);
    % Placeholder Hessian
    prob.qosubi     = [];
    prob.qosubj     = [];
    prob.qoval      = [];
    
    param.MSK_IPAR_OPTIMIZER                = 'MSK_OPTIMIZER_INTPNT';
    param.MSK_IPAR_INTPNT_MAX_ITERATIONS    = 50;
    param.MSK_IPAR_NUM_THREADS              = 1;
    param.MSK_IPAR_LOG                      = 0;  % 0=disable log, 1=brief, 2=detailed
    
    solver.prob     = prob;
    solver.param    = param;
end
