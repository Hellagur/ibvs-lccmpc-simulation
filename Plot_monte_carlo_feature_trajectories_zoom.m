%% PLOT MONTE CARLO FEATURE TRAJECTORIES WITH ZOOM ON TOP-RIGHT CORNER
%
% This function plots Monte Carlo feature trajectories in image plane,
% following the exact layout style of Plot_monte_carlo_feature_trajectories3.m,
% with zoomed subfigures highlighting the top-right corner where
% constraint violations are most likely to occur.
%
% Inputs:
%   path  - directory path to simulation result files
%   N    - number of Monte Carlo simulations
%
% Outputs:
%   fig - figure handle
%
% Usage:
%   Plot_monte_carlo_feature_trajectories_zoom('path/to/data', 500);

function fig = Plot_monte_carlo_feature_trajectories_zoom(path, N)

    fig = figure('Units','inches', ...
        'Position',[1 1 8 6], ...
        'PaperOrientation', 'landscape');

    % Define positions (normalized units: [left bottom width height])
    % Align zoom subplots with main plot:
    % - above: right edge aligned with main, moved up further to avoid overlap
    % - right: top edge aligned with main, moved left closer to main
    main_pos = [0.13 0.11 0.6 0.6];  % Main plot
    above_pos = [main_pos(1) main_pos(2) + main_pos(4) + 0.06 main_pos(3) 0.15];  % Above: right aligned, moved up further
    right_pos = [main_pos(1) + main_pos(3) + 0.02 main_pos(2) + 0 0.15 main_pos(4)];  % Right: top aligned, moved left closer

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

    % Zoom coordinate limits as requested
    zoom_above_xlim = [0 640];
    zoom_above_ylim = [500 530];
    zoom_right_xlim = [630 660];
    zoom_right_ylim = [0 512];

    for i = 1:N
        fname = fullfile(path, [num2str(i), '.mat']);
        data = load(fname);
        hist = data.hist;

        % Find the first column where condition is violated
        violation_col = size(hist.xs, 2);
        for col = 1:size(hist.xs, 2)
            if any(hist.xs(1:2:7, col) > um) || any(hist.xs(2:2:8, col) > nm)
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
            if ax == ax_main
                % Main plot - plot all features
                for j = 1:4
                    scatter(hist.xs(2*(j-1)+1,1:plot_step:plot_end), hist.xs(2*j,1:plot_step:plot_end), ...
                        marker_size, base_colors(j,:), ...
                        'filled', 'MarkerFaceAlpha', 0.35);
                    plot(hist.xs(2*(j-1)+1,1:plot_end), hist.xs(2*j,1:plot_end), ...
                        'Color', base_colors(j,:));
                end
            elseif ax == ax_zoom_above
                % Zoom above (top) - plot all points that are in zoom range
                for j = 1:4
                    idx = hist.xs(2*j, 1:plot_end) >= zoom_above_ylim(1) & hist.xs(2*j, 1:plot_end) <= zoom_above_ylim(2);
                    if any(idx)
                        x_data = hist.xs(2*(j-1)+1, idx);
                        y_data = hist.xs(2*j, idx);
                        scatter(x_data, y_data, ...
                            marker_size, base_colors(j,:), ...
                            'filled', 'MarkerFaceAlpha', 0.35);
                        plot(x_data, y_data, ...
                            'Color', base_colors(j,:));
                    end
                end
            else % ax == ax_zoom_right
                % Zoom right - plot all points that are in zoom range
                for j = 1:4
                    idx = hist.xs(2*(j-1)+1, 1:plot_end) >= zoom_right_xlim(1) & hist.xs(2*(j-1)+1, 1:plot_end) <= zoom_right_xlim(2);
                    if any(idx)
                        x_data = hist.xs(2*(j-1)+1, idx);
                        y_data = hist.xs(2*j, idx);
                        scatter(x_data, y_data, ...
                            marker_size, base_colors(j,:), ...
                            'filled', 'MarkerFaceAlpha', 0.35);
                        plot(x_data, y_data, ...
                            'Color', base_colors(j,:));
                    end
                end
            end
        end
    end

    % Plot sd and boundaries on all axes
    all_axes = [ax_main, ax_zoom_above, ax_zoom_right];
    for ax = all_axes
        set(fig, 'CurrentAxes', ax);
        for j = 1:4
            % Only plot desired feature if it's inside the zoom range
            if ax == ax_zoom_above
                if param.sd(2*j) >= zoom_above_ylim(1) && param.sd(2*j) <= zoom_above_ylim(2)
                    scatter(param.sd(2*(j-1)+1), param.sd(2*j), ...
                        marker_size * 2, [255,153,102]/255, ...
                        'filled', 'Marker', 'pentagram', ...
                        'MarkerEdgeColor', 'k', ...
                        'MarkerFaceAlpha', 0.85);
                end
            elseif ax == ax_zoom_right
                if param.sd(2*(j-1)+1) >= zoom_right_xlim(1) && param.sd(2*(j-1)+1) <= zoom_right_xlim(2)
                    scatter(param.sd(2*(j-1)+1), param.sd(2*j), ...
                        marker_size * 2, [255,153,102]/255, ...
                        'filled', 'Marker', 'pentagram', ...
                        'MarkerEdgeColor', 'k', ...
                        'MarkerFaceAlpha', 0.85);
                end
            else % main plot
                scatter(param.sd(2*(j-1)+1), param.sd(2*j), ...
                    marker_size * 2, [255,153,102]/255, ...
                    'filled', 'Marker', 'pentagram', ...
                    'MarkerEdgeColor', 'k', ...
                    'MarkerFaceAlpha', 0.85);
            end
        end

        % Draw image boundary with black dashed line in all axes
        if ax == ax_main
            % Full boundary for main plot
            line([-um, um, um, -um, -um], ...
                 [-nm, -nm, nm, nm, -nm], ...
                'color', 'k', ...
                'LineStyle', '--', ...
                'LineWidth', 2.0);
        elseif ax == ax_zoom_above
            % Zoomed top: draw the top boundary at y = 512 (nm) with black dashed
            line(zoom_above_xlim, [nm nm], ...
                'color', 'k', ...
                'LineStyle', '--', ...
                'LineWidth', 2.0);
        else % ax == ax_zoom_right
            % Zoomed right: draw the right boundary at x = 640 (um) with black dashed
            line([um um], zoom_right_ylim, ...
                'color', 'k', ...
                'LineStyle', '--', ...
                'LineWidth', 2.0);
        end

        grid on;

        % === Adjust aspect ratio to zoom only the constrained direction ===
        if ax == ax_main
            axis equal;  % Main plot keep equal aspect
            xlabel('$u$ (px)', 'FontSize', 12, 'FontName', 'Times New Roman', 'Interpreter', 'latex');
            ylabel('$v$ (px)', 'FontSize', 12, 'FontName', 'Times New Roman', 'Interpreter', 'latex');
            set(gca, 'FontSize', 12, 'FontName', 'Times New Roman');
        elseif ax == ax_zoom_above
            % Zoom above: data X=0~640 (full width), Y=500~530 (small range, 30 pixels)
            % We want: X unit length same as main plot, stretch Y unit to fill the box
            axis normal;
            xlim(zoom_above_xlim);
            ylim(zoom_above_ylim);
            xticks(0:100:600);
            yticks(500:5:530);

            % Calculate pbaspect: stretch Y direction
            data_w = diff(zoom_above_xlim);   % data width  (pixels)
            data_h = diff(zoom_above_ylim);   % data height (pixels)
            box_w = above_pos(3);             % box width  (figure normalized units)
            box_h = above_pos(4);             % box height (figure normalized units)
            % Adjust stretching scale: larger = more stretching
            stretch_scale = 0.9;  % <<< ADJUST HERE: increase for more stretch, decrease for less
            pbaspect([ ((data_w/box_w) / (data_h/box_h)) * stretch_scale    1    1 ]);

            % Remove axis labels as requested
            set(gca, 'FontSize', 10, 'FontName', 'Times New Roman');
            % No xlabel and ylabel on zoom subplots
        else % ax == ax_zoom_right
            % Zoom right: data X=630~660 (small range, 30 pixels), Y=0~512 (full height)
            % We want: Y unit length same as main plot, stretch X unit to fill the box
            axis normal;
            xlim(zoom_right_xlim);
            ylim(zoom_right_ylim);
            xticks(630:5:660);
            yticks(0:100:500);

            % Calculate pbaspect: stretch X direction
            data_w = diff(zoom_right_xlim);   % data width  (pixels)
            data_h = diff(zoom_right_ylim);   % data height (pixels)
            box_w = right_pos(3);             % box width  (figure normalized units)
            box_h = right_pos(4);             % box height (figure normalized units)
            % Adjust stretching scale: larger = more stretching
            stretch_scale = 1.0;  % <<< ADJUST HERE: increase for more stretch, decrease for less
            pbaspect([ 1    ((data_h/box_h) / (data_w/box_w)) * stretch_scale    1 ]);

            % Remove axis labels as requested
            set(gca, 'FontSize', 10, 'FontName', 'Times New Roman');
            % No xlabel and ylabel on zoom subplots
        end
    end

    % Set coordinate limits - main plot already done above
    set(ax_main, 'XLim', [-um-20 um+20], 'YLim', [-nm-20 nm+20]);

    % No main title as requested
    % title(...) removed

    fprintf("failure total number = %d\n", counter);
    fprintf("constraint satisfaction rate = %.1f%%\n", (N - counter)/N * 100);

end
