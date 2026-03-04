%% PLOT ACCUMULATED ENERGY COMPARE
function fig = Plot_accumulated_energy_compare(file1, file2, file3)
% Compare accumulated control energy across different gamma methods
%
% This function loads simulation results for three different gamma settings
% and plots the accumulated control energy over time for comparison.
%
% Inputs:
%   file1 - path to gamma adaptive results
%   file2 - path to gamma=0 results
%   file3 - path to gamma=1 results
%
% Outputs:
%   fig - figure handle

    data1 = load(file1);
    hist1 = data1.hist;
    param = data1.param;
    tspan = 0:param.ts:param.ts*(param.Tsteps-1);


    data2 = load(file2);
    hist2 = data2.hist;
    
    data3 = load(file3);
    hist3 = data3.hist;


    u1 = hist1.uT(:,1:param.Tsteps);
    energy1 = zeros(1,param.Tsteps);


    u2 = hist2.uT(:,1:param.Tsteps);
    energy2 = zeros(1,param.Tsteps);


    u3 = hist3.uT(:,1:param.Tsteps);
    energy3 = zeros(1,param.Tsteps);


    sum1 = 0;
    sum2 = 0;
    sum3 = 0;
    for i = 1:param.Tsteps
        sum1 = sum1 + norm(u1(:,i));
        energy1(i) = sum1;
        
        sum2 = sum2 + norm(u2(:,i));
        energy2(i) = sum2;
        
        sum3 = sum3 + norm(u3(:,i));
        energy3(i) = sum3;
    end


    base_colors = [231, 76, 60; 46, 204, 113; 52, 152, 219] / 255;


    fig = figure('Units','inches','Position',[1 1 8 6]);
    hold on;


    area(tspan, energy2, 'LineWidth', 2.0, ...
        'FaceColor', base_colors(2,:), 'EdgeColor', base_colors(3,:), ...
        'FaceAlpha', 0.36, 'DisplayName', '$\gamma \equiv 0$', 'LineStyle','-');

    area(tspan, energy3, 'LineWidth', 2.0, ...
        'FaceColor', base_colors(3,:), 'EdgeColor', base_colors(3,:), ...
        'FaceAlpha', 0.36, 'DisplayName', '$\gamma \equiv 1$', 'LineStyle','--');
    
    area(tspan, energy1, 'LineWidth', 2.0, ...
        'FaceColor', base_colors(1,:), 'EdgeColor', base_colors(1,:), ...
        'FaceAlpha', 0.36, 'DisplayName', '$\gamma$ Adaptive', 'LineStyle','-.');


    grid on; axis tight;
    ylim([0, max([energy1(end), energy2(end), energy3(end)])+4.0]);
    xlabel('Time (s)', 'FontSize', 12, 'FontName', 'Times New Roman');
    ylabel('$\sum||\boldmath{u}||_2$', 'FontSize', 12, 'FontName', 'Times New Roman', 'Interpreter','latex');
    legend('Interpreter', 'latex', 'Location', 'northwest', 'FontSize', 10);
    set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
end
