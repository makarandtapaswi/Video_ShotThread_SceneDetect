function [ has_homography,resX1,resX2,H,ok ] = calculate_homography(im1,im2)
% Extracted and adapted from the vlfeat.org example under
%   https://github.com/vlfeat/vlfeat/blob/master/apps/sift_mosaic.m
%% --------------------------------------------------------------------
%                                                         SIFT matches
% --------------------------------------------------------------------
im1 = convert_if_not_single(im1);
im2 = convert_if_not_single(im2);
[f1,d1] = vl_sift(im1) ;
[f2,d2] = vl_sift(im2) ;

[matches, scores] = vl_ubcmatch(d1,d2) ;

if isempty(matches)
    %If there is a completely uniform image then the matches come back
    %empty
    has_homography = false;
    H = [];
    resX1 = [];
    resX2 = [];
    ok = [];
else
    has_homography = true;
    
    numMatches = size(matches,2) ;
    
    X1 = f1(1:2,matches(1,:)) ; X1(3,:) = 1 ;
    X2 = f2(1:2,matches(2,:)) ; X2(3,:) = 1 ;
    % vl_ubcmatch thinks that X1 in im1 looks the same as X2 in im2
    
    %% --------------------------------------------------------------------
    %                                         RANSAC with homography model
    % --------------------------------------------------------------------
    
    clear H score ok ;
    for t = 1:100
        % estimate homograpyh
        subset = vl_colsubset(1:numMatches, 4) ; %Take 4 columns by random
        A = [] ;
        for i = subset
            A = cat(1, A, kron(X1(:,i)', vl_hat(X2(:,i)))) ;
        end
        [~,~,V] = svd(A) ;
        H{t} = reshape(V(:,9),3,3) ;
        % H{t} is the homography matrix made up by the 4 subset points that
        % projects X1 onto X2
        % Now the homography is scored by projecting all of the points through
        % that matrix and taking the delta
        % score homography
        X2_ = H{t} * X1 ;
        du = X2_(1,:)./X2_(3,:) - X2(1,:)./X2(3,:) ;
        dv = X2_(2,:)./X2_(3,:) - X2(2,:)./X2(3,:) ;
        ok{t} = (du.*du + dv.*dv) < 6*6 ; %Euclidian distance small enough?
        score(t) = sum(ok{t}) ;
    end
    
    %Take the homography for which the projection was the least off
    [~, best] = max(score) ;
    H = H{best} ;
    ok = ok{best} ;
    
    %% --------------------------------------------------------------------
    %                                                  Optional refinement
    % --------------------------------------------------------------------
    
    minimizing_fun = create_residual(X1,X2,ok);
    if exist('fminsearch') == 2
        H = H / H(3,3) ;
        opts = optimset('Display', 'none', 'TolFun', 1e-8, 'TolX', 1e-8) ;
        H(1:8) = fminsearch(minimizing_fun, H(1:8)', opts) ;
    else
        warning('Refinement disabled as fminsearch was not found.') ;
    end
    
    resX1 = f1(1:2,matches(1,ok));
    resX2 = f2(1:2,matches(2,ok));
end
end

function created_fun = create_residual(X1,X2,ok)
    function err = residual(H)
        u = H(1) * X1(1,ok) + H(4) * X1(2,ok) + H(7) ;
        v = H(2) * X1(1,ok) + H(5) * X1(2,ok) + H(8) ;
        d = H(3) * X1(1,ok) + H(6) * X1(2,ok) + 1 ;
        du = X2(1,ok) - u ./ d ;
        dv = X2(2,ok) - v ./ d ;
        err = sum(du.*du + dv.*dv) ;
    end
created_fun = @residual;
end


function [ single_image ] = convert_if_not_single( image )
if(~strcmp(class(image),'single'))
    single_image = single(mat2gray(rgb2gray(image)));
    %     single_image = single(rgb2gray(image));
else
    single_image = image;
end
end

