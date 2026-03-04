%% LAGUERRE BASIS MATRIX GENERATION
function Phi = Gen_laguerre_matrix(N, epsilon, Nc)
% Generate Laguerre matrix Phi with dimension: Nc × N
%
% This function constructs a Laguerre basis matrix used in model predictive
% control for spacecraft rendezvous operations. The matrix columns represent
% Laguerre functions evaluated at different time instances within the control
% horizon.
%
% Inputs:
%   N        - number of Laguerre basis functions
%   epsilon  - time scaling parameter (0 ≤ epsilon < 1)
%   Nc       - control horizon length (number of time steps)
%
% Outputs:
%   Phi     - Laguerre matrix of size N × Nc

    Phi = zeros(N, Nc);
    
    % Generate A_l matrix
    A_l = build_A_l_matrix(N, epsilon);
    
    % Compute L(0)
    iota = 1 - epsilon^2;
    L0 = sqrt(iota) * ((-epsilon).^(0:N-1)');
    
    % Recursively generate all L(i)
    L_current = L0;
    for i = 1:Nc
        Phi(:, i) = L_current;
        L_current = A_l * L_current;  % L(i+1) = A_l * L(i)
    end
end

%% A_L MATRIX CONSTRUCTION
function A_l = build_A_l_matrix(N, epsilon)
% Build A_l matrix according to paper equation (2.10)
%
% This function constructs the state transition matrix for Laguerre functions,
% which enables recursive computation of the Laguerre basis. The matrix structure
% follows the analytical formulation derived in the referenced paper.
%
% Inputs:
%   N        - number of Laguerre basis functions
%   epsilon  - time scaling parameter (0 ≤ epsilon < 1)
%
% Outputs:
%   A_l      - transition matrix of size N × N

    A_l = zeros(N, N);
    iota = 1 - epsilon^2;  % According to paper definition: ι = 1 - ε²
    
    % Fill A_l matrix
    for i = 1:N
        for j = 1:N
            if i == j
                % Diagonal elements are all epsilon
                A_l(i, j) = epsilon;
            elseif i > j
                % According to formula: A_l(i,j) = (-ε)^{i-j-1} * ι
                k = i - j - 1;  % Exponent
                A_l(i, j) = ((-epsilon)^k) * iota;
            end
            % i < j case is 0, matrix defaults to 0
        end
    end
end
