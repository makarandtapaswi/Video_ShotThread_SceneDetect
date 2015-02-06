function [ShotStartEnd, ShotType] = videoevents_to_shots(VideoStruct, fill_thresh)
%VIDEOEVENTS_TO_SHOTS - Converts the VideoEvents structure to start-end-frame shots
% [ShotStartEnd, ShotType] = videoevents_to_shots(iseq, VideoEvents, fill_thresh)
% Fixes few indexing issues. Old version used to be defined in each code separately (something like)
% ShotStartEnd = [[0, VE(:).startFrame]; [[VE(:).startFrame]-1 iseq_numframes(iseq)-1]];
%
% The default for fill_thresh is 5.
%
% Authors: Martin Bäuml & Makarand Tapaswi
% Last modified: 13-02-2013

if ~exist('fill_thresh', 'var'), fill_thresh = 5; end

VE = read_video_events(VideoStruct.data.shot_bdry);
VE(end+1).startFrame = VideoStruct.data.numframe;

%% Iterate through list of Video Events and add them to shots

ShotStartEnd = [0 VE(1).startFrame-1];
ShotType{1} = 'SHOT';
for k = 1:length(VE)-1
    % handle special case of cuts occurring one frame before any other type
    if k > 1 && ~strcmp(VE(k).type, 'CUT') && ShotStartEnd(end, 1) + fill_thresh > VE(k).startFrame
        VE(k).startFrame = ShotStartEnd(end, 1);
        ShotStartEnd(end, :) = [];
        ShotType = ShotType(1:end-1);
    end
    
    if VE(k).endFrame == -1
        ShotStartEnd = [ShotStartEnd; [VE(k).startFrame, VE(k+1).startFrame - 1]];
        ShotType{end+1} = 'SHOT';
    else
        ShotStartEnd = [ShotStartEnd; [VE(k).startFrame, VE(k).endFrame]];
        ShotType{end+1} = VE(k).type;
        if VE(k).endFrame + 1 == VE(k+1).startFrame
            % don't add anything new
        elseif VE(k).endFrame + fill_thresh < VE(k+1).startFrame
            % make it new shot
            ShotStartEnd = [ShotStartEnd; [VE(k).endFrame + 1, VE(k+1).startFrame - 1]];
            ShotType{end+1} = 'SHOT';
        else
            % put these few frame to the last thing
            ShotStartEnd(end, 2) = VE(k+1).startFrame - 1;
        end
    end
end

end
