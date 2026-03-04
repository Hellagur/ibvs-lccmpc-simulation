%% PLOT CAMERA MODEL
function Plot_camera_model(origin, R, scale, bodyColor, lensColor)
% Draw 3D camera model at specified pose
%
% This function visualizes a 3D camera body composed of a rectangular 
% cube (main body) and a short cylinder (lens). The model is oriented 
% along the camera's local +z axis.
%
% Inputs:
%   origin     - 3×1 camera center position in world coordinates
%   R          - 3×3 rotation matrix (camera-to-world transformation)
%   scale      - scaling factor controlling overall model size
%   bodyColor  - 1×3 RGB vector for camera body color
%   lensColor  - 1×3 RGB vector for lens color
%
% Outputs:
%   None (displays in current axes)

    if nargin < 5
        lensColor = [0.5 0.5 0.5];
    end
    if nargin < 4
        bodyColor = [0.8 0.8 0.8];
    end
    if nargin < 3
        scale = 1.0;
    end

    % Create camera body (cube)
    % Cube centered around (0,0,-0.025) in the camera frame
    z_len = 0.02;
    [Xb, Yb, Zb] = meshgrid([-0.025 0.025], [-0.025 0.025], [-z_len, z_len]);
    Xb = scale * Xb(:)'; 
    Yb = scale * Yb(:)';
    Zb = scale * Zb(:)';

    % Transform vertices into world coordinates
    verts = [Xb; Yb; Zb];
    verts = R * verts + origin;

    % Define cube faces
    faces = [
        1 2 4 3;   % Front
        5 6 8 7;   % Back
        1 2 6 5;   % Top
        3 4 8 7;   % Bottom
        1 3 7 5;   % Left
        2 4 8 6    % Right
    ];

    % Draw cube (camera body)
    patch('Vertices', verts', 'Faces', faces, ...
          'FaceColor', bodyColor, 'EdgeColor', 'k', 'FaceAlpha', 0.6);

    % Create camera lens (cylinder)
    [Xc, Yc, Zc] = cylinder(0.02 * scale, 20);
    Zc = Zc * 0.03 * scale;
    lensPoints = [Xc(:)'; Yc(:)'; Zc(:)'];

    % Rotate and translate lens
    pos_rel = R * [0; 0; z_len*scale];
    lensPoints = R * lensPoints + origin + pos_rel;
    Xc_new = reshape(lensPoints(1,:), size(Xc));
    Yc_new = reshape(lensPoints(2,:), size(Yc));
    Zc_new = reshape(lensPoints(3,:), size(Zc));

    % Draw lens cylinder
    surf(Xc_new, Yc_new, Zc_new, ...
         'FaceColor', lensColor, 'EdgeColor', 'none', 'FaceAlpha', 0.6);

    % Draw front cap outline
    theta = linspace(0, 2*pi, 100);
    r = 0.02 * scale;
    xc = r * cos(theta);
    yc = r * sin(theta);
    zc = ones(size(theta)) * 0.03 * scale;
    cap = R * [xc; yc; zc] + origin + pos_rel;

    plot3(cap(1,:), cap(2,:), cap(3,:), 'k', 'LineWidth', 0.5);
end
