function [Threads, shot_assigned] = similarity_to_threads(Similarity)
%SIMILARITY_TO_THREADS Converts the Similarity structure to a cell array of threads
% Shots are now threaded
%
% Author: Makarand Tapaswi
% Last modified: 13-02-2013

%% Use transitivity / cliques to find the connections
sim_mat = zeros(length(Similarity) + 1);
for k = 1:length(Similarity)
    for r = 1:length(Similarity(k).range)
        if ~isempty(Similarity(k).range(r).decision) && Similarity(k).range(r).decision == 1
            sim_mat(k, k+r) = 1;
        end
    end
end
%%% compute cliques on transitive matrices
[cliqs, sa] = transitivity_cliques(sim_mat);
sa = sa + 1;
t = [{find(sa == 1)}, cliqs];
%%% prepare output
shot_assigned = sa;
Threads = t;

end

