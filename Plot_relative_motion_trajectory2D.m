%% PLOT RELATIVE MOTION TRAJECTORY 2D
function Plot_relative_motion_trajectory2D(param, hist, k, saveFig)
% Plot 2D projection of relative motion trajectory in LVLH frame
%
% This function visualizes the relative motion trajectory projected onto
% the Y-X plane of the LVLH frame.
%
% Inputs:
%   param   - structure containing system parameters
%   hist    - structure containing simulation history
%   k       - current timestep
%   saveFig - boolean, whether to save figure as PDF
%
% Outputs:
%   None (displays figure)

    % Define coordinate axes
    x = [1;0;0]; y = [0;1;0]; z = [0;0;1];

    % Initialize rotation axes
    x_lt = zeros(3, k); y_lt = zeros(3, k); z_lt = zeros(3, k);
    x_ls = zeros(3, k); y_ls = zeros(3, k); z_ls = zeros(3, k);
    x_lc = zeros(3, k); y_lc = zeros(3, k); z_lc = zeros(3, k);
    for i = 1:k
        R_tl = hist.R_ti{i} * hist.R_li{i}';
        R_sl = hist.R_si{i} * hist.R_li{i}';
        R_cl = hist.R_ci{i} * hist.R_li{i}';
        x_lt(:,i) = R_tl' * x;
        y_lt(:,i) = R_tl' * y;
        z_lt(:,i) = R_tl' * z;
        x_ls(:,i) = R_sl' * x;
        y_ls(:,i) = R_sl' * y;
        z_ls(:,i) = R_sl' * z;
        x_lc(:,i) = R_cl' * x;
        y_lc(:,i) = R_cl' * y;
        z_lc(:,i) = R_cl' * z;
    end

    r_l = hist.xl(7:9,:);

    fig = figure('Units','inches','Position',[1 1 6 10]);

    ax_main = axes('Position',[0.05, 0.05, 0.90, 0.90]);
    hold(ax_main, 'on'); view(ax_main, 180, -90);
    grid(ax_main, 'on'); axis(ax_main, 'equal');
    xlim([-4.5,5.5]); ylim([-16.5,5.5])

    color_axes  = [1 0 0; 0 1 0; 0 0 1];
    color_point = [231 76 60; 46 204 113; 52 152 219; 241 196 15]/255;
    color_patch = [0 0 1; 204/255 255/255 204/255; 1 0 0];
    alpha_vals  = linspace(0.3, 0.5, k);

    for i = [1, k]
        start = zeros(1,3);
        Plot_arrow3D(start, start + 1.5 * x_lt(:,i)', color_axes(1,:), alpha_vals(i));
        Plot_arrow3D(start, start + 1.5 * y_lt(:,i)', color_axes(2,:), alpha_vals(i));
        Plot_arrow3D(start, start + 1.5 * z_lt(:,i)', color_axes(3,:), alpha_vals(i));
    end
    plot3(start(1),start(2),start(3),'ko','MarkerSize',3,'MarkerFaceColor','k');

    idx_array = [1,61,121,181,361,481,k];
    for i = idx_array
        pos = r_l(:,i)';
        Plot_arrow3D(pos, pos + 1.5 * x_ls(:,i)', color_axes(1,:), alpha_vals(i));
        Plot_arrow3D(pos, pos + 1.5 * y_ls(:,i)', color_axes(2,:), alpha_vals(i));
        Plot_arrow3D(pos, pos + 1.5 * z_ls(:,i)', color_axes(3,:), alpha_vals(i));
        Plot_camera_model(pos', hist.R_cl{i}', 15.0);
        Plot_camera_axes(pos', hist.R_cl{i}', 2.0, [0.2 0.6 1.0], 0.15);
    end

    for i = idx_array
        pos = (r_l(:,i) + hist.R_sl{i}' *param.r_sc)';
        Plot_arrow3D(pos, pos + 1.5 * x_lc(:,i)', color_axes(1,:), alpha_vals(i));
        Plot_arrow3D(pos, pos + 1.5 * y_lc(:,i)', color_axes(2,:), alpha_vals(i));
        Plot_arrow3D(pos, pos + 1.5 * z_lc(:,i)', color_axes(3,:), alpha_vals(i));
    end

    t_labels = [0, 30, 60, 90, 180, 240, 300];  
    offset_vectors = [
        1.0,  0.0, 0.0; 
       -1.0, -0.0, 0.0; 
        1.0, -0.0, 0.0; 
       -1.0, -0.0, 0.0; 
        1.5,  0.0, 0.0; 
       -1.5, -0.0, 0.0; 
        1.5, -0.0, 0.0; 
    ];
    for j = 1:length(t_labels)
        i = t_labels(j) / param.ts + 1;
        text_pos = r_l(:,i)' + offset_vectors(j,:);
        text(ax_main, text_pos(1), text_pos(2), text_pos(3), ...
            sprintf('t = %ds', t_labels(j)), ...
            'FontSize', 10, 'FontName', 'Times New Roman', ...
            'Interpreter', 'latex', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    end

    plot3(r_l(1,:), r_l(2,:), r_l(3,:), 'Color', 'k', 'LineWidth', 1.5);

    xi_l = zeros(3,4);
    for i = idx_array
        if i == 1, idx = 1; end
        if i >= 2, idx = 2; end
        if i == k, idx = 3; end

        R_tl = hist.R_ti{i}*hist.R_li{i}';
        for j = 1:4
            xi_l(:,j) = R_tl'*param.xi(3*(j-1)+1:3*j);
            scatter3(ax_main, xi_l(1,j), xi_l(2,j), xi_l(3,j), 30, color_point(j,:), ...
                     'filled', 'MarkerEdgeColor', color_point(j,:), ...
                     'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 1.0, 'LineWidth', 0.5);
        end

        patch('Parent', ax_main, 'Vertices', xi_l', 'Faces', [1 2 3 4], ...
              'FaceColor', 'interp', 'FaceVertexCData', repmat(color_patch(idx,:), 4, 1), ...
              'FaceAlpha', 0.25, 'EdgeColor', 'black');

        for j = 1:4
            line([r_l(1,i),xi_l(1,j)], [r_l(2,i),xi_l(2,j)], [r_l(3,i),xi_l(3,j)], ...
                 'Color', color_point(j,:), 'LineStyle', '--', 'LineWidth', 0.75);
        end
    end

    xlabel('$x_L\ (\rm{m})$', 'FontSize', 12, 'FontName', 'Times New Roman', 'Interpreter', 'latex');
    ylabel('$y_L\ (\rm{m})$', 'FontSize', 12, 'FontName', 'Times New Roman', 'Interpreter', 'latex');
    zlabel('$z_L\ (\rm{m})$', 'FontSize', 12, 'FontName', 'Times New Roman', 'Interpreter', 'latex');
    set(ax_main, 'FontSize', 12, 'FontName', 'Times New Roman');

    if saveFig == true
        set(gcf, 'PaperPositionMode', 'auto');
        set(gcf, 'Renderer', 'painters');
        figure_name = strcat('figs/relative_motion_trajectory2D_duration=', num2str(k*param.ts), 's');
        print(fig, figure_name, '-dpdf', '-r600')
    end
end
