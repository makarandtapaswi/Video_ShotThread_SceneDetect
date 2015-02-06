function [cliqs, t_in_cliq] = transitivity_cliques(aff_mat)
%TRANSITIVITY_CLIQUES Applies transitivity, gets maximal cliques
%
% Finds cliques in a graph given an affinity matrix (0 for no edge, 1 for
% edge). Automatically applies transitivity rules first to ensure that if 
% A-B and B-C, then A-C.
%
% NOTE: Input aff_mat must be symmetric / boolean.
%
% Author: Makarand Tapaswi
% Last modified: 27-05-2013

% Check whether aff_mat
if ~all(all(aff_mat == aff_mat'))
    aff_mat = aff_mat + aff_mat';
end

%% Apply transitivity and get cliques
% repeat until cliques are non-overlapping
fprintf('Finding cliques... \n');
cliqs = maximalCliques(aff_mat);
try_again = 5;

while cliques_overlap(cliqs) && try_again
    fprintf('Applying transitivity. ');
    for k = 1:size(aff_mat, 1)
        m = find(aff_mat(k, :));
        if length(m) > 1
            pairs = nchoosek(m, 2);
            aff_mat(sub2ind(size(aff_mat), pairs(:, 1), pairs(:, 2))) = 1;
            aff_mat(sub2ind(size(aff_mat), pairs(:, 2), pairs(:, 1))) = 1;
        end
    end
    try_again = try_again - 1;
    fprintf('Finding cliques... \n');
    cliqs = maximalCliques(aff_mat);
end

if try_again == 0
    warning('Cliqs might be repeatitive');
end

%% Return a vector providing info of which element went where
t_in_cliq = zeros(1, size(aff_mat, 1));
for k = 1:length(cliqs)
    t_in_cliq(cliqs{k}) = k;
end

end


function bool = cliques_overlap(cliqs)
% Checks whether cliques overlap
bool = length(unique([cliqs{:}])) ~= length([cliqs{:}]);
end