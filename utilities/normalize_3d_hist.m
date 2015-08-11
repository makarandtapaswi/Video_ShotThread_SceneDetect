function histOut = normalize_3d_hist(histIn, truncate)
%NORMALIZE_3D_HIST - Normalizes the input histogram nonlinearly
% Inputs - 3D histogram, and the truncate parameter
% Output - normalized histogram vector
%
% 0 < truncate < 1; the normalized truncation constant
% step 0. linearize the 3D cube
% step 1. normalize - divide by sum(sum(sum()))
% step 2. truncate max - cut all values above 'truncate' to 'truncate'
% step 3. re-normalize - divide by sum()

histOut = histIn(:);
histOut = histOut./sum(histOut);

% fprintf('Truncated %d data points\n',sum(histOut > truncate));
histOut(histOut > truncate) = truncate;
histOut = histOut./sum(histOut);

end

