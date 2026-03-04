%% FUZZY INFERENCE SYSTEM GENERATION
% Create Sugeno-type FIS for gamma adjustment
%
% This script generates a fuzzy inference system (FIS) for adaptive gamma
% adjustment in spacecraft rendezvous control. The fuzzy system maps
% position error (Sv) and angular velocity error (Sw) to a weighting factor
% gamma that adjusts the terminal cost in the MPC framework.
%
% Inputs:
%   None (parameters are hardcoded)
%
% Outputs:
%   gamma_adjuster.fis - generated fuzzy inference system file

% Create Sugeno-type FIS
fis = sugfis('Name', 'gamma_adjuster');

% Add input variable: v_err (position error)
fis = addInput(fis, [0.2 0.5], 'Name', 'v_err');
fis = addMF(fis, 'v_err', 'trimf', [0.2 0.2 0.35], 'Name', 'Low'   , 'VariableType', 'input');
fis = addMF(fis, 'v_err', 'trimf', [0.2 0.35 0.5], 'Name', 'Medium', 'VariableType', 'input');
fis = addMF(fis, 'v_err', 'trimf', [0.35 0.5 0.5], 'Name', 'High'  , 'VariableType', 'input');

% Add input variable: w_err (angular velocity error)
fis = addInput(fis, [0.045 0.095], 'Name', 'w_err');
fis = addMF(fis, 'w_err', 'trimf', [0.045 0.045 0.07], 'Name', 'Low'   , 'VariableType', 'input');
fis = addMF(fis, 'w_err', 'trimf', [0.045 0.07 0.095], 'Name', 'Medium', 'VariableType', 'input');
fis = addMF(fis, 'w_err', 'trimf', [0.07 0.095 0.095], 'Name', 'High'  , 'VariableType', 'input');

% Add output variable: gamma
fis = addOutput(fis, [0 1], 'Name', 'gamma');
fis = addMF(fis, 'gamma', 'linear', [0 0 0], 'Name', 'VeryLow');  % Example: 0*v + 0*w + 0
fis = addMF(fis, 'gamma', 'linear', [0.5 0.3 0.1], 'Name', 'Low'); % a=0.5 (v strong), b=0.3 (w medium), c=0.1
fis = addMF(fis, 'gamma', 'linear', [1.0 0.5 0.5], 'Name', 'Medium');
fis = addMF(fis, 'gamma', 'linear', [1.5 1.0 0.75], 'Name', 'High'); % Adjust coefficients to match logic, high偏向1

% Add rules: [input1 input2 output weight operator], operator=1 is AND
rules = [
    1 1 1 1 1;  % Low v, Low w -> Low
    1 2 1 1 1;  % Low v, Med w -> Low
    1 3 2 1 1;  % Low v, High w -> Med
    2 1 1 1 1;  % Med v, Low w -> Low
    2 2 3 1 1;  % Med v, Med w -> High
    2 3 3 1 1;  % Med v, High w -> High
    3 1 2 1 1;  % High v, Low w -> Med
    3 2 3 1 1;  % High v, Med w -> High
    3 3 3 1 1   % High v, High w -> High
];
fis = addRule(fis, rules);

% Save FIS file
writeFIS(fis, 'gamma_adjuster.fis');

%% Plotting
showplot = false;

%% Plotting
if showplot
    figure;
    subplot(211);
    plotmf(fis,'input',1)
    subplot(212);
    plotmf(fis,'input',2)
end

if showplot
    figure;
    % ===== Fig. X(a): Membership functions of S_v =====
    subplot(211); hold on; grid on;
    x = linspace(0.2, 0.5, 400);
    
    mu_L = trimf(x, [0.2 0.2 0.35]);
    mu_M = trimf(x, [0.2 0.35 0.5]);
    mu_H = trimf(x, [0.35 0.5 0.5]);
    
    plot(x, mu_L, 'LineWidth', 1.5);
    plot(x, mu_M, 'LineWidth', 1.5);
    plot(x, mu_H, 'LineWidth', 1.5);
    
    xlabel('$S_v$', 'Interpreter','latex');
    ylabel('Degree of Membership');
    
    legend({'Low','Medium','High'}, ...
        'Location','NorthWest', ...
        'FontName', 'Times New Roman', ...
        'FontSize', 10);
    
    set(gca, ...
        'FontName','Times New Roman', ...
        'FontSize',12, ...
        'LineWidth',1);

    % ===== Fig. X(b): Membership functions of S_\omega =====
    subplot(212); hold on; grid on;
    x = linspace(0.045, 0.095, 400);
    
    mu_L = trimf(x, [0.045 0.045 0.07]);
    mu_M = trimf(x, [0.045 0.07 0.095]);
    mu_H = trimf(x, [0.07 0.095 0.095]);
    
    plot(x, mu_L, 'LineWidth', 1.5);
    plot(x, mu_M, 'LineWidth', 1.5);
    plot(x, mu_H, 'LineWidth', 1.5);
    
    xlabel('$S_\omega$', 'Interpreter','latex');
    ylabel('Degree of Membership');
    
    legend({'Low','Medium','High'}, ...
        'Location','NorthWest', ...
        'FontName', 'Times New Roman', ...
        'FontSize', 10);
    
    set(gca, ...
        'FontName','Times New Roman', ...
        'FontSize',12, ...
        'LineWidth',1);
end

%% Optional: View FIS structure
if showplot
    figure;
    gensurf(fis);  % View output surface (3D plot, check smoothness)
    set(gca, ...
        'FontName', 'Times New Roman', ...
        'FontSize', 12, ...
        'TickLabelInterpreter', 'latex');
end

if showplot
    Sv = linspace(0.2, 0.5, 60);
    Sw = linspace(0.045, 0.095, 60);
    [SV, SW] = meshgrid(Sv, Sw);
    
    Gamma = zeros(size(SV));

    for i = 1:numel(SV)
        Gamma(i) = evalfis([SV(i), SW(i)], fis);
    end

    % ===== Fig. X(c): Fuzzy input-output surface =====
    figure;
    h = surf(SV, SW, Gamma);
    
    set(h, ...
        'FaceColor', 'interp', ...
        'EdgeColor', [0.3,0.3,0.3], ...
        'LineWidth', 0.5);

    view(135, 30);
    
    xlabel('$S_v$', 'Interpreter','latex');
    ylabel('$S_\omega$', 'Interpreter','latex');
    zlabel('$\gamma$', 'Interpreter','latex');
    
    set(gca, ...
        'FontName','Times New Roman', ...
        'FontSize',12, ...
        'LineWidth',1);
    
    box on;
    grid on; axis tight;

end
