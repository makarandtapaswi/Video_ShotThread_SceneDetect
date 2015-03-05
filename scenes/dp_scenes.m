function scene_break = dp_scenes(VideoStruct, params, varargin)
%DP_SCENES Get scenes using dynamic programming
%
% nscenes: number of max scenes to which DP forward computation happens
% backtrack_n: Can easily truncate by choosing an appropriate row to start backtracking
% auto_scenecount: 'elbow' | 'diff1'
%
% Output scene_break contains:
% [start_shot, end_shot, number_of_shots] (one row per scene)
%
% Author: Makarand Tapaswi
% Last modified: 09-10-2013

%% Load necessary data
sse = videoevents_to_shots(VideoStruct);

%%% RGB histogram distances
try
    nbins = params.descriptor.rgbhist.bins3d^3;
    load(sprintf(VideoStruct.cache.rgbhist, 'mean', nbins));
    hashtab = java.util.Hashtable;
    % Magic distance to score computation sigmoid values for "a" and "b"
    mySigmoid_a = -13.7814;
    mySigmoid_b = -2.8316;
    % The above were computed by fitting mean/std on the distances of randomly
    % created instances of "prev_shots" and "this_shot"! Good times... :)
catch
    error('Mean RGB histograms distance does not exist. See compute_low_level_shot_similarity first');
end

%%% Load/Compute threading
sim = shot_similarity(VideoStruct, params);
[~, sa] = similarity_to_threads(sim);

%% Scenes forward "cost" matrix
% Process default options
dopts.nscenes = floor(size(sse, 1)/5);
dopts.backtrack_n = -1;
dopts.auto_scenecount = 'diff1';
dopts.diff1_thresh = 0.8;
dopts.display = false;
opts = cvhci_process_options(varargin, dopts);

% Setup layers (max num shots in any scene)
nshots = size(sse, 1);
nlayers = 100;
% alpha (in the paper)
fall_down_curve = 1 - 0.5*((1:nlayers).^2 / nlayers.^2);

nr = opts.nscenes + 1; nc = nshots + 1;
cache_fname = sprintf(VideoStruct.cache.scenes_dtw3d, nr, nc, nlayers, nbins);
try
    fprintf('Loading cost matrix from cache... ');
    load(cache_fname);
    fprintf('Success\n');
