function Plot_monte_carlo_accumulated_energy3D(path1, path2, path3, N)
    % 计算每个方法的累积能量
    energy1 = zeros(1, N);
    energy2 = zeros(1, N);
    energy3 = zeros(1, N);
    for i = 1:N
        % 方法1
        data1 = load(fullfile(path1, [num2str(i), '.mat']));
        hist1 = data1.hist;
        u1 = hist1.uT;
        sum1 = 0;
        for j = 1:size(u1, 2)
            sum1 = sum1 + norm(u1(:,j));
        end
        energy1(i) = sum1;
        % 方法2
        data2 = load(fullfile(path2, [num2str(i), '.mat']));
        hist2 = data2.hist;
        u2 = hist2.uT;
        sum2 = 0;
        for j = 1:size(u2, 2)
            sum2 = sum2 + norm(u2(:,j));
        end
        energy2(i) = sum2;
        % 方法3
        data3 = load(fullfile(path3, [num2str(i), '.mat']));
        hist3 = data3.hist;
        u3 = hist3.uT;
        sum3 = 0;
        for j = 1:size(u3, 2)
            sum3 = sum3 + norm(u3(:,j));
        end
        energy3(i) = sum3;
    end
    % 确定统一的bins（基于所有能量范围）
    all_energy = [energy1, energy2, energy3];
    min_e = min(all_energy);
    max_e = max(all_energy);
    num_bins = 10; % 可调整bin数量
    edges = linspace(min_e, max_e, num_bins + 1);
    centers = (edges(1:end-1) + edges(2:end)) / 2; % bin中心作为x
    % 计算每个方法的histogram频数
    count1 = histcounts(energy1, edges);
    count2 = histcounts(energy2, edges);
    count3 = histcounts(energy3, edges);
    % 3D数据：y=方法1,2,3；x=bin中心；z=频数
    y = [1, 4, 7]; % 方法标签，拉宽距离（间隔3，可调整）
    z = [count1; count2; count3]; % 3行 (方法) x num_bins列
    % 绘制3D bar图
    figure('Units','inches', ...
           'Position',[1 1 12 6], ...
           'PaperOrientation', 'landscape');
    bar3(y, z);
    xlabel('$$\sum || \boldmath{u} ||_2$$', 'FontSize', 12, 'Interpreter','latex');
    zlabel('$$N$$', 'FontSize', 12, 'Interpreter','latex');
    yticks(y);
    yticklabels({'$$\boldmath{u}$$', '$$\Delta \boldmath{u}$$', '$$\boldmath{\eta}$$'});
    xticks(1:length(centers));
    xticklabels(arrayfun(@(x) sprintf('%.1f', x), centers, 'UniformOutput', false));
    set(gca, 'TickLabelInterpreter', 'latex', ...
        'FontName', 'Times New Roman', 'FontSize', 12);
end