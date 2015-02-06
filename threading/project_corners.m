function [corners1, corners2] = project_corners(im1, im2, H)
%PROJECT_CORNERS - Summary
% Description
%
% TODO:
% - Write documentation
% - "Verify" visually

if nargin < 3
    [ ~, ~, ~, H ] = calculate_homography(im1, im2);
end

corners1 = initialize_corners(im1);
corners2 = initialize_corners(im2);

for i = 1:numel(corners2)
    corner = corners2(i).original;
    corner(3) = 1;
    warning off;
    projected = inv(H) * corner;
    warning on;
    projected = projected ./ projected(3);
    corners2(i).projected = projected(1:2);
end
points = [corners2.projected];
offset = [abs(min(0, min(points(1,:)))) abs(min(0, min(points(2,:))))];
corners1 = move_by_offset(corners1,offset);
corners2 = move_by_offset(corners2,offset);
end

function [ points ] = move_by_offset(points, offset)
for i = 1:numel(points)
    points(i).projected = points(i).projected + offset';
end
end

function [ corners ] = initialize_corners(image)
corners = struct('original',[],'projected',[]);
corners(1).original = [1             1            ]';
corners(2).original = [1             size(image,2)]';
corners(3).original = [size(image,1) size(image,2)]';
corners(4).original = [size(image,1) 1            ]';
for i = 1:numel(corners)
    corners(i).projected = corners(i).original;
end
end
