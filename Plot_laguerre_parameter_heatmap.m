function Plot_laguerre_parameter_heatmap(file_path, file_name, nl_eps, steps, type)
    % type = 'error' or 'energy'
    unique_nl = unique(nl_eps(:,1));
    unique_eps = unique(nl_eps(:,2));
    final_vals = nan(length(unique_nl), length(unique_eps));  % 初始化NaN
    
    EXTREME_VAL = 1e10;  % 极大值，用于失败/剔除
    
    for i = 1:size(nl_eps,1)
        nl_val = nl_eps(i,1);
        eps_val = nl_eps(i,2);
        fname = fullfile(file_path, file_name(nl_val, eps_val));
        
        if ~exist(fname, 'file')
            disp(['File not found for N_l=', num2str(nl_val), ', eps=', num2str(eps_val), '. Setting to extreme.']);
            nl_idx = unique_nl == nl_val;
            eps_idx = unique_eps == eps_val;
            final_vals(nl_idx, eps_idx) = EXTREME_VAL;
            continue;
        end
        
        data = load(fname);
        param = data.param;
        hist = data.hist;
        
        if ~isfield(hist, 'xs') || ~isfield(param, 'sd') || isempty(hist.xs)
            disp(['Invalid data structure for N_l=', num2str(nl_val), ', eps=', num2str(eps_val), '. Setting to extreme.']);
            nl_idx = unique_nl == nl_val;
            eps_idx = unique_eps == eps_val;
            final_vals(nl_idx, eps_idx) = EXTREME_VAL;
            continue;
        end
        
        error = vecnorm(hist.xs(1:8,1:steps) - param.sd);
        
        % 失败检测
        if error(end) > 10 || isnan(error(end)) || isinf(error(end))
            disp(['Failed (>10 or NaN/Inf) for N_l=', num2str(nl_val), ', eps=', num2str(eps_val), ', error(end)=', num2str(error(end))]);
            nl_idx = unique_nl == nl_val;
            eps_idx = unique_eps == eps_val;
            final_vals(nl_idx, eps_idx) = EXTREME_VAL;  % 设为极大值
            continue;
        end
        
        if strcmp(type, 'error')
            val = error(end);
        elseif strcmp(type, 'energy')
            u = hist.uT(:,1:steps);
            val = sum(vecnorm(u));
        end
        
        if isnan(val) || isinf(val)
            disp(['Computed val is NaN/Inf for N_l=', num2str(nl_val), ', eps=', num2str(eps_val), '. Setting to extreme.']);
            nl_idx = unique_nl == nl_val;
            eps_idx = unique_eps == eps_val;
            final_vals(nl_idx, eps_idx) = EXTREME_VAL;
            continue;
        end
        
        nl_idx = unique_nl == nl_val;
        eps_idx = unique_eps == eps_val;
        final_vals(nl_idx, eps_idx) = val;
    end
    
    % 计算正常范围
    valid_vals = final_vals(final_vals < 1e10 & ~isnan(final_vals) & ~isinf(final_vals));
    if isempty(valid_vals)
        min_val = 0; max_val = 1;
    else
        min_val = min(valid_vals);
        max_val = max(valid_vals);
    end

    % 打印调试
    disp(['Normal min_val: ', num2str(min_val), ', max_val: ', num2str(max_val)]);
    
    figure('Units','inches', 'Position', [1 1 8 6]);
    imagesc(unique_eps, unique_nl, final_vals); % 热图
    set(gca, 'YDir','normal');
    
    % 自定义colormap：添加白色到末尾
    cmap = jet(256);  % 或parula(256)
    cmap(end+1, :) = [1 1 1];  % 末尾白色
    colormap(cmap);
    
    % caxis：上限加小eps，避免正常max钳位
    clim([min_val, max_val + 1e-1]);
    
    % 轴背景白（NaN）
    set(gca, 'Color', [1 1 1]);
    
    cb = colorbar;
    cb.Label.String = ['Final ', type];
    xlabel('$$\epsilon$$', 'Interpreter','latex', 'FontSize',12);
    ylabel('$$N_l$$', 'Interpreter','latex', 'FontSize',12);
    % title(['Final ', type, ' Heatmap'], 'FontSize',14);
    set(gca,'FontName','Times New Roman','FontSize',12);

    % 绘制红线
    hold on;
    plot(linspace(0,0.925,10), 2.5*ones(10,1), 'r', 'LineWidth', 2.5);
    plot(linspace(0,0.925,10), 3.5*ones(10,1), 'r', 'LineWidth', 2.5);
    plot(0.875*ones(10,1), linspace(0,3.5,10), 'r', 'LineWidth', 2.5);
    plot(0.925*ones(10,1), linspace(0,3.5,10), 'r', 'LineWidth', 2.5);
end