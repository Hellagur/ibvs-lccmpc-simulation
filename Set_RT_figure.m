%% Plot 2D real-time trajectory
function [h, xdata, ydata] = Set_RT_figure()
    figure;
    h = plot(NaN, NaN, 'b--', 'LineWidth', 1.5);
    grid on; hold on;
    xdata = [];
    ydata = [];
end