catch
    fprintf('Failed\n');
    % Forward pass
    dtw_cube = zeros(nr, nc, nlayers);
    idx_cube = zeros(nr, nc, nlayers);
    fprintf('%4d/%4d\n', 0, nr-1);
    for ii = 2:nr % potential number of scenes
        fprintf('%4d/%4d\n', ii-1, nr-1);
        for jj = 2:nc % over all shots
            fprintf('.');
            for kk = 1:min(jj, nlayers) % for each layer (kk-1 shots assigned to previous scene)
                if kk == 1
                    % max previous score
                    cubeind = [repmat(ii-1, nlayers, 1), repmat(jj-1, nlayers, 1), (1:nlayers)'];
                    linearind = sub2ind(size(dtw_cube), cubeind(:, 1), cubeind(:, 2), cubeind(:, 3));
                    % start a new scene score
                    new_scene_score = zeros(size(cubeind, 1), 1);
                    this_shot = jj-1;
                    for loc = 1:size(cubeind, 1)
                        prev_shots = (cubeind(loc, 2)) - (1 : (cubeind(loc, 3)));
                        prev_shots = prev_shots(prev_shots > 0);
                        if isempty(prev_shots), continue; end
                        %-% rgb histogram score
                        key = num2str(prev_shots);
                        if hashtab.containsKey(key)
                            % subtract, since we store +ve scores for same-scene
                            % basically, the higher the distance, better it is to start a new scene
                            % or, the lower the score (similarity), better to start a new scene
                            new_scene_score(loc) = 1 - hashtab.get(key);
                        else
                            shotdist = mean(pdist2(meanrgbhist(prev_shots, :), meanrgbhist(this_shot, :)));
                            shotscore = mySigmoid(shotdist, mySigmoid_b, mySigmoid_a);
                            hashtab.put(key, shotscore);
                            new_scene_score(loc) = 1 - shotscore;
                        end
                        %-% threading score
                        if sa(this_shot) ~= 1 && any(sa(prev_shots) == sa(this_shot))
                            % if this shot is a part of thread, and IS linked
                            % with any previous shot, then do not split!
                            new_scene_score(loc) = max(0, new_scene_score(loc) - 1);
                        else
                            new_scene_score(loc) = new_scene_score(loc);
                        end
                        %-% prevent really short scenes, use flipped alpha
                        new_scene_score(loc) = new_scene_score(loc) * fall_down_curve(end-length(prev_shots)+1);
                    end
                    % add it to cube
                    [max_score, max_idx] = max(dtw_cube(linearind) + new_scene_score);
                    dtw_cube(ii, jj, kk) = max_score;
                    idx_cube(ii, jj, kk) = linearind(max_idx);
                else
                    % continue same scene score
                    this_shot = jj-1;
                    prev_shots = (jj-1) - (1 : (kk-1));
                    prev_shots = prev_shots(prev_shots > 0);
                    if isempty(prev_shots), continue; end
                    %-% rgb histogram score
                    key = num2str(prev_shots);
                    if hashtab.containsKey(key)
                        same_scene_score = hashtab.get(key);
                    else
                        shotdist = mean(pdist2(meanrgbhist(prev_shots, :), meanrgbhist(this_shot, :)));
                        same_scene_score = mySigmoid(shotdist, mySigmoid_b, mySigmoid_a);
                        hashtab.put(key, same_scene_score);
                    end
                    %-% threading score
                    if sa(this_shot) ~= 1
                        same_scene_score = same_scene_score + sum(sa(prev_shots) == sa(this_shot));
                    end
                    % add it to cube
                    dtw_cube(ii, jj, kk) = dtw_cube(ii, jj-1, kk-1) + same_scene_score*fall_down_curve(kk);
                    idx_cube(ii, jj, kk) = sub2ind(size(dtw_cube), ii, jj-1, kk-1);
                end
            end
        end
        fprintf('\n');
    end
    save(cache_fname, 'dtw_cube', 'idx_cube', 'nr', 'nc', 'nlayers');
end

%% Backtrack the path
% if number of scenes is not specified, try to determine automatically
if opts.backtrack_n == -1
    vec = (max(squeeze(dtw_cube(:, end, :)), [], 2));
    if strcmp(opts.auto_scenecount, 'elbow')
        opts.backtrack_n = elbowDetect(vec');
    elseif strcmp(opts.auto_scenecount, 'diff1')
        opts.backtrack_n = find(diff(vec) < opts.diff1_thresh, 1, 'first');
    end
end

% initialize backtracking based on above thresholded number of scenes
ii = opts.backtrack_n + 1; jj = nc;
[~, kk] = max(squeeze(dtw_cube(ii, jj, :)));
path = [ii-1, jj-1, kk, dtw_cube(ii, jj, kk)];
while ii > 1 && jj > 1 % until the first 1,1 is reached
    loc = idx_cube(ii, jj, kk);
    if isnan(loc), keyboard; end
    [ii, jj, kk] = ind2sub(size(dtw_cube), idx_cube(ii, jj, kk));
    % add point to path
    path = [[ii-1, jj-1, kk, dtw_cube(ii, jj, kk)]; path]; %#ok
end
path(1, :) = [];

%% Create scene boundaries
scene_break = 1;
for k = 1:size(path, 1)
    if length(scene_break) ~= path(k, 1)
        scene_break = [scene_break, k];
    end
end

scene_break = [scene_break', [scene_break(2:end)'-1; size(sse, 1)]];
scene_break = [scene_break,   scene_break(:, 2) - scene_break(:, 1) + 1];
% print the list of scenes
if opts.display
    fprintf('Shot start, shot end, scene length\n');
    disp(scene_break);
end

% Bye! :)
end
