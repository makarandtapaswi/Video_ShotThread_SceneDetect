% Main script to show how shot threading can be performed

%% 1. On a pair of images
% take 2 sample images
im1 = imread('data/bbt_s01e01_excerpt/bbt_s01e01_002130.jpg');
im2 = imread('data/bbt_s01e01_excerpt/bbt_s01e01_002649.jpg');
% display the images
figure; set(gcf, 'Position', [100 100 600, 800]);
subplot(211); imshow(im1); title('Frame: 002130, shot 20');
subplot(212); imshow(im2); title('Frame: 002649, shot 22');
drawnow;

% compute similarity between the images
[decision, data] = are_images_similar(im1, im2, params);

% print decision
if decision, fprintf(2, 'The two images are similar enough to form a thread!\n');
else         fprintf(2, 'The two images are NOT similar to form a thread!\n');
end

%% 2. On the whole video
% this will take a while.
% Check line 27 of shot_similarity.m to enable/disable parfor

answer = input('Running this will take a while.\nHowever, after one completed run, the data will be saved in your cache.\nAre you sure you want to continue? (y/N): ', 's');
if strcmpi(answer, 'y')
    % create the video structure for one episode of BBT
    VideoStruct = BBT(1, 1);

    % compute similarity between every shot to 24 shots looking ahead
    similarity = shot_similarity(VideoStruct, params);

    % convert shot similarity decisions into threads (transitivity)
    [Threads, shot_assigned] = similarity_to_threads(similarity);

    % Shot threads are organized in the "Threads" variable
    % Threads{1} is a list of shots which are NOT part of a thread.
    % Threads{2:end} are actual shot threads

    visualize_threads_via_htmlrender(VideoStruct, Threads, shot_assigned);
end

