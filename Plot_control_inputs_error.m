%% PLOT CONTROL INPUTS ERROR
function Plot_control_inputs_error(param, hist, k)
% Plot control input errors over time
%
% This function visualizes the error between desired and actual control
% inputs, including both force and torque components.
%
% Inputs:
%   param - structure containing spacecraft mass (ms)
%   hist  - structure containing control history (u, uT)
%   k     - current time step index
%
% Outputs:
%   None (displays figure)

    style = Plot_style();
    fig = figure('Units','inches','Position',[1 1 8 6]);
    ms = param.ms;
    uT = hist.uT;
    u  = hist.u;
    force  = ms * (uT(1:3,:) - u(1:3,:));
    torque = uT(4:6,:) - u(4:6,:);


    subplot(2,1,1); hold on;
    stairs(force(1,1:k), 'Color', style.axis(1,:), 'LineStyle', style.axisLine{1}, 'LineWidth', 1.5);
    stairs(force(2,1:k), 'Color', style.axis(2,:), 'LineStyle', style.axisLine{2}, 'LineWidth', 1.5);
    stairs(force(3,1:k), 'Color', style.axis(3,:), 'LineStyle', style.axisLine{3}, 'LineWidth', 1.5);
    grid on; axis tight;
    set(gca,'FontSize',14,'FontName','Times New Roman');
    ylabel('\fontname{宋体}控制推力\fontname{Times New Roman}/N', ...
           'FontSize', 14, 'Interpreter', 'tex');
    xlabel('\fontname{宋体}时间\fontname{Times New Roman}/s', ...
           'FontSize', 14, 'Interpreter', 'tex')

    subplot(2,1,2); hold on;
    stairs(torque(1,1:k), 'Color', style.axis(1,:), 'LineStyle', style.axisLine{1}, 'LineWidth', 1.5);
    stairs(torque(2,1:k), 'Color', style.axis(2,:), 'LineStyle', style.axisLine{2}, 'LineWidth', 1.5);
    stairs(torque(3,1:k), 'Color', style.axis(3,:), 'LineStyle', style.axisLine{3}, 'LineWidth', 1.5);
    grid on; axis tight;
    set(gca,'FontSize',14,'FontName','Times New Roman');
    ylabel('\fontname{宋体}控制力矩\fontname{Times New Roman}/Nm', ...
           'FontSize', 14, 'Interpreter', 'tex');
    xlabel('\fontname{宋体}时间\fontname{Times New Roman}/s', ...
           'FontSize', 14, 'Interpreter', 'tex')

end
