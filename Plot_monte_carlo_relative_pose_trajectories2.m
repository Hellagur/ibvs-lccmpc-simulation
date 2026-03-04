%% PLOT MONTE CARLO RELATIVE POSE TRAJECTORIES
function Plot_monte_carlo_relative_pose_trajectories2(path, total_numbers, varargin)
% Plot Monte Carlo relative pose trajectories
%
% This function visualizes relative position and attitude (MRPs) trajectories
% from multiple Monte Carlo simulations with zoomed insets for the final time period.
%
% Inputs:
%   path          - directory path to simulation result files
%   total_numbers - number of simulation files
%   varargin     - optional 'saveFig' parameter (true/false, default false)

p = inputParser;
addParameter(p, 'saveFig', false, @islogical);
parse(p, varargin{:});
saveFig = p.Results.saveFig;

% Create figure
fig = figure('Units','inches','Position',[1 1 8 6]);
Nc = total_numbers*5;

gamma = 0.55;
map = sky(Nc);
idx = round(1 + (Nc-1) * linspace(0,1,total_numbers).^gamma);
colors = map(idx, :);

% Subplot 1: Relative position
subplot(211);
hold on; box off;

% Subplot 2: Relative attitude (MRPs)
subplot(212);
hold on; box off;

% Loop over all simulations
r_ct_t_all = cell(total_numbers,1);
s_ct_all = cell(total_numbers,1);
r_ct_d = [0; 0; -5];

for i = 1:total_numbers
    fname = fullfile(path, [num2str(i), '.mat']);
    data = load(fname);
    param = data.param;
    hist = data.hist;
    tspan = (0:1:param.Tsteps) * param.ts;
    
    r_ct_t = zeros(3, param.Tsteps+1);
    s_ct = zeros(3, param.Tsteps+1);
    
    % Compute relative position
    for j = 1:param.Tsteps+1
        R_tl = hist.R_ti{j} * hist.R_li{j}';
        R_ts = hist.R_ti{j} * hist.R_si{j}';
        r_ct_t(:,j) = R_tl * hist.xl(7:9,j) + R_ts * param.r_sc - r_ct_d;
    end
    
    % Compute relative attitude
    for j = 1:param.Tsteps+1
        R_ct = hist.R_ci{j} * hist.R_ti{j}';
        s_ct(:,j) = dcm2mrp(R_ct);
    end
    
    r_ct_tn = vecnorm(r_ct_t);
    s_ctn = vecnorm(s_ct);
    r_ct_t_all{i} = r_ct_tn;
    s_ct_all{i} = s_ctn;
    
    % Plot
    subplot(211);
    plot(tspan, r_ct_tn, 'Color', colors(i,:), 'LineStyle', '-', 'LineWidth', 1.0);
    
    subplot(212);
    plot(tspan, s_ctn, 'Color', colors(i,:), 'LineStyle', '-', 'LineWidth', 1.0);
end

% Subplot 1 settings
subplot(211);
xlabel('Time (s)', 'FontSize', 12, 'FontName', 'Times New Roman');
ylabel('$||\boldmath{\rho}_{TC}-\boldmath{\rho}_{TC}^*||_2$ (m)', 'FontSize', 12, ...
'FontName', 'Times New Roman', 'Interpreter','latex');
grid on; axis tight;
set(gca, 'FontSize', 12, 'FontName', 'Times New Roman');

