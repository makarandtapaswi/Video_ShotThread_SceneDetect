function elbowPt = elbowDetect(curve, plotme)
%ELBOWDETECT - Find the elbow point given a curve - for example useful for determining cutoff point for clustering
% ELBOWDETECT uses a technique joining the first and last point of the
% curve and then computes the distance parallel to the perpendicular to 
% this line for each point. 

% Copyright (C) 2011 CVHCI-KIT


% Sample example - uncomment the following lines
% curve = [8.4663 8.3457 5.4507 5.3275 4.8305 4.7895 4.6889 4.6833 4.6819 4.6542 4.6501 4.6287 4.6162 4.585 4.5535 4.5134 4.474 4.4089 4.3797 4.3494 4.3268 4.3218 4.3206 4.3206 4.3203 4.2975 4.2864 4.2821 4.2544 4.2288 4.2281 4.2265 4.2226 4.2206 4.2146 4.2144 4.2114 4.1923 4.19 4.1894 4.1785 4.178 4.1694 4.1694 4.1694 4.1556 4.1498 4.1498 4.1357 4.1222 4.1222 4.1217 4.1192 4.1178 4.1139 4.1135 4.1125 4.1035 4.1025 4.1023 4.0971 4.0969 4.0915 4.0915 4.0914 4.0836 4.0804 4.0803 4.0722 4.065 4.065 4.0649 4.0644 4.0637 4.0616 4.0616 4.061 4.0572 4.0563 4.056 4.0545 4.0545 4.0522 4.0519 4.0514 4.0484 4.0467 4.0463 4.0422 4.0392 4.0388 4.0385 4.0385 4.0383 4.038 4.0379 4.0375 4.0364 4.0353 4.0344];
% plotme = 1;

if ~exist('plotme','var'), plotme = 0; end % default set to plot

%% Find elbow point
% get coordinates of all the points
numPoints = length(curve);
allCoord = [1:numPoints;curve]';

% pull out first point
firstPoint = allCoord(1,:);

% get normalized vector between first and last point - this is the line
lineVec = allCoord(end,:) - firstPoint;
lineVecNorm = lineVec / sqrt(sum(lineVec.^2));

% find the distance from each point to the line:
vecFromFirstPt = bsxfun(@minus, allCoord, firstPoint);

% take dot product between projection and first-last point direction
scalarProduct = dot(vecFromFirstPt, repmat(lineVecNorm,[numPoints,1]), 2);
fromParallel = scalarProduct*lineVecNorm;

% finally, vector between parallel line to all points is
vecToLine = vecFromFirstPt - fromParallel;
distToLine = sqrt(sum(vecToLine.^2,2));
[~,elbowPt] = max(distToLine);

%% Drawing

if plotme, 
    figure(1), 
    plot(distToLine); title('Distance to the line');
    figure, hold on;
    plot(curve); title('Original input curve');
    plot(allCoord(elbowPt,1), allCoord(elbowPt,2),'or','LineWidth',5)
end

end