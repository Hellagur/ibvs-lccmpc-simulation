function Plot_monte_carlo_terminal_image_error_boxplot2(path, total_numbers)
    errors = zeros(4, total_numbers);
    for i = 1:total_numbers
        fname = fullfile(path, [num2str(i), '.mat']);
        data = load(fname);
        param = data.param;
        hist = data.hist;
        pos_err = hist.xs(1:8,param.Tsteps+1) - param.sd;
        for j = 1:size(errors,1)
            errors(j,i) = norm(pos_err(2*(j-1)+1:2*j));
        end
    end
    % === 绘图部分 ===
    fig = figure('Units','inches','Position',[1 1 8 6]); hold on;
    h   = boxplot(errors', ...
        'Labels', {'','','',''}, ...  % 隐藏原单个标签
        'Whisker', 1.5, 'Widths', 0.6);

    cmap = [0.2 0.5 0.8;
            0.3 0.7 1.0;
            0.4 0.9 0.8;
            0.2 0.7 0.6];
    
    boxes = findobj(gca,'Tag','Box');
    for j = 1:length(boxes)
        patch(get(boxes(j),'XData'), get(boxes(j),'YData'), cmap(j,:), ...
            'FaceAlpha', 0.3, 'EdgeColor', cmap(j,:), 'LineWidth', 1.2);
    end
    set(findobj(gca,'Tag','Whisker'), 'LineWidth',1.5);
    set(findobj(gca,'Tag','Median'), 'Color','r', 'LineWidth',1.5);
    set(findobj(gca,'Tag','Outliers'), 'Marker','x', ...
        'MarkerEdgeColor','r', 'LineWidth', 1.0);
    ylabel('$||\boldmath{s}_i(t_f) - \boldmath{s}_{d,i}||_2$ (px)', ...
        'FontSize', 12, 'FontName', 'Times New Roman', 'Interpreter', 'latex');
    set(gca, 'FontSize', 12, 'FontName', 'Times New Roman');
    grid on; box off;
    h1 = plot(NaN,NaN,'s','Color',[0.3 0.7 1.0],'MarkerFaceColor',[0.3 0.7 1.0],...
        'MarkerSize',10,'DisplayName','Q1–Q3 (Box)');
    h2 = plot(NaN,NaN,'-r','LineWidth',1.5,'DisplayName','Median (Q2)');
    h3 = plot(NaN,NaN,'-k','LineWidth',1.5,'DisplayName','Whiskers');
    h4 = plot(NaN,NaN,'xr','MarkerSize',8,'DisplayName','Outliers','LineWidth',1.0);
    legend([h1,h2,h3,h4], 'Location','northeast', ...
        'Orientation','vertical','FontSize',10,'Box','on');
    
    % 添加分组横坐标标签（内部放置在x轴下方）
    y_limits = ylim;  % 获取当前y轴范围
    label_y_pos = y_limits(1) - 0.05 * (y_limits(2) - y_limits(1));  % 放置在y轴底部下方5%
    text(1, label_y_pos, '$$(u_1, v_1)$$', 'HorizontalAlignment', 'center', 'Interpreter', 'latex', 'FontSize', 12);
    text(2, label_y_pos, '$$(u_2, v_2)$$', 'HorizontalAlignment', 'center', 'Interpreter', 'latex', 'FontSize', 12);
    text(3, label_y_pos, '$$(u_3, v_3)$$', 'HorizontalAlignment', 'center', 'Interpreter', 'latex', 'FontSize', 12);
    text(4, label_y_pos, '$$(u_4, v_4)$$', 'HorizontalAlignment', 'center', 'Interpreter', 'latex', 'FontSize', 12);
    
    % 输出均值到命令行
    num_features = size(errors,1);
    mean_errors = mean(errors, 2);
    median_errors = median(errors, 2);
    for i = 1:num_features
        fprintf('Feature %d mean error = %.4f px\n', i, mean_errors(i));
    end
    for i = 1:num_features
        fprintf('Feature %d median error = %.4f px\n', i, median_errors(i));
    end
end