% Performs some data download, compilation, and messaging operations on first initialization of the repository
global VIDEOEVENTS

% Create a file in PROJECTROOT/tmp/ to know whether it has been accessed before
tmp_fname = 'tmp/first_init';
if exist(tmp_fname, 'file')
    run('ext/vlfeat/toolbox/vl_setup.m');
    clear tmp_fname
    return;
end

if ~isdir('tmp'), mkdir('tmp'); end

%% data download
fprintf(2, 'Sample Image Data: BBT S01E01 excerpt\n');
fprintf('\nPlease download the following zip file (27.3MB):\n');
fprintf('https://cvhci.anthropomatik.kit.edu/~mtapaswi/downloads/shot_thread_scene_detect_data/bbt_s01e01_excerpt.zip\n');
fprintf('... and unzip it in the same folder so that sample images are accessible.\n');
while ~exist('data/bbt_s01e01_excerpt', 'dir') || ~exist('data/bbt_s01e01_excerpt/bbt_s01e01_000000.jpg', 'file')
    fprintf('Press any key to continue, once you are done.\n');
    pause;
end
fprintf('checked. Good to go\n');

%% VLFeat
fprintf(2, '\n\nVLFeat\n');
fprintf('http://www.vlfeat.org/install-matlab.html\n');
fprintf('Please download and unpack the folder to "%s/ext/vlfeat" and make sure the file vl_setup.m exists in the "toolbox" folder.\n', VIDEOEVENTS.base_dir);
vlsetup_fname = 'ext/vlfeat/toolbox/vl_setup.m';
while ~exist(vlsetup_fname, 'file')
    fprintf('Press any key to continue...\n');
    pause;
end
% Setup to use VLFeat
run('ext/vlfeat/toolbox/vl_setup.m');

%% Create file to indicate first_init ran successfully
fid = fopen(tmp_fname, 'w');
fprintf(fid, 'Created temporary file on %s\n', date);
fclose(fid);

clear tmp_fname vlsetup_fname
