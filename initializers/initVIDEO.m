function VideoStruct = initVIDEO(video_name, varargin)
%INITVIDEO - Returns VideoStructure array for list of input video names
% Usually called by other stuff, although it can also be called directly.
% Examples:
%   video_name = 'bbt_s01e01', 'buffy_s05e01', 'got_s01e01'
%
% length(varargin) == 2, {season, episode}
%
% This code adds or calls the adders of stuff to the video structure
% ADD: video_info, labels, cache

global VIDEOEVENTS

%% Process arguments
default_args.series = '';
default_args.season = [];
default_args.episode = [];
default_args.movie = [];
VideoStruct = cvhci_process_options(varargin, default_args);

%% Add all the information
VideoStruct.name = video_name;

%%% data file name templates
VideoStruct.data.img_fname =   [VIDEOEVENTS.base_dir, 'data/', video_name, '_excerpt/', video_name, '_%06d.jpg'];
VideoStruct.data.shot_bdry =   [VIDEOEVENTS.base_dir, 'data/shot_boundaries/', video_name, '.videvents'];

%% Cache file name templates
%%% Cache directories
dirs.base = [VIDEOEVENTS.base_dir, 'cache/'];
dirs.similarity = [dirs.base, 'shot_similarity/'];
dirs.scenes = [dirs.base, 'scenes/'];
dirs.visualization = [dirs.base, 'visualization/'];
dirs.vis_threading = [dirs.visualization, 'threading/'];
dirs.vis_scenes = [dirs.visualization, 'scenes/'];
fields = fieldnames(dirs);
for k = 1:length(fields)
    if ~exist(dirs.(fields{k}), 'dir')
        mkdir(dirs.(fields{k}));
    end
end

%%% Shot threading cache
VideoStruct.cache.homography_shot_similarity = [dirs.similarity, video_name, '.range-%d.num-%d.move-%.2f.homography_sift.mat']; % range, num_matches, allowable_movement
VideoStruct.cache.rgbhist = [dirs.similarity, video_name, '.%s.rgbhist.bins-%d.mat']; % indicate first/mid/last or combinations
VideoStruct.cache.prev_shot_dist = [dirs.similarity, video_name, '.%s.range-%d.prev-shot-dist.mat']; % feature, range

%%% Scenes cache
VideoStruct.cache.scenes_dtw3d = [dirs.scenes, video_name, '.dtw3d.nr-%d.nc-%d.nl-%d.bin-%d.costmat.mat'];

%%% Visualization cache
VideoStruct.cache.visualization.threading.matfile =  [dirs.vis_threading, video_name, '.mat'];
VideoStruct.cache.visualization.threading.htmlfile = [dirs.vis_threading, video_name, '.threads.html'];

VideoStruct.cache.visualization.scenes.matfile =  [dirs.vis_scenes, video_name, '.num-%d.bin-%d.mat'];
VideoStruct.cache.visualization.scenes.htmlfile = [dirs.vis_scenes, video_name, '.num-%d.bin-%d.mat.html'];


end
