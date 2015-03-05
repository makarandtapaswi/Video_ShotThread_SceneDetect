function Similarity = shot_similarity(VideoStruct, params)
%SHOT_SIMILARITY - Computes similarity score between consecutive and alternating shots
% Uses the homography between two images to check for similarity
% Wraps are_images_similar.m (originally are_shots_sequential.m from Sebastian)
%
% Author: Makarand Tapaswi
% Last modified: 27-06-2013

frame_offset = 5;

lookahead = params.shot_similarity.lookahead;
cache_fname = sprintf(VideoStruct.cache.homography_shot_similarity, lookahead, params.shot_similarity.num_matches, params.shot_similarity.allowable_movement);

try
    fprintf('Loading from cache... ');
    load(cache_fname);
    fprintf('Success\n');

catch
    fprintf('Failed\n');

    ShotStartEnd = videoevents_to_shots(VideoStruct);
    fprintf('Computing similarity for %d shots over a lookahead %d\n', size(ShotStartEnd, 1), lookahead);

    series_name = VideoStruct.series;
    parfor k = 1:(size(ShotStartEnd, 1)-1)
        range_struct = struct('frame1', cell(1, lookahead), 'frame2', [], 'decision', [], 'data', []);
        for r = 1:lookahead
            if k+r > size(ShotStartEnd, 1)
                continue;
            end

            %% Check whether shots are similar by comparing the last frame and first frame
            % the original thing that was being done. This was changed to
            % use frame-offsets to take care of Buffy dissolves, and
            % shouldn't impact other series much
            f1 = ShotStartEnd(k, 2);
            f2 = ShotStartEnd(k+r, 1);
            im1 = imread(sprintf(VideoStruct.data.img_fname, f1));
            im2 = imread(sprintf(VideoStruct.data.img_fname, f2));

            range_struct(r).frame1 = f1;
            range_struct(r).frame2 = f2;

            [range_struct(r).decision, range_struct(r).data] ...
                   = are_images_similar(im1, im2, params, false);

            fprintf('Consecutive shots: %3d -- %3d, similarity: %d\n', k, k+r, range_struct(r).decision);

        end
        for r = 1:lookahead
            Similarity(k).range(r) = range_struct(r);
        end
    end
    save(cache_fname, 'Similarity');

end

end