% ---- Determine zoom-in range (last 50 seconds) ----
zoom_duration = 40.0;
[~, zoom_start_idx] = min(abs(tspan - (tspan(end) - zoom_duration)));
zoom_t = tspan(zoom_start_idx:end);
% ---- Subplot 1 settings ----
subplot(211);
xlabel('Time (s)', 'FontSize', 12, 'FontName', 'Times New Roman');
ylabel('$||\boldmath{\rho}_{TC}-\boldmath{\rho}_{TC}^*||_2$ (m)', 'FontSize', 12, ...
'FontName', 'Times New Roman', 'Interpreter','latex');
grid on; axis tight;
ylim([min(cellfun(@(x) min(x(:)), r_ct_t_all))-1, max(cellfun(@(x) max(x(:)), r_ct_t_all))+1]);
set(gca, 'FontSize', 12, 'FontName', 'Times New Roman');
% Inset for x,y
idx1 = 421:461;
zoom_t1 = tspan(idx1);
ax_inset_xy = axes('Position', [0.69, 0.79, 0.15, 0.10]); hold on; box on;
for i = 1:total_numbers
    r_ct_tn = r_ct_t_all{i};
    plot(zoom_t1, r_ct_tn(idx1), 'Color', colors(i,:), 'LineStyle', '-', 'LineWidth', 1.0);
end
plot(zoom_t1, 0.02*ones(size(zoom_t1)), 'Color', '#666666', 'LineStyle', '--', 'LineWidth', 1.0);
set(ax_inset_xy,'FontSize',10,'FontName','Times New Roman');
ax_inset_xy.YAxis.Exponent = 0; % Disable scientific notation
grid on; axis tight;
xlim([zoom_t1(1), zoom_t1(end)]);
ylim([-0.01,0.03]);
% Inset for z
ax_inset_z = axes('Position', [0.69, 0.64, 0.15, 0.10]); hold on; box on;
for i = 1:total_numbers
    r_ct_tn = r_ct_t_all{i};
    plot(zoom_t, r_ct_tn(zoom_start_idx:end), 'Color', colors(i,:), 'LineStyle', '-', 'LineWidth', 1.0);
end
set(ax_inset_z,'FontSize',10,'FontName','Times New Roman');
ax_inset_z.YAxis.Exponent = 0;
% title('$$z_T$$', 'Interpreter', 'latex', 'FontSize', 10);
grid on; axis tight;

% Subplot 2 settings
subplot(212);
xlabel('Time (s)', 'FontSize', 12, 'FontName', 'Times New Roman');
ylabel('$$||\boldmath{\sigma}_{CT}||_2$$ (MRPs)', 'FontSize', 12, ...
'FontName', 'Times New Roman', 'Interpreter','latex');
grid on; axis tight;
set(gca, 'FontSize', 12, 'FontName', 'Times New Roman');

ax_inset_att1 = axes('Position', [0.69, 0.30, 0.15, 0.10]); hold on; box on;
for i = 1:total_numbers
    s_ctn = s_ct_all{i};
    plot(zoom_t1, s_ctn(idx1), 'Color', colors(i,:), 'LineStyle', '-', 'LineWidth', 1.0);
end
plot(zoom_t1, 0.01*ones(size(zoom_t1)), 'Color', '#666666', 'LineStyle', '--', 'LineWidth', 1.0);
set(ax_inset_att1,'FontSize',10,'FontName','Times New Roman');
ax_inset_att1.YAxis.Exponent = 0; % Disable scientific notation
grid on; axis tight;
xlim([zoom_t1(1), zoom_t1(end)]);
ylim([-0.01,0.05]);
ax_inset_att = axes('Position', [0.69, 0.15, 0.15, 0.10]); hold on; box on;
for i = 1:total_numbers
    s_ctn = s_ct_all{i};
    plot(zoom_t, s_ctn(zoom_start_idx:end), 'Color', colors(i,:), 'LineStyle', '-', 'LineWidth', 1.0);
end
set(ax_inset_att,'FontSize',10,'FontName','Times New Roman');
ax_inset_att.YAxis.Exponent = 0;
grid on; axis tight;

% Export figure if requested
if saveFig
    set(gcf, 'PaperPositionMode', 'auto');
    set(gcf, 'Renderer', 'painters');
    figure_name = strcat('figs/relative_pose_trajectories_duration=', ...
                         num2str((param.Tsteps)*param.ts), 's');
    print(fig, figure_name, '-dpdf', '-r600');
end
end
