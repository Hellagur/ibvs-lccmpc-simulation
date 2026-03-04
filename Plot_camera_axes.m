%% PLOT CAMERA AXES
function Plot_camera_axes(origin, R, scale, color, alpha)
% Visualize 3D camera frustum in world coordinates
%
% This function draws a simplified 3D camera model represented by a 
% viewing frustum and image plane, given the camera's position, orientation, 
% and scaling factor.
%
% Inputs:
%   origin - 3×1 camera center position in world coordinates
%   R      - 3×3 rotation matrix (camera frame to world frame)
%   scale  - scaling factor defining focal length and image plane size
%   color  - 1×3 RGB vector specifying frustum color
%   alpha  - scalar in [0,1], transparency of image plane
%
% Outputs:
%   None (displays in current axes)

    if nargin < 5, alpha = 0.5; end

    % Camera intrinsic geometry
    f = scale;
    w = 0.640 * scale;
    h = 0.512 * scale;

    % Image plane corners in camera coordinates
    p1 = [ w/2  h/2  f]';
    p2 = [-w/2  h/2  f]';
    p3 = [-w/2 -h/2  f]';
    p4 = [ w/2 -h/2  f]';

    % Transform to world coordinates
    z_len = 0.3;
    pos_rel = R * [0; 0; z_len];
    origin = origin + pos_rel;
    p1 = origin + R * p1;
    p2 = origin + R * p2;
    p3 = origin + R * p3;
    p4 = origin + R * p4;

    % Draw image plane
    patch('XData', [p1(1), p2(1), p3(1), p4(1)], ...
          'YData', [p1(2), p2(2), p3(2), p4(2)], ...
          'ZData', [p1(3), p2(3), p3(3), p4(3)], ...
          'FaceColor', color, 'FaceAlpha', alpha, ...
          'EdgeColor', 'k');

    % Draw frustum lines
    line([origin(1) p1(1)], [origin(2) p1(2)], [origin(3) p1(3)], 'Color', color);
    line([origin(1) p2(1)], [origin(2) p2(2)], [origin(3) p2(3)], 'Color', color);
    line([origin(1) p3(1)], [origin(2) p3(2)], [origin(3) p3(3)], 'Color', color);
    line([origin(1) p4(1)], [origin(2) p4(2)], [origin(3) p4(3)], 'Color', color);

    % Draw camera center
    plot3(origin(1), origin(2), origin(3), 'ko', ...
          'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k', 'MarkerSize', 2);
end
