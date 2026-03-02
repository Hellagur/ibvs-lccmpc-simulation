function fig = Plot_relative_pose_error_compare(file1, file2, file3)
    
    data1 = load(file1);
    hist1 = data1.hist;
    param = data1.param;
    tspan = 0:param.ts:param.ts*param.Tsteps;

    data2 = load(file2);
    hist2 = data2.hist;
    
    data3 = load(file3);
    hist3 = data3.hist;
    
    % Preallocate relative position and attitude arrays
    r_ct_t1 = zeros(3, param.Tsteps+1);  % Relative position in target frame
    s_ct1   = zeros(3, param.Tsteps+1);  % Relative attitude (MRPs)

    r_ct_t2 = zeros(3, param.Tsteps+1);  % Relative position in target frame
    s_ct2   = zeros(3, param.Tsteps+1);  % Relative attitude (MRPs)

    r_ct_t3 = zeros(3, param.Tsteps+1);  % Relative position in target frame
    s_ct3   = zeros(3, param.Tsteps+1);  % Relative attitude (MRPs)

    %% ---- Compute relative position ----
    for i = 1:param.Tsteps+1
        R_tl = hist1.R_ti{i} * hist1.R_li{i}';     % DCM from LVLH to target frame
        R_ts = hist1.R_ti{i} * hist1.R_si{i}';
        r_ct_t1(:,i) = R_tl * hist1.xl(7:9,i) + R_ts * param.r_sc;

        R_tl = hist2.R_ti{i} * hist2.R_li{i}';     % DCM from LVLH to target frame
        R_ts = hist2.R_ti{i} * hist2.R_si{i}';
        r_ct_t2(:,i) = R_tl * hist2.xl(7:9,i) + R_ts * param.r_sc;

        R_tl = hist3.R_ti{i} * hist3.R_li{i}';     % DCM from LVLH to target frame
        R_ts = hist3.R_ti{i} * hist3.R_si{i}';
        r_ct_t3(:,i) = R_tl * hist3.xl(7:9,i) + R_ts * param.r_sc;
    end

    r_ct_d = [0; 0; -5];

    r_ct_tn1 = vecnorm(r_ct_t1 - r_ct_d);
    r_ct_tn2 = vecnorm(r_ct_t2 - r_ct_d);
    r_ct_tn3 = vecnorm(r_ct_t3 - r_ct_d);

    r_ct_end1 = norm(r_ct_t1(:,end) - r_ct_d);
    r_ct_end2 = norm(r_ct_t2(:,end) - r_ct_d);
    r_ct_end3 = norm(r_ct_t3(:,end) - r_ct_d);

    fprintf("terminal postion error: %f, %f, %f\n", r_ct_end1, r_ct_end2, r_ct_end3);

    %% ---- Compute relative attitude (MRPs) ----
    for i = 1:param.Tsteps+1
        R_ct = hist1.R_ci{i} * hist1.R_ti{i}';      % DCM from target to chaser
        s_ct1(:,i) = dcm2mrp(R_ct);                 % Convert DCM to MRP

        R_ct = hist2.R_ci{i} * hist2.R_ti{i}';      % DCM from target to chaser
        s_ct2(:,i) = dcm2mrp(R_ct);                 % Convert DCM to MRP

        R_ct = hist3.R_ci{i} * hist3.R_ti{i}';      % DCM from target to chaser
        s_ct3(:,i) = dcm2mrp(R_ct);                 % Convert DCM to MRP
    end

    s_ctn1 = vecnorm(s_ct1);
    s_ctn2 = vecnorm(s_ct2);
    s_ctn3 = vecnorm(s_ct3);

    s_ctd = [0;0;0];
    s_ct_end1 = norm(s_ct1(:,end) - s_ctd);
    s_ct_end2 = norm(s_ct2(:,end) - s_ctd);
    s_ct_end3 = norm(s_ct3(:,end) - s_ctd);

    fprintf("terminal attitude error: %f, %f, %f\n", s_ct_end1, s_ct_end2, s_ct_end3);

    fig = figure('Units','inches','Position',[1 1 8 6]);

    %% position
    subplot(211); hold on;
    plot(tspan, r_ct_tn1, 'r', 'DisplayName', '$\gamma$ Adaptive', 'LineWidth', 1.5);
    plot(tspan, r_ct_tn3, 'b--', 'DisplayName', '$\gamma \equiv 1$', 'LineWidth', 1.5);
    plot(tspan, r_ct_tn2, 'k-.', 'DisplayName', '$\gamma \equiv 0$', 'LineWidth', 1.5);
    grid on; axis tight;
    xlabel('Time (s)', 'FontSize', 12, 'FontName', 'Times New Roman');
    ylabel('$||\boldmath{\rho}_{TC} - \boldmath{\rho}_{TC}^*||_2$ (m)', 'FontSize', 12, ...
           'FontName', 'Times New Roman', 'Interpreter','latex');
    legend('Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 10);
    set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);

    % Inset for x,y
    zoom_idx1 = 141:221;
    zoom_t1 = tspan(zoom_idx1);
    
    ax_inset_xy = axes('Position', [0.38, 0.64, 0.20, 0.10]); hold on; box on;
    plot(zoom_t1, r_ct_tn1(zoom_idx1), 'r-', 'LineWidth', 1.5);
    plot(zoom_t1, r_ct_tn2(zoom_idx1), 'k-.', 'LineWidth', 1.5);
    plot(zoom_t1, 0.02*ones(size(zoom_t1)), 'Color', '#666666', 'LineWidth', 1.0, 'LineStyle', '--');
    % plot(zoom_t1, 4.99*ones(size(zoom_t1)), 'Color', '#666666', 'LineWidth', 1.0, 'LineStyle', '--');
    set(gca,'FontSize',10,'FontName','Times New Roman');
    ax_inset_xy.YAxis.Exponent = 0;  % Disable scientific notation
    grid on; axis tight;
    xticks(70:10:110);
    yticks(0:0.02:0.05);
    ylim([0,0.05])

    % Inset for x,y,z
    zoom_duration = 40.0;
    [~, zoom_start_idx] = min(abs(tspan - (tspan(end) - zoom_duration)));
    zoom_t = tspan(zoom_start_idx:end);
    
    ax_inset_xyz = axes('Position', [0.65, 0.64, 0.20, 0.10]); hold on; box on;
    plot(zoom_t, r_ct_tn1(zoom_start_idx:end), 'r-', 'LineWidth', 1.5);
    plot(zoom_t, r_ct_tn2(zoom_start_idx:end), 'k-.', 'LineWidth', 1.5);
    plot(zoom_t, r_ct_tn3(zoom_start_idx:end), 'b--', 'LineWidth', 1.5);
    set(gca,'FontSize',10,'FontName','Times New Roman');
    ax_inset_xyz.YAxis.Exponent = 0;
    grid on; axis tight;
    

    %% attitude
    subplot(212); hold on;
    plot(tspan, s_ctn1, 'r', 'DisplayName', '$\gamma$ Adaptive', 'LineWidth', 1.5);
    plot(tspan, s_ctn3, 'b--', 'DisplayName', '$\gamma \equiv 1$', 'LineWidth', 1.5);
    plot(tspan, s_ctn2, 'k-.', 'DisplayName', '$\gamma \equiv 0$', 'LineWidth', 1.5);
    grid on; axis tight;
    xlabel('Time (s)', 'FontSize', 12, 'FontName', 'Times New Roman');
    ylabel('$||\mathbf{\sigma}_{CT}||_2$ (MRPs)', 'FontSize', 12, ...
           'FontName', 'Times New Roman', 'Interpreter','latex');
    legend('Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 10);
    set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);

    % Inset for x,y
    ax_inset_xy = axes('Position', [0.38, 0.22, 0.20, 0.10]); hold on; box on;
    plot(zoom_t1, s_ctn1(zoom_idx1), 'r-', 'LineWidth', 1.5);
    plot(zoom_t1, s_ctn2(zoom_idx1), 'k-.', 'LineWidth', 1.5);
    plot(zoom_t1,  0.01*ones(size(zoom_t1)), 'Color', '#666666', 'LineWidth', 1.0, 'LineStyle', '--');
    set(gca,'FontSize',10,'FontName','Times New Roman');
    ax_inset_xy.YAxis.Exponent = 0;  % Disable scientific notation
    grid on; axis tight;
    xticks(70:10:110);
    yticks(0:0.02:0.05);
    ylim([-0.01,0.05])

    % Inset for x,y,z
    ax_inset_xyz = axes('Position', [0.65, 0.22, 0.20, 0.10]); hold on; box on;
    plot(zoom_t, s_ctn1(zoom_start_idx:end), 'r-', 'LineWidth', 1.5);
    plot(zoom_t, s_ctn2(zoom_start_idx:end), 'k-.', 'LineWidth', 1.5);
    plot(zoom_t, s_ctn3(zoom_start_idx:end), 'b--', 'LineWidth', 1.5);
    set(gca,'FontSize',10,'FontName','Times New Roman');
    ax_inset_xyz.YAxis.Exponent = 0;
    grid on; axis tight;
    yticks(0.01:0.04:0.13)

end