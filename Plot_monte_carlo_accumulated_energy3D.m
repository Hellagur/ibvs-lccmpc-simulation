%% PLOT MONTE CARLO ACCUMULATED ENERGY 3D
function Plot_monte_carlo_accumulated_energy3D(path1, path2, path3, N)
% Plot 3D bar chart comparing accumulated energy across methods
%
% This function computes and visualizes the accumulated control energy for
% three different control variable methods using 3D bar charts.
%
% Inputs:
%   path1 - path to method 1 results (u)
%   path2 - path to method 2 results (du)
%   path3 - path to method 3 results (eta)
%   N     - number of Monte Carlo simulations
%
% Outputs:
%   None (displays figure)

    energy1 = zeros(1, N);
    energy2 = zeros(1, N);
    energy3 = zeros(1, N);
    
    for i = 1:N
        % Method 1
        data1 = load(fullfile(path1, [num2str(i), '.mat']));
        hist1 = data1.hist;
        u1 = hist1.uT;
        sum1 = 0;
        for j = 1:size(u1, 2)
            sum1 = sum1 + norm(u1(:,j));
        end
        energy1(i) = sum1;
        
        % Method 2
        data2 = load(fullfile(path2, [num2str(i), '.mat']));
        hist2 = data2.hist;
        u2 = hist2.uT;
        sum2 = 0;
        for j = 1:size(u2, 2)
            sum2 = sum2 + norm(u2(:,j));
        end
        energy2(i) = sum2;
        
        % Method 3
        data3 = load(fullfile(path3, [num2str(i), '.mat']));
        hist3 = data3.hist;
        u3 = hist3.uT;
        sum3 = 0;
        for j = 1:size(u3, 2)
            sum3 = sum3 + norm(u3(:,j));
        end
        energy3(i) = sum3;
    end
    
    % Determine bins
    all_energy = [energy1, energy2, energy3];
    min_e = min(all_energy);
    max_e = max(all_energy);
    num_bins = 10;
    edges = linspace(min_e, max_e, num_bins + 1);
    centers = (edges(1:end-1) + edges(2:end)) / 2;
    
    % Compute histograms
    count1 = histcounts(energy1, edges);
    count2 = histcounts(energy2, edges);
    count3 = histcounts(energy3, edges);
    
    y = [1, 4, 7];
    z = [count1; count2; count3];
    
    figure('Units','inches', ...
           'Position',[1 1 12 6], ...
           'PaperOrientation', 'landscape');
    bar3(y, z);
    xlabel('$$\sum || \boldmath{u} ||_2$$', 'FontSize', 12, 'Interpreter','latex');
    zlabel('$$N$$', 'FontSize', 12, 'Interpreter','latex');
    yticks(y);
    yticklabels({'$$\boldmath{u}$$', '$$\Delta \boldmath{u}$$', '$$\boldmath{\eta}$$'});
    xticks(1:length(centers));
    xticklabels(arrayfun(@(x) sprintf('%.1f', x), centers, 'UniformOutput', false));
    set(gca, 'TickLabelInterpreter', 'latex', ...
        'FontName', 'Times New Roman', 'FontSize', 12);
end
