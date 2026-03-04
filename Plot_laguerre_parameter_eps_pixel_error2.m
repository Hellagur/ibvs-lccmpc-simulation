%% PLOT LAGUERRE PARAMETER EPS PIXEL ERROR
function Plot_laguerre_parameter_eps_pixel_error2(file_path, file_name, nl_eps, steps)
% Plot pixel error vs time for different Laguerre parameters
%
% This function creates a tiled subplot showing pixel error trajectories
% for different combinations of Laguerre basis functions (Nl) and 
% time scaling parameters (epsilon).
%
% Inputs:
%   file_path  - directory path to simulation files
%   file_name  - function for generating filename
%   nl_eps     - matrix of [Nl, epsilon] pairs
%   steps      - number of time steps to plot

    unique_nl = unique(nl_eps(:,1));
    tspan = 0:0.5:(steps-1)*0.5;
    figure('Units','inches', 'Position', [1 1 12 10]);
    tiledlayout(3,3, 'TileSpacing','compact');
    
    global_min = Inf;
    global_max = -Inf;
    
    ax_handles = gobjects(length(unique_nl), 1);
    
    for k = 1:length(unique_nl)
        nl_val = unique_nl(k);
        idx_nl = nl_eps(:,1) == nl_val;
        nl_subset = nl_eps(idx_nl,:);
        colors = parula(size(nl_subset,1));
        ax = nexttile;
        ax_handles(k) = ax;
        hold on;
        
        % Calculate data range for current subplot
        local_min = Inf;
        local_max = -Inf;
        
        for i = 1:size(nl_subset,1)
            fname = fullfile(file_path, file_name(nl_subset(i,1), nl_subset(i,2)));
            data = load(fname);
            param = data.param;
            hist = data.hist;
            error = vecnorm(hist.xs(1:8,1:steps) - param.sd);
            if error(end) > 10
                disp(['N_l=', num2str(nl_subset(i,1)), ', eps=', num2str(nl_subset(i,2)), ' failed.']);
                continue;
            end
            plot(tspan, error, 'Color', colors(i,:), 'LineWidth', 1.5);
            
            % Update global and local ranges
            local_min = min(local_min, min(error));
            local_max = max(local_max, max(error));
            global_min = min(global_min, min(error));
            global_max = max(global_max, max(error));
        end
        
        % Highlight nl=3, eps=0.9 (only in nl=3 subplot)
        if nl_val == 3
            fname = fullfile(file_path, file_name(3, 0.9));
            data = load(fname);
            param = data.param;
            hist = data.hist;
            error = vecnorm(hist.xs(1:8,1:steps) - param.sd);
            h = plot(tspan, error, 'm', 'LineWidth', 2.0, 'DisplayName', '$$\epsilon = 0.9$$');
            legend(h, 'Interpreter','latex', 'FontSize',10, 'Location', 'northeast');
        end
        
        set(gca, 'YScale','log');
        grid on; axis tight;
        xlabel('Time (s)', 'Interpreter','latex', 'FontSize',12);
        ylabel('$$\|\mathbf{s}-\mathbf{s}_d\|_2$$', 'Interpreter','latex', 'FontSize',12);
        set(gca,'FontName','Times New Roman','FontSize',12);
        
        % Add colorbar (for eps)
        cb = colorbar('FontSize',12);
        cb.Label.String = '$$\epsilon$$';
        cb.Label.Interpreter = 'latex';
        clim([min(nl_subset(:,2)), max(nl_subset(:,2))]);
        
        % Add internal title (using text, normalized position: top-left)
        text(0.05, 0.95, ['$$N_l = ', num2str(nl_val), '$$'], ...
             'Units', 'normalized', 'Interpreter','latex', ...
             'FontSize',10, 'FontWeight','bold');
    end
    
    if global_min <= 0
        global_min = 1e-6;
    end
    set(ax_handles, 'YLim', [global_min, global_max]);
end
