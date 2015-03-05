% ALL PARAMETERS FILE

%% Shot descriptors
% RGB histogram
params.descriptor.rgbhist.use = true;
params.descriptor.rgbhist.bins3d = 6;

%% Shot Similarity Parameters
% Shot similarity based on homography
params.shot_similarity.allowable_movement = 1; % normalized movement of the corners to match images
params.shot_similarity.num_matches = 20; % number of required SIFT matches
params.shot_similarity.lookahead = 24; % default of the "range" easily parfor with 12x2
