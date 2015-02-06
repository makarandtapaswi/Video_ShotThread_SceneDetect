function [decision, data] = are_images_similar(im1, im2, params, debug)
%ARE_SHOTS_SIMILAR - Shot threading based on homography via SIFT
% Based on the code used by Sebastian Geiger to thread shots
%
% Last modified: 13-02-2013

if ~exist('debug', 'var')
    debug = false;
end

% Compute homography
[has_homography, x1, x2, H, matched_keypoints] = calculate_homography(im1, im2);

if has_homography
    % If a homography is found, compute movement and projections and then make a
    % decision as to whether the shots are similar or not
    data.H = H;
    data.x1 = x1;
    data.x2 = x2;
    data.matched_keypoints = matched_keypoints;
    data.absolute_number_matches = sum(matched_keypoints);
    
    % Compute movement of corners
    [corners_1, corners_2] = project_corners(im1, im2, H);
    data.movement = calculate_single_movement(corners_1, im1) + calculate_single_movement(corners_2, im2);
   
    % Make the decision based on number of matches and movement
    decision = data.absolute_number_matches >= params.shot_similarity.num_matches ...
                           && data.movement <  params.shot_similarity.allowable_movement;

    if debug
        vgg_gui_H(im1, im2, H);
        pause;
    end

else
    decision = false;
    % Generate an empty data structure and return
    data = struct('x1', [], 'x2', [], 'matched_keypoints', [], 'H', [], 'movement', [], 'absolute_number_matches', -1);
end

end

function movement = calculate_single_movement(corners, image)
% Calculate how much the image should be moved to match perfectly
movement = 0;
for i = 1:numel(corners)
    corner = corners(i);
    movement = movement + abs(corner.projected(1) - corner.original(1))/size(image,1);
    movement = movement + abs(corner.projected(2) - corner.original(2))/size(image,2);
end
end
