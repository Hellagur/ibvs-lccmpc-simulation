function style = Plot_style()
%PLOT_STYLE Shared color and line style definitions for paper figures.

    style.feature = [231  76  60;
                      46 204 113;
                      52 152 219;
                     241 196  15] ./ 255;

    style.method.adaptive = style.feature(1,:);
    style.method.gamma0   = style.feature(2,:);
    style.method.gamma1   = style.feature(3,:);

    style.methodLine.adaptive = '-';
    style.methodLine.gamma0   = '-.';
    style.methodLine.gamma1   = '--';

    style.axis = [231  76  60;
                   46 204 113;
                   52 152 219] ./ 255;
    style.axisLine = {'-', '-.', '--'};

    style.neutral.grid      = [0.85 0.85 0.85];
    style.neutral.axis      = [0.40 0.40 0.40];
    style.neutral.threshold = [0.40 0.40 0.40];
    style.neutral.bg        = [0.99 0.99 0.99];
    style.neutral.dark      = [0.10 0.10 0.10];
    style.neutral.mid       = [0.45 0.45 0.45];
    style.neutral.light     = [0.70 0.76 0.82];

    style.state.desired = [255 153 102] ./ 255;
    style.state.initial = [1.00 0.00 0.00];
    style.state.terminal = [0.00 0.65 0.00];
    style.state.plane = [0.72 0.82 0.92;
                         0.78 0.78 0.78;
                         0.96 0.72 0.62];
    style.state.planeAlpha = [0.52 0.18 0.52];
    style.state.poseBox = [0.35 0.62 0.82];
    style.state.attBox  = [0.38 0.70 0.68];
    style.state.boxWhisker = [0.35 0.35 0.35];
    style.state.boxMedian = [1.00 0.00 1.00];

    style.camera.body = [0.82 0.82 0.82];
    style.camera.lens = [0.50 0.50 0.50];
    style.camera.frustum = [0.20 0.60 1.00];

    style.alert = [0.80 0.15 0.12];
    style.highlight = [1.00 0.00 1.00];
    style.cmap = @parula;
    style.mcPoseCmap = @(n) local_colormap([0.10 0.25 0.60;
                                             0.05 0.50 0.72;
                                             0.18 0.62 0.52], n);
    style.mcPoseAlpha = 0.18;
    style.mcPoseInsetAlpha = 0.22;
    style.lineWidth = 1.5;
    style.lineWidthThin = 1.0;
end

function cmap = local_colormap(stops, n)
    if n <= 1
        cmap = stops(1,:);
        return;
    end

    x = linspace(0, 1, size(stops, 1));
    xi = linspace(0, 1, n);
    cmap = interp1(x, stops, xi, 'linear');
end
