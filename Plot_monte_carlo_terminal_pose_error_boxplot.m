%% PLOT MONTE CARLO TERMINAL POSE ERROR BOXPLOT
function Plot_monte_carlo_terminal_pose_error_boxplot(path, total_numbers)
% Plot boxplot of terminal relative pose errors
%
% This function visualizes the distribution of terminal position and attitude
% errors from Monte Carlo simulations using boxplots.
%
% Inputs:
%   path          - directory path to simulation files
%   total_numbers - number of simulation files
%
% Outputs:
%   None (displays figure)

    style = Plot_style();
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
    
    figure('Units','inches','Position',[1 1 8 6]);
    tiledlayout(2,1, 'TileSpacing', 'compact');
    
    % Position errors
    nexttile;
    hold on;
    pos_errors = errors(1:3, :)';
    boxplot(pos_errors, ...
        'Labels', {'$$x$$', '$$y$$', '$$z$$'}, ...
        'Whisker', 1.5, 'Widths', 0.6);
    cmap_pos = repmat(style.state.poseBox, 3, 1);
    boxes = findobj(gca,'Tag','Box');
    for j = 1:length(boxes)
        patch(get(boxes(j),'XData'), get(boxes(j),'YData'), cmap_pos(j,:), ...
            'FaceAlpha', 0.3, 'EdgeColor', cmap_pos(j,:), 'LineWidth', 1.2);
    end
    set(findobj(gca,'Tag','Whisker'), 'Color', style.state.boxWhisker, 'LineWidth',1.5);
    set(findobj(gca,'Tag','Median'), 'Color', style.state.boxMedian, 'LineWidth',1.5);
    set(findobj(gca,'Tag','Outliers'), 'Marker','x', ...
        'MarkerEdgeColor', style.alert, 'LineWidth', 1.0);
    ylabel('$||\boldmath{\rho}_{\mathrm{CT}}(t_f)-\boldmath{\rho}_{\mathrm{CT}}^*||_2$ (m)', ...
           'FontSize', 14, 'FontName', 'Times New Roman', 'Interpreter','latex');
    set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 14, 'FontName', 'Times New Roman');
    grid on; box off;
    ylim([-0.0155, 0.0155]);
    ax = gca;
    ax.YAxis.Exponent = -2;
    ax.YAxis.TickLabelFormat = '%.0f';
    
    % Attitude errors
    nexttile;
    hold on; box off;
    ylim([-1e-4, 1e-4]);
    att_errors = errors(4:6, :)';
    boxplot(att_errors, ...
        'Labels', {'$$\sigma_{\mathrm{CL},1}$$', '$$\sigma_{\mathrm{CL},2}$$', '$$\sigma_{\mathrm{CL},3}$$'}, ...
        'Whisker', 1.5, 'Widths', 0.6);
    cmap_att = repmat(style.state.attBox, 3, 1);
    boxes = findobj(gca,'Tag','Box');
    for j = 1:length(boxes)
        patch(get(boxes(j),'XData'), get(boxes(j),'YData'), cmap_att(j,:), ...
            'FaceAlpha', 0.3, 'EdgeColor', cmap_att(j,:), 'LineWidth', 1.2);
    end
    set(findobj(gca,'Tag','Whisker'), 'Color', style.state.boxWhisker, 'LineWidth',1.5);
    set(findobj(gca,'Tag','Median'), 'Color', style.state.boxMedian, 'LineWidth',1.5);
    set(findobj(gca,'Tag','Outliers'), 'Marker','x', ...
        'MarkerEdgeColor', style.alert, 'LineWidth', 1.0);
    ylabel('$||\boldmath{\sigma}_{\mathrm{CL}}(t_\mathrm{f})||_2$ (MRPs)', ...
           'FontSize', 14, 'FontName', 'Times New Roman', 'Interpreter', 'latex');
    set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 14, 'FontName', 'Times New Roman');
    grid on;

    % Legend
    h1 = plot(NaN,NaN,'s',...
    'Color',style.state.poseBox,...
    'MarkerFaceColor',style.state.poseBox,...
    'MarkerSize',10,...
    'DisplayName',...
    '\fontname{宋体}四分位区间\fontname{Times New Roman} (Q1-Q3)');

    h2 = plot(NaN,NaN,'-',...
        'Color',style.state.boxMedian,...
        'LineWidth',1.5,...
        'DisplayName',...
        '\fontname{宋体}中位数\fontname{Times New Roman} (Q2)');
    
    h3 = plot(NaN,NaN,'-',...
        'Color',style.state.boxWhisker,...
        'LineWidth',1.5,...
        'DisplayName',...
        '\fontname{宋体}须线');
    
    h4 = plot(NaN,NaN,'x',...
        'Color',style.alert,...
        'MarkerSize',8,...
        'LineWidth',1.0,...
        'DisplayName',...
        '\fontname{宋体}离群点');
    
    lgd = legend([h1,h2,h3,h4],...
        'Location','northeast',...
        'Orientation','vertical',...
        'FontSize',10,...
        'Box','on');
    
    lgd.Interpreter = 'tex';

    % Print error report
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
