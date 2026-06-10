%% PLOT LAGUERRE PARAMETER EPS PIXEL ERROR
function Plot_laguerre_parameter_eps_pixel_error2(file_path, file_name, nl_eps, steps)
% Plot pixel error vs time for different Laguerre parameters
%
% Inputs:
%   file_path  - directory path to simulation files
%   file_name  - function for generating filename
%   nl_eps     - matrix of [Nl, epsilon] pairs
%   steps      - number of time steps to plot

    style = Plot_style();
    unique_nl = unique(nl_eps(:,1));

    tspan = 0:0.5:(steps-1)*0.5;

    figure('Units','inches','Position',[1 1 16 9]);

    tiledlayout(3,3,'TileSpacing','compact');

    global_min = Inf;
    global_max = -Inf;

    ax_handles = gobjects(length(unique_nl),1);

    nrows = 3;
    ncols = 3;

    for k = 1:length(unique_nl)

        nl_val = unique_nl(k);

        idx_nl = nl_eps(:,1) == nl_val;
        nl_subset = nl_eps(idx_nl,:);

        colors = style.cmap(size(nl_subset,1));

        ax = nexttile;
        ax_handles(k) = ax;
        colormap(ax, style.cmap(256));

        hold(ax,'on');

        local_min = Inf;
        local_max = -Inf;

        for i = 1:size(nl_subset,1)

            fname = fullfile(file_path,...
                file_name(nl_subset(i,1),nl_subset(i,2)));

            data = load(fname);

            param = data.param;
            hist  = data.hist;

            error = vecnorm(hist.xs(1:8,1:steps) - param.sd);

            if error(end) > 10
                disp(['N_l=',num2str(nl_subset(i,1)),...
                      ', eps=',num2str(nl_subset(i,2)),...
                      ' failed.']);
                continue;
            end

            plot(ax,tspan,error,...
                'Color',colors(i,:),...
                'LineWidth',1.5);

            local_min = min(local_min,min(error));
            local_max = max(local_max,max(error));

            global_min = min(global_min,min(error));
            global_max = max(global_max,max(error));

        end

        %% Highlight reference case
        if nl_val == 3

            fname = fullfile(file_path,file_name(3,0.9));

            data = load(fname);

            param = data.param;
            hist  = data.hist;

            error = vecnorm(hist.xs(1:8,1:steps) - param.sd);

            h = plot(ax,tspan,error,...
                'Color', style.highlight,...
                'LineStyle','-',...
                'LineWidth',2.0,...
                'DisplayName','$\epsilon = 0.9$');

            legend(h,...
                'Interpreter','latex',...
                'FontSize',12,...
                'Location','northeast');

        end

        %% Axis settings
        set(ax,'YScale','log');

        grid(ax,'on');
        axis(ax,'tight');

        %% -------- Only left column has ylabel --------
        if mod(k-1,ncols) == 0

            ylabel(ax,...
                '$$\|\mathbf{s}-\mathbf{s}_{\mathrm d}\|_2$$',...
                'Interpreter','latex',...
                'FontSize',14);

        else

            ylabel(ax,'');

        end

        %% -------- Only bottom row has xlabel --------
        if k > length(unique_nl)-ncols

            xlabel(ax,...
                '\fontname{宋体}时间\fontname{Times New Roman}/s',...
                'Interpreter','tex',...
                'FontSize',14);

        else

            xlabel(ax,'');

        end

        %% Tick font
        set(ax,...
            'FontName','Times New Roman',...
            'FontSize',14);

        %% Colorbar
        cb = colorbar(ax);

        cb.FontSize = 14;
        cb.Label.String = '$$\epsilon$$';
        cb.Label.Interpreter = 'latex';

        clim(ax,...
            [min(nl_subset(:,2)),...
             max(nl_subset(:,2))]);

        %% Internal title
        text(ax,...
            0.05,...
            0.95,...
            ['$$\mathrm{N_l} = ',num2str(nl_val),'$$'],...
            'Units','normalized',...
            'Interpreter','latex',...
            'FontSize',12,...
            'FontWeight','bold');

    end

    %% Unified y-limits
    if global_min <= 0
        global_min = 1e-6;
    end

    set(ax_handles,...
        'YLim',...
        [global_min global_max]);

end
