function Plot_monte_carlo_relative_pose_trajectories2(path, total_numbers, varargin)
% PLOT_RELATIVE_POSE_TRAJECTORIES_SUB
% Plot relative position and attitude (MRPs) trajectories in subplots.
% Includes zoom-in insets for the last 50 seconds.
%
% Inputs:
% path - directory path to .mat files
% total_numbers - number of simulation files (1 to total_numbers)
% varargin - optional 'saveFig' (true/false, default false)
p = inputParser;
addParameter(p, 'saveFig', false, @islogical);
parse(p, varargin{:});
saveFig = p.Results.saveFig;
% Create figure
fig = figure('Units','inches','Position',[1 1 8 6]);
Nc = total_numbers*5;
gamma = 0.55;
% map = flip(sky(Nc)); % 原代码，饱和度较低
% map = hsv(Nc); % 之前修改，饱满但偏粉红太亮
map = sky(Nc); % 修改为 parula，柔和蓝-黄渐变
% 或者使用 viridis：map = viridis(Nc); % 另一种柔和渐变（蓝-绿-黄）
idx = round(1 + (Nc-1) * linspace(0,1,total_numbers).^gamma);
colors = map(idx, :);
% colors = sky(total_numbers);
% Subplot 1: Relative position
subplot(211);
hold on; box off;
% Subplot 2: Relative attitude (MRPs)
subplot(212);
hold on; box off;
% Loop over all simulations to compute and plot
r_ct_t_all = cell(total_numbers,1); % Store for insets
s_ct_all = cell(total_numbers,1);
r_ct_d = [0; 0; -5];
for i = 1:total_numbers
    fname = fullfile(path, [num2str(i), '.mat']);
    data = load(fname);
    param = data.param;
    hist = data.hist;
    tspan = (0:1:param.Tsteps) * param.ts;
% Preallocate relative position and attitude arrays
    r_ct_t = zeros(3, param.Tsteps+1); % Relative position in target frame
    s_ct = zeros(3, param.Tsteps+1); % Relative attitude (MRPs)
% Compute relative position
for j = 1:param.Tsteps+1
        R_tl = hist.R_ti{j} * hist.R_li{j}'; % DCM from LVLH to target frame
        R_ts = hist.R_ti{j} * hist.R_si{j}';
        r_ct_t(:,j) = R_tl * hist.xl(7:9,j) + R_ts * param.r_sc - r_ct_d;
end
% Compute relative attitude (MRPs)
for j = 1:param.Tsteps+1
        R_ct = hist.R_ci{j} * hist.R_ti{j}'; % DCM from target to chaser
        s_ct(:,j) = dcm2mrp(R_ct); % Convert DCM to MRP
end
    r_ct_tn = vecnorm(r_ct_t);
    s_ctn = vecnorm(s_ct);
    r_ct_t_all{i} = r_ct_tn;
    s_ct_all{i} = s_ctn;
% Plot relative position in subplot 1
    subplot(211);
    plot(tspan, r_ct_tn, 'Color', colors(i,:), 'LineStyle', '-', 'LineWidth', 1.0, 'DisplayName', ['x_T Sim ' num2str(i)]);
% Plot relative attitude in subplot 2
    subplot(212);
    plot(tspan, s_ctn, 'Color', colors(i,:), 'LineStyle', '-', 'LineWidth', 1.0, 'DisplayName', ['\sigma_{CT,1} Sim ' num2str(i)]);
end
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
% ---- Subplot 2 settings ----
subplot(212);
xlabel('Time (s)', 'FontSize', 12, 'FontName', 'Times New Roman');
ylabel('$$||\mathbf{\sigma}_{CT}||_2$$ (MRPs)', 'FontSize', 12, ...
'FontName', 'Times New Roman', 'Interpreter','latex');
grid on; axis tight;
ylim([min(cellfun(@(x) min(x(:)), s_ct_all))-0.01, max(cellfun(@(x) max(x(:)), s_ct_all))+0.01]);
set(gca, 'FontSize', 12, 'FontName', 'Times New Roman');
% h1 = plot(NaN, NaN, 'Color', [0,0,0], 'LineStyle', '-', 'LineWidth', 1.5, 'DisplayName', '$$\sigma_{CT,1}$$');
% h2 = plot(NaN, NaN, 'Color', [0,0,0], 'LineStyle', ':', 'LineWidth', 1.5, 'DisplayName', '$$\sigma_{CT,2}$$');
% h3 = plot(NaN, NaN, 'Color', [0,0,0], 'LineStyle', '-.', 'LineWidth', 1.5, 'DisplayName', '$$\sigma_{CT,3}$$');
% legend([h1,h2,h3], 'Interpreter','latex', 'FontSize', 10, 'Location','northeast');
% Inset for attitude (σ1, σ2, σ3)
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
% ---- Export figure as PDF if requested ----
if saveFig
    set(gcf, 'PaperPositionMode', 'auto');
    set(gcf, 'Renderer', 'painters');
    figure_name = strcat('figs/relative_pose_trajectories_duration=', ...
                         num2str((param.Tsteps)*param.ts), 's');
    print(fig, figure_name, '-dpdf', '-r600');
end
end