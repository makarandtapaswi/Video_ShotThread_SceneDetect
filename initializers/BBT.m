function VideoStruct = BBT(season, episode)
% Initialize STORYGRAPH project for The Big Bang Theory
% Given season and episode
%

num_frames = {[32990 30391 31757 29773 29086 30301]};

k = 1;
for ep = episode
    video_name = sprintf('bbt_s%02de%02d', season, ep);
    VideoStruct(k) = initVIDEO(video_name, 'series', 'bbt', 'season', season, 'episode', ep);
    % Hack some info about the video here to substitute for the actual full video
    VideoStruct(k).data.numframe = num_frames{season}(ep);
    k = k + 1;
end



end
