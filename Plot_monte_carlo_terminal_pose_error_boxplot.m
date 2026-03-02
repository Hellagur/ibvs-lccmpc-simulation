function Plot_monte_carlo_terminal_pose_error_boxplot(path, total_numbers)
    errors = zeros(6, total_numbers);
    for i = 1:total_numbers
        fname = fullfile(path, [num2str(i), '.mat']);
        data = load(fname);
        param = data.param;
        hist = data.hist;
        R_tl = hist.R_ti{param.Tsteps+1} * hist.R_li{param.Tsteps+1}';
        R_ts = hist.R_ti{param.Tsteps+1} * hist.R_si{param.Tsteps+1}';
        r_ct_t = R_tl * hist.xl(7:9,param.Tsteps+1) + R_ts * param.r_sc;
        R_ct = hist.R_ci{param.Tsteps+1} * hist.R_ti{param.Tsteps+1}';
        s_ct = dcm2mrp(R_ct);
        errors(:,i) = [r_ct_t - [0;0;-5]; s_ct];
    end
    
    % === 绘图部分 ===
    fig = figure('Units','inches','Position',[1 1 8 6]);
    tiledlayout(2,1, 'TileSpacing', 'compact');
    
    % 子图1: 位置误差 (x_T, y_T, z_T)
    nexttile;
    hold on;
    pos_errors = errors(1:3, :)';  % 转置为箱线图输入
    h_pos = boxplot(pos_errors, ...
        'Labels', {'$$x$$', '$$y$$', '$$z$$'}, ...
        'Whisker', 1.5, 'Widths', 0.6);
    cmap_pos = [0.3 0.7 1.0; 0.3 0.7 1.0; 0.3 0.7 1.0];
    boxes = findobj(gca,'Tag','Box');
    for j = 1:length(boxes)
        patch(get(boxes(j),'XData'), get(boxes(j),'YData'), cmap_pos(j,:), ...
            'FaceAlpha', 0.3, 'EdgeColor', cmap_pos(j,:), 'LineWidth', 1.2);
    end
    set(findobj(gca,'Tag','Whisker'), 'LineWidth',1.5);
    set(findobj(gca,'Tag','Median'), 'Color','r', 'LineWidth',1.5);
    set(findobj(gca,'Tag','Outliers'), 'Marker','x', ...
        'MarkerEdgeColor','r', 'LineWidth', 1.0);
    ylabel('$||\boldmath{\rho}_{CT}(t_f)-\boldmath{\rho}_{CT}^*||_2$ (m)', 'FontSize', 12, 'FontName', 'Times New Roman', 'Interpreter','latex');
    set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 12, 'FontName', 'Times New Roman');
    grid on; box off;
    % title('Relative Position Error', 'Interpreter', 'latex', 'FontSize', 14);
    ylim([-0.0155, 0.0155]);
    ax = gca;
    % 设置 y 轴指数为 -3（即 ×10^{-3}），并显示在轴顶部
    ax.YAxis.Exponent = -2;
    
    % 设置 y 轴刻度标签格式为整数（%.0f 表示无小数位）
    ax.YAxis.TickLabelFormat = '%.0f';
    
    % 子图2: 姿态误差 (σ_CL,1, σ_CL,2, σ_CL,3)
    nexttile;
    hold on; box off;
    ylim([-1e-4, 1e-4]);
    att_errors = errors(4:6, :)';  % 转置为箱线图输入
    h_att = boxplot(att_errors, ...
        'Labels', {'$$\sigma_{CL,1}$$', '$$\sigma_{CL,2}$$', '$$\sigma_{CL,3}$$'}, ...
        'Whisker', 1.5, 'Widths', 0.6);
    cmap_att = [0.4 0.8 0.8; 0.4 0.8 0.8; 0.4 0.8 0.8];
    boxes = findobj(gca,'Tag','Box');
    for j = 1:length(boxes)
        patch(get(boxes(j),'XData'), get(boxes(j),'YData'), cmap_att(j,:), ...
            'FaceAlpha', 0.3, 'EdgeColor', cmap_att(j,:), 'LineWidth', 1.2);
    end
    set(findobj(gca,'Tag','Whisker'), 'LineWidth',1.5);
    set(findobj(gca,'Tag','Median'), 'Color','r', 'LineWidth',1.5);
    set(findobj(gca,'Tag','Outliers'), 'Marker','x', ...
        'MarkerEdgeColor','r', 'LineWidth', 1.0);
    ylabel('$||\boldmath{\sigma}_{CL}(t_f)||_2$ (MRPs)', 'FontSize', 12, 'FontName', 'Times New Roman', 'Interpreter', 'latex');
    set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 12, 'FontName', 'Times New Roman');
    grid on;
    % title('Relative Attitude Error (MRPs)', 'Interpreter', 'latex', 'FontSize', 14);

    % 共享图例（放置在figure外部或一个子图中）
    h1 = plot(NaN,NaN,'s','Color',[0.3 0.7 1.0],'MarkerFaceColor',[0.3 0.7 1.0],...
        'MarkerSize',10,'DisplayName','Q1–Q3 (Box)');
    h2 = plot(NaN,NaN,'-r','LineWidth',1.5,'DisplayName','Median (Q2)');
    h3 = plot(NaN,NaN,'-k','LineWidth',1.5,'DisplayName','Whiskers');
    h4 = plot(NaN,NaN,'xr','MarkerSize',8,'DisplayName','Outliers','LineWidth',1.0);
    legend([h1,h2,h3,h4], 'Location','northeastoutside', ...
        'Orientation','vertical','FontSize',10,'Box','on');
    
    % 输出均值和中位数到命令行（分开位置和姿态）
    fprintf('Terminal Position Errors:\n');
    pos_mean = mean(errors(1:3,:), 2);
    pos_median = median(errors(1:3,:), 2);
    for i = 1:3
        fprintf('Position %d mean error = %.6f m\n', i, pos_mean(i));
        fprintf('Position %d median error = %.6f m\n', i, pos_median(i));
    end
    
    fprintf('\nTerminal Attitude Errors (MRPs):\n');
    att_mean = mean(errors(4:6,:), 2);
    att_median = median(errors(4:6,:), 2);
    for i = 1:3
        fprintf('Attitude %d mean error = %.6f\n', i, att_mean(i));
        fprintf('Attitude %d median error = %.6f\n', i, att_median(i));
    end
end