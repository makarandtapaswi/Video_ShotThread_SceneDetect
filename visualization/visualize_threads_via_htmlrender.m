function Threads = visualize_threads_via_htmlrender(VideoStruct, cell_threads, shot_assigned)
%VISUALIZE_THREADS_VIA_HTMLRENDER Creates the HTML files showing shot threading
% Reach until this point using
%       SS = shot_similarity(VideoStruct, params);
%       [cell_threads, shot_assigned] = similarity_to_threads(SS);
%
% Then call the python tool on command line in case Matlab doesn't work due to
% GLIBC problems.
%
% Author: Makarand Tapaswi
% Last modified: 07-10-2013

sse = videoevents_to_shots(VideoStruct);

%% Generate the main threads structure
idx_mapping = zeros(length(cell_threads));
Threads = empty_struct();
for k = 1:length(shot_assigned)
    if shot_assigned(k) == 1
        Threads(end+1).shots(1).number = k;
        Threads(end).shots(1).start_imfile = sprintf(VideoStruct.data.img_fname, (sse(k, 1)));
        Threads(end).shots(1).finis_imfile = sprintf(VideoStruct.data.img_fname, (sse(k, 2)));
    else
        if idx_mapping(shot_assigned(k)) == 0, % means no thread has been assigned yet
            Threads(end+1).shots(1).number = k;
            Threads(end).shots(1).start_imfile = sprintf(VideoStruct.data.img_fname, (sse(k, 1)));
            Threads(end).shots(1).finis_imfile = sprintf(VideoStruct.data.img_fname, (sse(k, 2)));
            idx_mapping(shot_assigned(k)) = length(Threads);
        else
            idx = idx_mapping(shot_assigned(k));
            Threads(idx).shots(end+1).number = k;
            Threads(idx).shots(end).start_imfile = sprintf(VideoStruct.data.img_fname, (sse(k, 1)));
            Threads(idx).shots(end).finis_imfile = sprintf(VideoStruct.data.img_fname, (sse(k, 2)));
        end
    end
end

for k = 1:length(Threads)
    Threads(k).shots(end+1).number = 0;
    Threads(k).shots(end).start_imfile = 'badone';
    Threads(k).shots(end).finis_imfile = 'badone';
end

%% What to do next
% Copy the Threads structure to a generic "output" structure (which can take other fields)
% Write the "output" structure to mat file
% Call the gen_html.py with this using template as "threading.html"

%%% save the output mat file
output.series_season = sprintf('%s_s%02d', VideoStruct.series, VideoStruct.season);
output.videoname = VideoStruct.name;
output.threads = Threads;
save(VideoStruct.cache.visualization.threading.matfile, 'output');

%%% run the rendering python tool
global VIDEOEVENTS
command = [VIDEOEVENTS.binaries.render_to_html ' ', ...
                VIDEOEVENTS.binaries.render_template_folder, 'threading.html ', ...
                VideoStruct.cache.visualization.threading.matfile ' ', ...
                VideoStruct.cache.visualization.threading.htmlfile];
print_dashes; print_dashes;
fprintf('To create HTML output, run this command on the terminal...\n');
fprintf('%s\n', command);

print_dashes; print_dashes;
fprintf('To open the HTML, run this command on the terminal...\n');
fprintf('firefox %s\n', VideoStruct.cache.visualization.threading.htmlfile);
                                             
end

function print_dashes()
fprintf('--------------------------------\n');
end


