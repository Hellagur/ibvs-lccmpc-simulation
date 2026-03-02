function [M, H, S, D] = Build_prediction_matrices(method, param)
    
    % Prediction horizon
    Np = param.Np;
    Nc = param.Nc;

    % System matrices
    Ad = param.Ad;
    Bd = param.Bd;

    % System dimensions
    nx = param.n_states;    % Number of state variables
    nu = param.n_controls;  % Number of control inputs

    % Construct dynamic equation
    if isempty(method) || strcmp(method, 'eta') || strcmp(method, 'du')
        % x_s = M x_k + H u_{k-1} + S \Delta u_s + D d_s
        H = zeros(nx*Np, nu);
    else
        % x_s = M x_k + S u_s + D d_s
        H = [];
    end

    M = zeros(nx*Np, nx);
    S = zeros(nx*Np, nu*Nc);
    D = zeros(nx*Np, nx*Np);
    
    if isempty(method) || strcmp(method, 'eta') || strcmp(method, 'du')
        % x_s = M x_k + H u_{k-1} + S \Delta u_s + D d_s
        for i = 1:Np
            % 1. 填充 M 矩阵
            M((i-1)*nx+1 : i*nx, :) = Ad^i;
            
            % 2. 填充 H 矩阵 (Sum A^j * B)
            sum_AB = zeros(nx, nu);
            for j = 0:i-1
                sum_AB = sum_AB + Ad^j * Bd;
            end
            H((i-1)*nx+1 : i*nx, :) = sum_AB;
            
            % 3. 填充 S 矩阵
            for j = 1:min(i, Nc)
                % S 的每一块其实是对应步数的 H 项
                % 例如 S(row=i, col=j) = H(step = i-j+1)
                sub_step = i - j + 1;
                sum_S = zeros(nx, nu);
                for k = 0:sub_step-1
                    sum_S = sum_S + Ad^k * Bd;
                end
                S((i-1)*nx+1 : i*nx, (j-1)*nu+1 : j*nu) = sum_S;
            end
    
            % 4. 填充 D 矩阵 (干扰项)
            for j = 1:i
                D((i-1)*nx+1 : i*nx, (j-1)*nx+1 : j*nx) = Ad^(i-j);
            end
        end
    else
        % x_s = M x_k + S u_s + D d_s
        for i = 1:Np
            % 1. 填充 M 矩阵
            M((i-1)*nx+1 : i*nx, :) = Ad^i;
            
            % 2. 填充 S 矩阵
            for j = 1:min(i, Nc)
                S((i-1)*nx+1 : i*nx, (j-1)*nu+1 : j*nu) = Ad^(i-j) * Bd;
            end
            
            % 3. 填充 D 矩阵 (干扰项)
            for j = 1:i
                D((i-1)*nx+1 : i*nx, (j-1)*nx+1 : j*nx) = Ad^(i-j);
            end
        end
    end

end