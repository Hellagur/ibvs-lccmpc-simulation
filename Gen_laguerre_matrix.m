%% Laguerre functions
function Phi = Gen_laguerre_matrix(N, epsilon, Nc)
% 生成Laguerre矩阵Phi，维度: Nc × N
% Nc: 控制时域长度
% N: Laguerre基函数数量
% epsilon: 时间尺度参数

    Phi = zeros(N, Nc);
    
    % 生成A_l矩阵
    A_l = build_A_l_matrix(N, epsilon);
    
    % 计算L(0)
    iota = 1 - epsilon^2;
    L0 = sqrt(iota) * ((-epsilon).^(0:N-1)');
    
    % 递归生成所有L(i)
    L_current = L0;
    for i = 1:Nc
        Phi(:, i) = L_current;
        L_current = A_l * L_current;  % L(i+1) = A_l * L(i)
    end
end

function A_l = build_A_l_matrix(N, epsilon)
% 根据论文公式(2.10)构建A_l矩阵
% N: Laguerre基函数数量
% epsilon: 时间尺度参数 (0 ≤ epsilon < 1)

    A_l = zeros(N, N);
    iota = 1 - epsilon^2;  % 根据论文定义：ι = 1 - ε²
    
    % 填充A_l矩阵
    for i = 1:N
        for j = 1:N
            if i == j
                % 对角线元素都是epsilon
                A_l(i, j) = epsilon;
            elseif i > j
                % 根据公式：A_l(i,j) = (-ε)^{i-j-1} * ι
                k = i - j - 1;  % 指数
                A_l(i, j) = ((-epsilon)^k) * iota;
            end
            % i < j的情况为0，矩阵默认就是0
        end
    end
end