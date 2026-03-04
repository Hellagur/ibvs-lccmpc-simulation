%% PLOT FEATURE STATES TRAJECTORY
function Plot_feature_states_trajectory(param, hist, k, saveFig)
% Plot feature point trajectories in image plane
%
% This function visualizes the trajectories of feature points in the image plane
% over time, showing initial, final, and desired positions.
%
% Inputs:
%   param   - structure containing image plane parameters (um, nm, sd, ts)
%   hist    - structure containing feature state history (xs)
%   k       - current time step index
%   saveFig - boolean, whether to save figure as PDF
%
% Outputs:
%   None (displays figure)

    fig = figure('Units','inches','Position',[1 1 8 6]);

    % Background grid
    step = 20;
    x_range = -param.um:step:param.um;
    y_range = -param.nm:step:param.nm;
    hold on;
    
    for y = y_range
        line([-param.um, param.um], [y, y], 'Color', [0.85 0.85 0.85], 'LineWidth', 0.6);
    end
    for x = x_range
        line([x, x], [-param.nm, param.nm], 'Color', [0.85 0.85 0.85], 'LineWidth', 0.6);
    end
    
    set(gca, 'Color', [0.99 0.99 0.99]);  
    box on;
    
    line([0 0], [-param.nm, param.nm], 'Color', [0.4 0.4 0.4], 'LineStyle', ':');
    line([-param.um, param.um], [0 0], 'Color', [0.4 0.4 0.4], 'LineStyle', ':');

    line('XData', [param.sd(1:2:7);param.sd(1)], ...
         'YData', [param.sd(2:2:8);param.sd(2)], ...
         'LineStyle','--','LineWidth',1.5);

    base_colors = [231, 76,  60; 46,  204, 113; 52, 152, 219; 241, 196, 15] / 255;

    markerSize = 50;
    for idx = 1:4
        xs_idx = hist.xs(2*idx-1,:);
        ys_idx = hist.xs(2*idx,:);
        for i = 1:k
            color = 0.3 + 0.7*(i-1)/(k-1);
            c_rgb = base_colors(idx,:) * color + (1-color)*[1 1 1]; 
            scatter(xs_idx(i), ys_idx(i), markerSize, c_rgb, 'filled'); hold on;
        end
        plot(xs_idx, ys_idx, '-', 'Color', base_colors(idx,:), 'LineWidth', 1.0);
    end

    %% ---- Plot line ----
    num = 1024;
    gamma = 0.5;
    map = turbo(num);
    idx = round(1 + (num-1) * linspace(0,1,k).^gamma);
    colors_l = map(idx, :);
    
    for i = 1:k
        line(hist.xs([1,3,5,7,1],i), hist.xs([2,4,6,8,2],i), ...
            'Color', colors_l(i,:), ...
            'LineStyle', '-', ...
            'LineWidth', 1.0);
    end

    %% ---- Plot desired positions ----
    for i = 1:4
        p0 = plot(param.sd(2*i-1), param.sd(2*i), 'p', ...
             'MarkerFaceColor','#FF9966','MarkerEdgeColor','k','MarkerSize',11);
    end
    
    %% ---- Plot initial positions ----
    for i = 1:4
        p2 = plot(hist.xs(2*i-1,1), hist.xs(2*i,1), 'o', ...
             'MarkerFaceColor','none','MarkerEdgeColor','r','MarkerSize',6,'LineWidth',1.5);
    end
    
    %% ---- Plot final positions ----
    for i = 1:4
        p3 = plot(hist.xs(2*i-1,k), hist.xs(2*i,k), 'o', ...
             'MarkerFaceColor','none','MarkerEdgeColor','g','MarkerSize',6,'LineWidth',1.5);
    end

    axis equal;
    xlim([-param.um, param.um]);
    ylim([-param.nm, param.nm]);
    xlabel('$u\ (\rm{px})$', 'FontSize',12,'FontName','Times New Roman','Interpreter','latex');
    ylabel('$v\ (\rm{px})$', 'FontSize',12,'FontName','Times New Roman','Interpreter','latex');
    set(gca,'FontSize',12,'FontName','Times New Roman');

    legend([p3, p2, p0], {'Final Position','Initial Position','Target Position'}, ...
           'FontSize',12,'FontName','Times New Roman','Location','northeast');

    if saveFig
        set(gcf, 'PaperPositionMode','auto');
        set(gcf, 'Renderer','painters');
        figure_name = strcat('figs/feature_states_trajectory_duration=', num2str(k*param.ts), 's');
        print(fig, figure_name, '-dpdf', '-r600');
    end
end
