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

    fig = figure('Units','inches','Position',[1 1 8 6]);
    ms = param.ms;
    uT = hist.uT;
    u  = hist.u;
    force  = ms * (uT(1:3,:) - u(1:3,:));
    torque = uT(4:6,:) - u(4:6,:);


    subplot(2,1,1); hold on;
    stairs(force(1,1:k), 'r-', 'LineWidth', 1.5);
    stairs(force(2,1:k), 'k-.', 'LineWidth', 1.5);
    stairs(force(3,1:k), 'b--', 'LineWidth', 1.5);
    grid on; axis tight;
    set(gca,'FontSize',12,'FontName','Times New Roman');
    ylabel('Force [N]','FontSize', 12, ...
           'FontName', 'Times New Roman');
    xlabel('Time (s)','FontSize', 12, ...
           'FontName', 'Times New Roman')

    subplot(2,1,2); hold on;
    stairs(torque(1,1:k), 'r-', 'LineWidth', 1.5);
    stairs(torque(2,1:k), 'k-.', 'LineWidth', 1.5);
    stairs(torque(3,1:k), 'b--', 'LineWidth', 1.5);
    grid on; axis tight;
    set(gca,'FontSize',12,'FontName','Times New Roman');
    ylabel('Torque [Nm]','FontSize', 12, ...
           'FontName', 'Times New Roman');
    xlabel('Time (s)','FontSize', 12, ...
           'FontName', 'Times New Roman')

end
