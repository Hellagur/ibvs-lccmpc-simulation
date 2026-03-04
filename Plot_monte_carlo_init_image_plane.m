%% PLOT MONTE CARLO INITIAL IMAGE PLANE
function Plot_monte_carlo_init_image_plane(s0_all, N)
% Plot Monte Carlo initial feature positions in image plane
%
% This function visualizes the initial distribution of feature points in the
% image plane from Monte Carlo simulations.
%
% Inputs:
%   s0_all - initial feature positions (8×N)
%   N      - number of samples
%
% Outputs:
%   None (displays figure)

    fig = figure('Units','inches', ...
                 'Position',[1 1 8 6], ...
                 'PaperOrientation', 'landscape');
    view(2); hold on;

    param = Init_params();
    sd = param.sd;
    um = param.um;
    nm = param.nm;
    
    Colors = [231  76  60; 
               46 204 113; 
               52 152 219; 
              241 196  15] ./ 255;

    for i = 1:N
        s0 = s0_all(:,i);
        for j = 1:4
            scatter(s0(2*(j-1)+1), s0(2*j,1), 40,...
                'MarkerEdgeColor', Colors(j,:), ...
                'MarkerFaceColor', Colors(j,:), ...
                'MarkerFaceAlpha', 0.35);
        end
        line('XData', [s0(1:2:7); s0(1)], ...
             'YData', [s0(2:2:8); s0(2)], ...
             'Color', [120,120,120]/255)
    end

    line([um, um, -um, -um, um], ...
         [-nm, nm, nm, -nm, -nm], ...
         'color', 'k', ...
         'LineStyle', '--', ...
         'LineWidth', 1.5);

    xlabel('$u\ (\rm{px})$', ...
            'FontSize', 12, ...
            'FontName', 'Times New Roman', ...
            'Interpreter', 'latex');
    ylabel('$v\ (\rm{px})$', ...
            'FontSize', 12, ...
            'FontName', 'Times New Roman', ...
            'Interpreter', 'latex');
    set(gca, 'FontSize', 12, 'FontName', 'Times New Roman');

    grid on; axis equal;
end
