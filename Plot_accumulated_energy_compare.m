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

    style = Plot_style();
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


    fig = figure('Units','inches','Position',[1 1 8 6]);
    hold on;


    area(tspan, energy2, 'LineWidth', 2.0, ...
        'FaceColor', style.method.gamma0, 'EdgeColor', style.method.gamma0, ...
        'FaceAlpha', 0.30, 'DisplayName', '$\gamma \equiv 0$', 'LineStyle', style.methodLine.gamma0);

    area(tspan, energy3, 'LineWidth', 2.0, ...
        'FaceColor', style.method.gamma1, 'EdgeColor', style.method.gamma1, ...
        'FaceAlpha', 0.30, 'DisplayName', '$\gamma \equiv 1$', 'LineStyle', style.methodLine.gamma1);
    
    area(tspan, energy1, 'LineWidth', 2.0, ...
        'FaceColor', style.method.adaptive, 'EdgeColor', style.method.adaptive, ...
        'FaceAlpha', 0.30, 'DisplayName', '$\gamma$ Adaptive', 'LineStyle', style.methodLine.adaptive);


    grid on; axis tight;
    ylim([0, max([energy1(end), energy2(end), energy3(end)])+4.0]);
    xlabel('\fontname{宋体}时间\fontname{Times New Roman}/s', ...
           'FontSize', 14, 'Interpreter', 'tex');
    ylabel('$\sum||\boldmath{u}||_2$', 'FontSize', 14, 'FontName', 'Times New Roman', 'Interpreter','latex');
    legend('Interpreter', 'latex', 'Location', 'northwest', 'FontSize', 12);
    set(gca, 'FontName', 'Times New Roman', 'FontSize', 14);
end
