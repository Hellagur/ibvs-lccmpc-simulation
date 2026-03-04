%% PLOT LAGUERRE PARAMETER HEATMAP
function Plot_laguerre_parameter_heatmap(file_path, file_name, nl_eps, steps, type)
% Plot heatmap of final error or energy vs Laguerre parameters
%
% This function creates a heatmap visualization showing the final pixel error
% or control energy for different combinations of Laguerre basis functions (Nl)
% and time scaling parameters (epsilon).
%
% Inputs:
%   file_path  - directory path to simulation files
%   file_name  - function for generating filename
%   nl_eps     - matrix of [Nl, epsilon] pairs
%   steps      - number of time steps
%   type       - 'error' or 'energy'

    unique_nl = unique(nl_eps(:,1));
    unique_eps = unique(nl_eps(:,2));
    final_vals = nan(length(unique_nl), length(unique_eps));
    
    EXTREME_VAL = 1e10;
    
    for i = 1:size(nl_eps,1)
        nl_val = nl_eps(i,1);
        eps_val = nl_eps(i,2);
        fname = fullfile(file_path, file_name(nl_val, eps_val));
        
        if ~exist(fname, 'file')
            nl_idx = unique_nl == nl_val;
            eps_idx = unique_eps == eps_val;
            final_vals(nl_idx, eps_idx) = EXTREME_VAL;
            continue;
        end
        
        data = load(fname);
        param = data.param;
        hist = data.hist;
        
        error = vecnorm(hist.xs(1:8,1:steps) - param.sd);
        
        if error(end) > 10 || isnan(error(end)) || isinf(error(end))
            nl_idx = unique_nl == nl_val;
            eps_idx = unique_eps == eps_val;
            final_vals(nl_idx, eps_idx) = EXTREME_VAL;
            continue;
        end
        
        if strcmp(type, 'error')
            val = error(end);
        elseif strcmp(type, 'energy')
            u = hist.uT(:,1:steps);
            val = sum(vecnorm(u));
        end
        
        nl_idx = unique_nl == nl_val;
        eps_idx = unique_eps == eps_val;
        final_vals(nl_idx, eps_idx) = val;
    end
    
    valid_vals = final_vals(final_vals < 1e10 & ~isnan(final_vals) & ~isinf(final_vals));
    if isempty(valid_vals)
        min_val = 0; max_val = 1;
    else
        min_val = min(valid_vals);
        max_val = max(valid_vals);
    end
    
    figure('Units','inches', 'Position', [1 1 8 6]);
    imagesc(unique_eps, unique_nl, final_vals);
    set(gca, 'YDir','normal');
    
    cmap = jet(256);
    cmap(end+1, :) = [1 1 1];
    colormap(cmap);
    
    clim([min_val, max_val + 1e-1]);
    set(gca, 'Color', [1 1 1]);
    
    cb = colorbar;
    cb.Label.String = ['Final ', type];
    xlabel('$$\epsilon$$', 'Interpreter','latex', 'FontSize',12);
    ylabel('$$N_l$$', 'Interpreter','latex', 'FontSize',12);
    set(gca,'FontName','Times New Roman','FontSize',12);

    % Plot selected region
    hold on;
    plot(linspace(0,0.925,10), 2.5*ones(10,1), 'r', 'LineWidth', 2.5);
    plot(linspace(0,0.925,10), 3.5*ones(10,1), 'r', 'LineWidth', 2.5);
    plot(0.875*ones(10,1), linspace(0,3.5,10), 'r', 'LineWidth', 2.5);
    plot(0.925*ones(10,1), linspace(0,3.5,10), 'r', 'LineWidth', 2.5);
end
