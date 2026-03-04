%% PLOT MONTE CARLO FEATURE TRAJECTORIES
function fig = Plot_monte_carlo_feature_trajectories3(path, N)
% Plot Monte Carlo feature point trajectories in image plane
%
% This function visualizes feature point trajectories from multiple Monte Carlo
% simulations in the image plane, with zoomed views showing convergence behavior.
%
% Inputs:
%   path - directory path to simulation result files
%   N    - number of Monte Carlo simulations
%
% Outputs:
%   fig - figure handle

    fig = figure('Units','inches', ...
        'Position',[1 1 8 6], ...
        'PaperOrientation', 'landscape');

    % Define positions (normalized units: [left bottom width height])
    main_pos = [0.13 0.11 0.6 0.6];  % Main plot
    above_pos = [0.13 main_pos(2) + main_pos(4) + 0.05 0.6 0.15];  % Above
    right_pos = [main_pos(1) + main_pos(3) + 0.05 0.11 0.15 0.6];  % Right

    ax_main = axes('Position', main_pos);
    ax_zoom_above = axes('Position', above_pos);
    ax_zoom_right = axes('Position', right_pos);

    base_colors = [231,76,60; 46,204,113; 52,152,219; 241,196,15] ./ 255;
    marker_size = 30;
    counter = 0;


    % Load param from first file
    fname = fullfile(path, '1.mat');
    data = load(fname);
    param = data.param;
    um = param.um;
    nm = param.nm;


    zoom_delta_u = 0.08 * um;
    zoom_delta_v = 0.08 * nm;


    for i = 1:N
        fname = fullfile(path, [num2str(i), '.mat']);
        data = load(fname);
        param = data.param;
        hist = data.hist;


        % Find the first column where condition is violated
        violation_col = size(hist.xs, 2);
        for col = 1:size(hist.xs, 2)
            if any(abs(hist.xs(1:2:7, col)) > param.um) || any(abs(hist.xs(2:2:8, col)) > param.nm)
                violation_col = col;
                break;
            end
        end


        is_failure = violation_col < size(hist.xs, 2);


        if is_failure
            fprintf("[%d] failure.\n", i);
            counter = counter + 1;
            plot_end = violation_col+1;
            plot_step = 1;
            if plot_end < 1
                plot_end = 1;
            end
            axes_list = [ax_main, ax_zoom_above, ax_zoom_right];
        else
            plot_end = size(hist.xs, 2);
            plot_step = 1;
            axes_list = [ax_main, ax_zoom_above, ax_zoom_right];
        end


        for ax = axes_list
            set(fig, 'CurrentAxes', ax);
            hold on;
            for j = 1:4
                scatter(hist.xs(2*(j-1)+1,1:plot_step:plot_end), hist.xs(2*j,1:plot_step:plot_end), ...
                    marker_size, base_colors(j,:), ...
                    'filled', 'MarkerFaceAlpha', 0.35);
                plot(hist.xs(2*(j-1)+1,1:plot_end), hist.xs(2*j,1:plot_end), ...
                    'Color', base_colors(j,:));
            end
        end
    end


    % Plot sd and boundaries on all axes
    all_axes = [ax_main, ax_zoom_above, ax_zoom_right];
    for ax = all_axes
        set(fig, 'CurrentAxes', ax);
        for j = 1:4
            scatter(param.sd(2*(j-1)+1), param.sd(2*j), ...
                marker_size, [255,153,102]/255, ...
                'filled', 'Marker', 'pentagram', ...
                'MarkerEdgeColor', 'k', ...
                'MarkerFaceAlpha', 0.85);
        end
        line([um, um, -um, -um, um], ...
             [-nm, nm, nm, -nm, -nm], ...
            'color', 'k', ...
            'LineStyle', '--', ...
            'LineWidth', 2.0);
        grid on; axis equal;
        xlabel('$u$ (px)', 'FontSize', 12, 'FontName', 'Times New Roman', 'Interpreter', 'latex');
        ylabel('$v$ (px)', 'FontSize', 12, 'FontName', 'Times New Roman', 'Interpreter', 'latex');
        set(gca, 'FontSize', 12, 'FontName', 'Times New Roman');
    end


    % Set zoom limits
    set(ax_zoom_above, 'XLim', [-um um], 'YLim', [nm - zoom_delta_v nm + zoom_delta_v]);
    set(ax_zoom_right, 'XLim', [um - zoom_delta_u um + zoom_delta_u], 'YLim', [-nm nm]);


    fprintf("failure total number = %d\n", counter);
end
