%% SOLVE QUADRATIC PROGRAMMING
function [uopt, info, solver] = Solve_qp(solver)
% Solve quadratic programming problem using MOSEK optimizer
%
% This function invokes the MOSEK solver to compute the optimal control
% inputs for the MPC optimization problem. It supports warm-starting
% using previously computed solutions for improved computational efficiency.
%
% Inputs:
%   solver - structure containing MOSEK problem and parameter settings
%
% Outputs:
%   uopt   - optimal control inputs
%   info   - solver status ('OPTIMAL', 'ERROR', or 'PRIMAL_AND_DUAL_FEASIBLE')
%   solver - updated solver structure with solution for warm-start

    if isfield(solver,'xx') && ~isempty(solver.xx)  % Warm-start only with valid xx
        solver.prob.xx = solver.xx;  % Use itr or intpnt depending on MOSEK version
    end
    [rcode, res] = mosekopt('minimize', solver.prob, solver.param);
    if rcode == 0 && isfield(res,'sol') && isfield(res.sol,'itr')
        info = res.sol.itr.prosta;  % Use itr for QP
        uopt = res.sol.itr.xx;
        solver.xx = uopt;  % Save for next iteration
    else
        info = 'ERROR';  % Or res.info if available
        uopt = [];  % Return empty on failure
        warning('MOSEK solve failed: %s', info);
    end
end
