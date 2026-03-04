%% DEFINE CHANCE CONSTRAINTS
function bd = Define_chance_cons(Ac, D, Rd, alpha)
% Compute probabilistic constraint tightening for chance constraints
%
% This function calculates the tightening term for state constraints to
% handle disturbances with known covariance. It projects the disturbance
% effect onto each constraint and applies conservative tightening based on
% the specified confidence level alpha.
%
% Inputs:
%   Ac    - constraint matrix for state bounds
%   D     - disturbance transition matrix
%   Rd    - disturbance covariance matrix
%   alpha - confidence parameter (probability level)
%
% Outputs:
%   bd    - tightening vector added to constraint bounds

    % Extract disturbance dimension and prediction horizon
    n  = size(Rd, 1);             % State dimension
    m  = size(Ac, 1);             % Total number of stacked inequalities
    Np = size(D, 2) / n;          % Prediction horizon inferred from Gd

    % Project disturbance effect on constraints
    A_Gd    = Ac * D;               % (m x Np*n)
    bd      = zeros(m, 1);          % Initialize tightening term

    % ---------------------------------------------------------------------
    % Compute probabilistic tightening term b_d(i)
    % Each inequality A_c(i,:) x <= b_c(i) is adjusted by the worst-case
    % standard deviation of projected disturbance:
    %
    %     b_d(i) = sum_j [ -sqrt(alpha * a_ij * R_d * a_ij') ]
    %
    % where a_ij is the part of row i of A_Gd corresponding to step j.
    % This accounts for the propagation of uncertainty at each prediction step.
    % ---------------------------------------------------------------------
    for i = 1:m
        a_i = - A_Gd(i, :);
        b_sum = 0;
        for j = 1:Np
            a_ij = a_i((j-1)*n+1 : j*n);
            b_sum = b_sum - sqrt(alpha * a_ij * Rd * a_ij');  % Conservative tightening
        end
        bd(i) = b_sum;
    end
end
