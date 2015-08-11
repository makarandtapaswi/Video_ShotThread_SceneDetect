function [meanrgbhist, keyframes] = low_level_shot_similarity(VideoStruct, params)
%LOW_LEVEL_SHOT_SIMILARITY Checks for similar shots over a short range
% Perform shot similarity matching with multiple low-level features
%   * RGB histograms
% 
% Author: Makarand Tapaswi
% Last modified: 20-02-2013


%%% RGB 3D Histogram (mean of all frames in the shot)
mean_rgbhist_cache_fname = sprintf(VideoStruct.cache.rgbhist, 'mean', params.descriptor.rgbhist.bins3d^3);
try
    fprintf('Loaded mean RGB histograms... ');
    load(mean_rgbhist_cache_fname);
    fprintf('Success\n');
catch
    fprintf('Failed\n');
    fprintf('Computing RGB histograms... \n');

    %%% NOTE: THIS CODE NEEDS MODIFICATION BASED ON THE WAY IMAGES ARE READ FROM THE VIDEO
    iseq = read_video_sequence(VideoStruct);
    VE = get_video_events(VideoStruct);
    ShotStartEnd = videoevents_to_shots(iseq, VE);
    keyframes = round(mean(ShotStartEnd, 2));
    num_shots = length(keyframes);

    meanrgbhist = zeros(num_shots, params.shot_similarity.rgbhist.bins3d^3, 1);
    nd_hist_params = [0, 255, params.descriptor.rgbhist.bins3d];
    fprintf('%4d/%4d\n', 0, num_shots);
    for ii = 1:num_shots % for each shot
        fprintf('\b\b\b\b\b\b\b\b\b\b%4d/%4d\n', ii, num_shots);
        list_frames = ShotStartEnd(ii, 1):ShotStartEnd(ii, 2);
        for jj = 1:length(list_frames) % for each frame in the shot
            % get image (needs modification!)
            im = iseq_imread(iseq, list_frames(jj));
            % compute histogram
            clhist = imhist_nd_fast(double(im), repmat(nd_hist_params, [size(im, 3), 1]));
            % accumulate normalized histogram (no truncation)
            meanrgbhist(ii, :) = meanrgbhist(ii, :) + normalize_3d_hist(clhist, 1).';
        end
        meanrgbhist(ii, :) = meanrgbhist(ii, :)/length(list_frames);
    end
    % save mean histogram
    save(mean_rgbhist_cache_fname, 'meanrgbhist', 'keyframes');
end

end

