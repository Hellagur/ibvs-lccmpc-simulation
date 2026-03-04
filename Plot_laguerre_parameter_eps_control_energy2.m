%% PLOT LAGUERRE PARAMETER EPS CONTROL ENERGY
function Plot_laguerre_parameter_eps_control_energy2(file_path, file_name, nl_eps, steps)
% Plot control energy vs time for different Laguerre parameters
%
% This function creates a tiled subplot showing accumulated control energy
% trajectories for different combinations of Laguerre basis functions (Nl)
% and time scaling parameters (epsilon).
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
        
        local_min = Inf;
        local_max = -Inf;
        
        for i = 1:size(nl_subset,1)
            fname = fullfile(file_path, file_name(nl_subset(i,1), nl_subset(i,2)));
            data = load(fname);
            hist = data.hist;
            error = vecnorm(hist.xs(1:8,1:steps) - data.param.sd);
            if error(end) > 10
                continue;
            end
            u = hist.uT(:,1:steps);
            energy = cumsum(vecnorm(u));
            plot(tspan, energy, 'Color', colors(i,:), 'LineWidth', 1.5);
            
            % Update global and local ranges
            local_min = min(local_min, min(energy));
            local_max = max(local_max, max(energy));
            global_min = min(global_min, min(energy));
            global_max = max(global_max, max(energy));
        end

        % Highlight nl=3, eps=0.9 (only in nl=3 subplot)
        if nl_val == 3
            fname = fullfile(file_path, file_name(3, 0.9));
            data = load(fname);
            hist = data.hist;
            u = hist.uT(:,1:steps);
            energy = cumsum(vecnorm(u));
            h = plot(tspan, energy, 'm', 'LineWidth', 2.0, 'DisplayName', '$$\epsilon = 0.9$$');
            legend(h, 'Interpreter','latex', 'FontSize',10, 'Location', 'southeast');
        end
        
        grid on; axis tight;
        xlabel('Time (s)', 'Interpreter','latex', 'FontSize',12);
        ylabel('$$\sum || \mathbf{u} ||_2$$', 'Interpreter','latex', 'FontSize',12);
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
