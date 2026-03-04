%% BUILD QP CONSTRAINTS
function [Aqp, bqp] = Build_qp_constraints( ...
        method, en_ccons, param, xk, M, H, S, D)
% Construct constraint matrices for quadratic programming problem
%
% This function builds the inequality constraints for the QP problem in
% model predictive control. It handles input constraints, state constraints,
% and applies chance constraint tightening for robustness against disturbances.
%
% Inputs:
%   method   - constraint formulation method: 'eta' (default), 'du', or 'u'
%   en_ccons - enable chance constraints flag (boolean)
%   param    - structure containing control parameters and constraints
%   xk       - current state vector
%   M, H, S  - system matrices for prediction
%   D        - disturbance matrix
%
% Outputs:
%   Aqp - combined constraint matrix
%   bqp - combined constraint bounds

    % Dimensions
    nu = param.n_controls;
    Np = param.Np;
    Nc = param.Nc;


    % ---------- Input constraint ----------
    if isempty(method) || strcmp(method, 'eta')
        C    = kron(tril(ones(Nc)), eye(nu));
        Up   = repmat(param.up, Nc, 1);
        Au_u = param.Au_ * C * param.T;   % Maps η to input constraint
        bu_u = param.bu_ - param.Au_ * Up;
    elseif strcmp(method, 'du')
        C    = kron(tril(ones(Nc)), eye(nu));
        Up   = repmat(param.up, Nc, 1);
        Au_u = param.Au_ * C;
        bu_u = param.bu_ - param.Au_ * Up;
    elseif strcmp(method, 'u')
        Au_u = param.Au_;
        bu_u = param.bu_;
    end


    % ---------- Disturbance sequence ----------
    ds = kron(ones(Np,1), param.mud);


    % ---------- Chance constraint tightening ----------
    Ac = param.Ax_;
    bc = param.bx_;
    up = param.up;

    if en_ccons     % Enable chance constraints?
        bd = Define_chance_cons(Ac, D, param.Rd, param.alpha);
    else
        bd = zeros(size(bc));
    end


    if isempty(method) || strcmp(method, 'eta')
        Aineq = Ac * S * param.T;
        bineq = bc - Ac * (M * xk + H * up + D * ds) + bd;
    elseif strcmp(method, 'du')
        Aineq = Ac * S;
        bineq = bc - Ac * (M * xk + H * up + D * ds) + bd;
    elseif strcmp(method, 'u')
        Aineq = Ac * S;
        bineq = bc - Ac * (M * xk + D * ds) + bd;
    end


    % ---------- Final QP constraints ----------
    Aqp = [Au_u;
           Aineq];

    bqp = [bu_u;
           bineq];
end
