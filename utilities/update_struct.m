function s = update_struct(s, varargin)

for k = 1:2:length(varargin)
    if ~ischar(varargin{k})
        error('string expected at position %d', k);
    end

    field = regexp(varargin{k}, '\.', 'split');
    s = setfield(s, field{:}, varargin{k+1});
end

end
