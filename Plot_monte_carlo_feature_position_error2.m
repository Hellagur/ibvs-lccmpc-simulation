%% PLOT MONTE CARLO FEATURE POSITION ERROR
function fig = Plot_monte_carlo_feature_position_error2(path, total_numbers)
% Plot Monte Carlo feature position error trajectories
%
% This function visualizes feature point position error trajectories from
% multiple Monte Carlo simulations.
%
% Inputs:
%   path          - directory path to simulation files
%   total_numbers - number of Monte Carlo simulations
%
% Outputs:
%   fig - figure handle

    fig = figure('Units','inches', ...
                 'Position',[1 1 8 6], ...
                 'PaperOrientation', 'landscape');
    view(2); hold on;

    style = Plot_style();
    base_colors = style.feature;
    markerSize = 30;

    for i = 1:total_numbers
        fname   = fullfile(path, [num2str(i), '.mat']);
        data    = load(fname);
        tspan   = (0:1:data.param.Tsteps)*data.param.ts;      
        pos_err = data.hist.xs(1:8,1:data.param.Tsteps+1) - data.param.sd;
        pos_errn = zeros(4, data.param.Tsteps+1);
        for j = 1:4
            pos_errn(j,:) = vecnorm(pos_err(2*(j-1)+1:2*j,:));
        end

        for j = 1:size(pos_errn,1)
            scatter(tspan(1:5:end), pos_errn(j,1:5:end), markerSize, base_colors(j,:), 'filled', 'MarkerFaceAlpha', 0.35);
        end
    end
        plot(tspan, 1.5*ones(size(tspan)), '--', 'Color', style.neutral.threshold, 'LineWidth', 1.0);

    grid on; axis tight;
    xlabel('\fontname{宋体}时间\fontname{Times New Roman}/s', ...
           'FontSize', 14, 'Interpreter', 'tex');
    ylabel('$||\boldmath{s}_i - \boldmath{s}_{\mathrm{d},i}||_2$ (px)', ...
        'FontSize', 14, 'FontName', 'Times New Roman', 'Interpreter', 'latex');
    set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
    yscale('log');

    % Inset
    pos = get(gca, 'Position');  
    inset_scale = 0.34;
    inset_w = pos(3) * inset_scale;
    inset_h = pos(4) * inset_scale;
    inset_x = pos(1) + pos(3) - inset_w - 0.03;
    inset_y = pos(2) + pos(4) - inset_h - 0.04;
    ax_inset = axes('Position', [inset_x, inset_y, inset_w, inset_h]); 
    box on; hold on; grid(ax_inset,'on'); axis(ax_inset,'tight');
    set(ax_inset, 'FontSize', 12, 'FontName', 'Times New Roman');

    for i = 1:total_numbers
        fname   = fullfile(path, [num2str(i), '.mat']);
        data    = load(fname);
        tspan   = (0:1:data.param.Tsteps)*data.param.ts;      
        pos_err = data.hist.xs(1:8,1:data.param.Tsteps+1) - data.param.sd;
        
        zoom_duration = 50.0;
        [~, zoom_start_idx] = min(abs(tspan - (tspan(end) - zoom_duration)));
        zoom_t = tspan(zoom_start_idx:end);
        zoom_err = pos_err(:,zoom_start_idx:end);

        zoom_errn = zeros(4, length(zoom_t));
        for j = 1:4
            zoom_errn(j,:) = vecnorm(zoom_err(2*(j-1)+1:2*j,:));
        end

        for j = 1:size(zoom_errn,1)
            scatter(ax_inset, zoom_t(1:2:end), zoom_errn(j,1:2:end), markerSize, base_colors(j,:), 'filled', 'MarkerFaceAlpha', 0.35);
        end
    end
        plot(zoom_t, 1.5*ones(size(zoom_t)), '--', 'Color', style.neutral.threshold, 'LineWidth', 1.0);
    ylim([0,1.6]);
end
