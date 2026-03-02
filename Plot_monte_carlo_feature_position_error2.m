function fig = Plot_monte_carlo_feature_position_error2(path, total_numbers)
    fig = figure('Units','inches', ...
                 'Position',[1 1 8 6], ...
                 'PaperOrientation', 'landscape');
    view(2); hold on;

    %========================
    % 定义更自然的渐变色方案
    %========================
    colors = parula(total_numbers*3);
    ids = 1;
    ide = round(total_numbers*2.7);
    num = round(total_numbers*0.95);
    colors = [colors(ids:ids+num,:);
              colors(ide:ide+(total_numbers-num),:);];
    base_colors = [231, 76, 60; 46, 204, 113; 52, 152, 219; 241, 196, 15] / 255;
    markerSize = 30;
    %========================
    % 绘制轨迹
    %========================
    for i = 1:total_numbers
        fname   = fullfile(path, [num2str(i), '.mat']);
        data    = load(fname);
        tspan   = (0:1:data.param.Tsteps)*data.param.ts;      
        pos_err = data.hist.xs(1:8,1:data.param.Tsteps+1) - data.param.sd;
        pos_errn = zeros(4, data.param.Tsteps+1);
        for j = 1:4
            pos_errn(j,:) = vecnorm(pos_err(2*(j-1)+1:2*j,:));
        end

        % for idx = 1:4
        %     % 绘制渐变点 (为了性能，建议主图若点数过多可简化)
        %     for j = 1:5:length(tspan) % 每隔5个点画一个，避免卡顿
        %         color_factor = 0.3 + 0.7*(j-1)/(length(tspan)-1);
        %         c_rgb = base_colors(idx,:) * color_factor + (1-color_factor)*[1 1 1];
        %         scatter(tspan(j), pos_errn(idx,i), markerSize, c_rgb, 'filled', 'MarkerFaceAlpha', 0.6);
        %     end
        %     % plot(ax_main, tspan, pos_errn(idx,:), '-', 'Color', base_colors(idx,:), 'LineWidth', 1.5);
        % end

        for j = 1:size(pos_errn,1)
            scatter(tspan(1:5:end), pos_errn(j,1:5:end), markerSize, base_colors(j,:), 'filled', 'MarkerFaceAlpha', 0.35);
            % plot(tspan(1:end), pos_errn(j,1:end), 'Color', base_colors(j,:), 'LineWidth', 0.75);
        end
    end
    plot(tspan, 1.5*ones(size(tspan)), '--', 'Color', '#666666', 'LineWidth', 1.0);

    %========================
    % 主图设置
    %========================
    grid on; axis tight;
    xlabel('Time (s)', 'FontSize', 12, 'FontName', 'Times New Roman');
    ylabel('$||\boldmath{s}_i - \boldmath{s}_{d,i}||_2$ (px)', ...
        'FontSize', 12, 'FontName', 'Times New Roman', 'Interpreter', 'latex');
    set(gca, 'FontSize', 12, 'FontName', 'Times New Roman');
    yscale('log');

    %========================
    % inset 子图
    %========================
    pos = get(gca, 'Position');  
    inset_scale = 0.34;  
    inset_w = pos(3) * inset_scale;
    inset_h = pos(4) * inset_scale;
    inset_x = pos(1) + pos(3) - inset_w - 0.03;
    inset_y = pos(2) + pos(4) - inset_h - 0.04;
    ax_inset = axes('Position', [inset_x, inset_y, inset_w, inset_h]); 
    box on; hold on; grid(ax_inset,'on'); axis(ax_inset,'tight');
    set(ax_inset, 'FontSize', 10, 'FontName', 'Times New Roman');

    zoom_duration = 50.0;

    for i = 1:total_numbers
        fname   = fullfile(path, [num2str(i), '.mat']);
        data    = load(fname);
        tspan   = (0:1:data.param.Tsteps)*data.param.ts;      
        pos_err = data.hist.xs(1:8,1:data.param.Tsteps+1) - data.param.sd;
        
        [~, zoom_start_idx] = min(abs(tspan - (tspan(end) - zoom_duration)));
        zoom_t = tspan(zoom_start_idx:end);
        zoom_err = pos_err(:,zoom_start_idx:end);

        zoom_errn = zeros(4, length(zoom_t));
        for j = 1:4
            zoom_errn(j,:) = vecnorm(zoom_err(2*(j-1)+1:2*j,:));
        end

        for j = 1:size(zoom_errn,1)
            scatter(ax_inset, zoom_t(1:2:end), zoom_errn(j,1:2:end), markerSize, base_colors(j,:), 'filled', 'MarkerFaceAlpha', 0.35);
            % plot(zoom_t(1:end), zoom_errn(j,1:end), 'Color', base_colors(j,:), 'LineWidth', 0.75);
        end
    end
    plot(zoom_t, 1.5*ones(size(zoom_t)), '--', 'Color', '#666666', 'LineWidth', 1.0);
    ylim([0,1.6]);
end
