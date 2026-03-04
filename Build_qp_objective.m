%% BUILD QP OBJECTIVE
function [Hqp, fqp] = Build_qp_objective(method, param, xk, M, H, S, D, gamma)
% Construct objective function matrices for quadratic programming problem
%
% This function builds the quadratic cost function for the MPC optimization.
% It constructs the Hessian matrix Hqp and linear term fqp for the QP:
%   min  0.5 * u' * Hqp * u + fqp' * u
%
% The cost penalizes tracking error and control effort, with adjustable weights.
%
% Inputs:
%   method  - formulation method: 'eta' (default), 'du', or 'u'
%   param   - structure containing prediction parameters and weights
%   xk      - current state vector
%   M, H, S - system matrices for prediction
%   D       - disturbance matrix
%   gamma   - weighting factor for terminal cost adjustment
%
% Outputs:
%   Hqp - Hessian matrix of the quadratic cost
%   fqp - linear term of the quadratic cost

    Np = param.Np;
    Nc = param.Nc;


    % ---------- Reference ----------
    r = [param.sd; zeros(6,1)];
    rbar = repmat(r, Np, 1);


    % ---------- Q, P ----------
    Qdiag = blkdiag( ...
        1e1*eye(8), ...
        1e6*eye(6)*gamma);
    
    Qds = 1e1 * eye(8);
    Cv  = param.Ls * [zeros(6,8), eye(6)];

    Q = Qdiag + gamma * Cv' * Qds * Cv;
    P = 1e1 * Qdiag;


    % ---------- Block diagonal cost ----------
    Qbar = blkdiag( kron(eye(Np-1), Q), P );


    % ---------- Disturbance ----------
    ds = kron(ones(Np,1), param.mud);


    % ---------- Constant offset ----------
    if isempty(method) || strcmp(method, 'eta') || strcmp(method, 'du')
        x0 = M*xk + H*param.up + D*ds - rbar;
    else
        x0 = M*xk + D*ds - rbar;
    end


    % ---------- QP matrices ----------
    if isempty(method) || strcmp(method, 'eta')
        T = param.T;
        Hqp = 2 * (T' * S' * Qbar * S * T + param.R);
        fqp = 2 * (T' * S' * Qbar * x0);
    else
        Rbar = blkdiag( kron(eye(Nc), param.R));
        Hqp = 2 * (S' * Qbar * S + Rbar);
        fqp = 2 * (S' * Qbar * x0);
    end
end
