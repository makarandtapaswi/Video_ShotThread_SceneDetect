function EventsStruct = read_video_events(videvents_fname)
%READ_VIDEO_EVENTS Reads the video events given the filename or a VideoStruct
%    READ_VIDEO_EVENTS(FNAME) reads the video events from video event
%    CVHCI-standard file FNAME and pass back as a structure.
%
%    READ_VIDEO_EVENTS(VIDEOSTRUCT) reads the video events file corresponding to
%    the given VIDEOSTRUCT.
%
% Author: Makarand Tapaswi
% Last-modified: 30-01-2012

verbose = false;

if ~isstr(videvents_fname)
   % assume that the parameter is a video struct
   assert(isstruct(videvents_fname));
   videvents_fname = videvents_fname.labels.videoevents.combined;
end

readme = fopen(videvents_fname,'r');

EventsStruct = struct;
count = 1;

tline = fgetl(readme);
while ischar(tline)
    if strfind(tline,'CVHCI')
        if verbose
            fprintf('Found %s\n',tline);
        end
    else
        a = regexp(tline, ' ', 'split');
        EventsStruct(count).startFrame = str2double(a{1});
        EventsStruct(count).startTime = str2double(a{2});
        EventsStruct(count).type = a{3};
        
        % if endframe and endtime exist, read
        if length(a) > 4 && ~isempty(a{4})
            EventsStruct(count).endFrame = str2double(a{4});
            EventsStruct(count).endTime = str2double(a{5});
        else
            EventsStruct(count).endFrame = -1;
            EventsStruct(count).endTime = -1;
        end
        
        count = count + 1;
    end
    tline = fgetl(readme);
end


fclose(readme);


end

