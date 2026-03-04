%% PLOT FEATURE ERROR TRAJECTORY
function fig = Plot_feature_error_trajectory(param, hist, k)
% Plot feature point error trajectories in pixel domain
%
% This function visualizes the tracking error of feature points in the image
% plane over time. Errors are computed as the Euclidean distance between
% actual and desired feature positions.
%
% Inputs:
%   param - structure containing image plane parameters (um, nm, sd)
%   hist  - structure containing feature state history (xs)
%   k     - current time step index
%
% Outputs:
%   fig   - figure handle

    fig = figure('Units','inches','Position',[1 1 8 6]);
    tspan = (0:1:k)*param.ts;
    
    % --- Data preprocessing ---
    err = hist.xs(1:8,:) - param.sd;
    errn = zeros(4, size(err,2));
    for j = 1:4
        errn(j,:) = sqrt(err(2*(j-1)+1,:).^2 + err(2*j,:).^2);
    end


    base_colors = [231, 76, 60; 46, 204, 113; 52, 152, 219; 241, 196, 15] / 255;
    markerSize = 30;

    % --- Main plot ---
    ax_main = gca;
    hold(ax_main, 'on');
    for idx = 1:4
        % Draw gradient points (for performance, simplify if too many points)
        for i = 1:2:length(tspan) % Plot every 5th point to avoid lag
            color_factor = 0.3 + 0.7*(i-1)/(length(tspan)-1);
            c_rgb = base_colors(idx,:) * color_factor + (1-color_factor)*[1 1 1];
            scatter(ax_main, tspan(i), errn(idx,i), markerSize, c_rgb, 'filled', 'MarkerFaceAlpha', 0.6);
        end
        plot(ax_main, tspan, errn(idx,:), '-', 'Color', base_colors(idx,:), 'LineWidth', 1.5);
    end
    plot(ax_main, tspan, 1.5*ones(length(tspan)), '--', 'Color', '#666666', 'LineWidth', 1.0);
    grid on; box on;
    set(gca, 'YScale', 'log', 'FontSize', 11, 'FontName', 'Times New Roman');
    xlabel('Time (s)'); ylabel('$||\boldmat{s}_i - \boldmat{s}_{d,i}||_2$', 'Interpreter','latex');

    h1 = scatter(NaN, NaN, markerSize, base_colors(1,:), 'filled', 'MarkerFaceAlpha', 0.6);
    h2 = scatter(NaN, NaN, markerSize, base_colors(2,:), 'filled', 'MarkerFaceAlpha', 0.6);
    h3 = scatter(NaN, NaN, markerSize, base_colors(3,:), 'filled', 'MarkerFaceAlpha', 0.6);
    h4 = scatter(NaN, NaN, markerSize, base_colors(4,:), 'filled', 'MarkerFaceAlpha', 0.6);

    legend([h1,h2,h3,h4], 'Feature 1', 'Feature 2', 'Feature 3', 'Feature 4', ...
            'FontSize', 10, 'Interpreter', 'latex', 'Location', 'best');

    % --- Subplot (Inset) ---
    zoom_duration = 50.0; 
    zoom_start_idx = find(tspan >= (tspan(end) - zoom_duration), 1);
    zoom_t = tspan(zoom_start_idx:end);
    zoom_err = errn(:, zoom_start_idx:end);
    
    % Automatically calculate inset position: upper right corner
    main_pos = get(ax_main, 'Position');
    inset_scale = 0.35;
    ax_inset = axes('Position', [main_pos(1)+main_pos(3)*(1-inset_scale)-0.22, ...
                                 main_pos(2)+main_pos(4)*(1-inset_scale)-0.03, ...
                                 main_pos(3)*inset_scale, ...
                                 main_pos(4)*inset_scale]);
    hold(ax_inset, 'on'); box on;


    for idx = 1:4
        % Fix: color gradient ratio should be recalculated for inset
        curr_zoom_err = zoom_err(idx, :);
        for i = 1:length(zoom_t)
            % Map color ratio back to original time axis for visual consistency
            global_idx = zoom_start_idx + i - 1;
            color_factor = 0.3 + 0.7*(global_idx-1)/(length(tspan)-1);
            c_rgb = base_colors(idx,:) * color_factor + (1-color_factor)*[1 1 1];
            scatter(ax_inset, zoom_t(i), curr_zoom_err(i), markerSize/2, c_rgb, 'filled');
        end
        % Fix: plot with correct row vector
        plot(ax_inset, zoom_t, curr_zoom_err, '-', 'Color', base_colors(idx,:), 'LineWidth', 1.0);
    end
    plot(ax_inset, zoom_t, 1.5*ones(length(zoom_t)), '--', 'Color', '#666666', 'LineWidth', 1.0);
    grid(ax_inset, 'on');
    set(ax_inset, 'FontSize', 9, 'FontName', 'Times New Roman');
    % Inset usually not recommended for log axis unless error span is huge
    axis(ax_inset, 'tight'); 
    ylim([0,1.6]);
end
