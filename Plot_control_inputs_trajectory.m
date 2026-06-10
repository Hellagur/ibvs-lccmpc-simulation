%% PLOT CONTROL INPUTS TRAJECTORY
function fig = Plot_control_inputs_trajectory(param, hist, k, saveFig)
% Plot spacecraft control inputs over time
%
% This function visualizes both thrust forces and control moments applied
% in the spacecraft body frame over the simulation duration.
%
% Inputs:
%   param   - structure containing system parameters (ts, ms, fm, tm)
%   hist    - structure containing control history (u, uT)
%   k       - current time step index
%   saveFig - boolean, whether to save figure as PDF
%
% Outputs:
%   fig - figure handle

    %% Prepare Figure
    style = Plot_style();
    fig = figure('Units','inches','Position',[1 1 8 6]);
    tspan = (0:1:k-1) * param.ts;  % time vector

    %% Subplot 1: Thrust Forces
    subplot(211)
    ms = param.ms;
    fm = param.fm*ms;
    view(2); hold on; box off;
    stairs(tspan, hist.uT(1,1:k)*ms, 'Color', style.axis(1,:), 'LineStyle', style.axisLine{1}, 'LineWidth',1.5);  % fx
    stairs(tspan, hist.uT(2,1:k)*ms, 'Color', style.axis(2,:), 'LineStyle', style.axisLine{2}, 'LineWidth',1.5);  % fy
    stairs(tspan, hist.uT(3,1:k)*ms, 'Color', style.axis(3,:), 'LineStyle', style.axisLine{3}, 'LineWidth',1.5);  % fz
    grid on; axis tight;
    ylim([-fm-1,fm+1]); yticks(-5:2:5);
    xlabel('\fontname{宋体}时间\fontname{Times New Roman}/s', ...
           'FontSize', 14, 'Interpreter', 'tex');
    ylabel('\fontname{宋体}控制推力\fontname{Times New Roman}/N', ...
           'FontSize', 14, 'Interpreter', 'tex');
    set(gca,'FontSize',14,'FontName','Times New Roman');
    legend('$f^c_{\mathrm{S},x}$', '$f^c_{\mathrm{S},y}$', '$f^c_{\mathrm{S},z}$', ...
           'FontSize', 12, 'FontName', 'Times New Roman', ...
           'Interpreter', 'latex', 'Location', 'northeast');

    %% Subplot 2: Control Moments
    subplot(212)
    view(2); hold on; box off;
    stairs(tspan, hist.uT(4,1:k), 'Color', style.axis(1,:), 'LineStyle', style.axisLine{1}, 'LineWidth',1.5);  % tau_x
    stairs(tspan, hist.uT(5,1:k), 'Color', style.axis(2,:), 'LineStyle', style.axisLine{2}, 'LineWidth',1.5);  % tau_y
    stairs(tspan, hist.uT(6,1:k), 'Color', style.axis(3,:), 'LineStyle', style.axisLine{3}, 'LineWidth',1.5);  % tau_z
    grid on; axis tight;
    tm = param.tm;
    ylim([-tm-0.05,tm+0.05]); yticks(-0.2:0.1:0.2);
    xlabel('\fontname{宋体}时间\fontname{Times New Roman}/s', ...
           'FontSize', 14, 'Interpreter', 'tex');
    ylabel('\fontname{宋体}控制力矩\fontname{Times New Roman}/Nm', ...
           'FontSize', 14, 'Interpreter', 'tex');
    set(gca,'FontSize',14,'FontName','Times New Roman');
    legend('$\tau^c_{\mathrm{S},x}$', '$\tau^c_{\mathrm{S},y}$', '$\tau^c_{\mathrm{S},z}$', ...
           'FontSize', 12, 'FontName', 'Times New Roman', ...
           'Interpreter', 'latex', 'Location', 'northeast');

    %% Save Figure if Requested
    if saveFig
        set(gcf, 'PaperPositionMode', 'auto');      % automatic paper size
        set(gcf, 'Renderer', 'painters');           % vector graphics
        figure_name = strcat('figs/control_input_trajectory_duration=', num2str(k*param.ts), 's');
        print(fig, figure_name, '-dpdf', '-r600')
    end
end
