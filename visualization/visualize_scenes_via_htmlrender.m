function visualize_scenes_via_htmlrender(VideoStruct, scene_breaks, params)
%VISUALIZE_SCENES_VIA_HTMLRENDER Show automatically generated scenes in HTML
% Method = ncuts
% This creates the scenes with auto-scene count of diff1 (may need to change
% based on series)
%
%
% Then call the python tool on command line in case Matlab doesn't work due to
% GLIBC problems.
%
% Author: Makarand Tapaswi
% Last modified: 07-10-2013

sse = videoevents_to_shots(VideoStruct);

%% Generate a main scenes structure
Scenes = empty_struct();
for k = 1:size(scene_breaks, 1)
    sc = 2;
    Scenes(k).shots(1).number = [];
    Scenes(k).shots(1).imfile = [];
    for s = scene_breaks(k, 1):scene_breaks(k, 2)
        Scenes(k).shots(sc).number = s;
        Scenes(k).shots(sc).imfile = sprintf(VideoStruct.data.img_fname, sse(s, 1));
        sc = sc + 1;
    end
end

%% What to do next
% Copy the Threads structure to a generic "output" structure (which can take other fields)
% Write the "output" structure to mat file
% Call the gen_html.py with this using template as "scenes.html"

nbin = params.descriptor.rgbhist.bins3d^3;
%%% save the output mat file
output.videoname = VideoStruct.name;
output.numscenes = length(Scenes);
output.scenes = Scenes;
mat_fname = sprintf(VideoStruct.cache.visualization.scenes.matfile, output.numscenes, nbin);
html_fname = sprintf(VideoStruct.cache.visualization.scenes.htmlfile, output.numscenes, nbin);
save(mat_fname, 'output');

%%% run the rendering python tool
global VIDEOEVENTS
command = [VIDEOEVENTS.binaries.render_to_html ' ', ...
                VIDEOEVENTS.binaries.render_template_folder, 'scenes.html ', ...
                mat_fname ' ', ...
                html_fname];
print_dashes; print_dashes;
fprintf('To create HTML output, run this command on the terminal...\n');
fprintf('%s\n', command);

print_dashes; print_dashes;
fprintf('To open the HTML, run this command on the terminal...\n');
fprintf('firefox %s\n', html_fname);


end

function print_dashes()
fprintf('--------------------------------\n');
end


