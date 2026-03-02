%% Plot 2D real-time trajectory
function [h, xdata, ydata] = Add_RT_xydata(h, xdata, ydata, x, y)
    xdata(end+1) = x;
    ydata(end+1) = y;
    set(h, 'XData', xdata, 'YData', ydata);
    drawnow limitrate;
end