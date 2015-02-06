function [ options ] = cvhci_process_options(args, varargin)
%CVHCI_PROCESS_OPTIONS parses varargin options
%    OPT = CVHCI_PROCESS_OPTIONS(ARGS, DEFAULT_OPTS) expects a cell array or struct
%    ARGS.  If ARGS is a cell array, it parses 'OptionName1', OptionValue1, ...
%    pairs.  If ARGS is a struct, field names are interpreted as option names,
%    and field values as option values.  Default options DEFAULT_OPTS can be
%    either given as struct, or as a list of string-value pairs (varargin).
%    The output OPT is a struct, where all given options from ARGS are set, and
%    those from DEFAULT_OPTS for which there was no new value in ARGS.
%
%    Examples:
%       default_options = struct('a', 1, 'b', [123 123]);
%       varargin = {'a', 5};
%       options = cvhci_process_options(varargin, default_options)
%
%       varargin = {'a', 5};
%       options = cvhci_process_options(varargin, 'a', 1, 'b', [124 124])
%
% Author: Martin Bäuml



if ~iscell(args) && ~isstruct(args)
    error('expecting a struct or cell array as first argument');
end

if length(varargin) == 1
    if ~isstruct(varargin{1})
        error('expecting a struct if there is only one second argument');
    end
    default_options = varargin{1};
else
    for k = 2:2:length(varargin)
        varargin{k} = {varargin{k}};
    end
    default_options = struct(varargin{:});
end

if isempty(args)
    options = default_options;
elseif length(args) > 1
    options = update_struct(default_options, args{:});
else
    if iscell(args)
        args = args{1};
    end
    assert(isstruct(args))
    options = setstructfields(default_options, args);
end

end

function test_cvhci_process_options()

default_options = struct('a', 1, 'b', [123 123]);

varargin = {'a', 5};
options = cvhci_process_options(varargin, default_options)

varargin = {'a', 5};
options = cvhci_process_options(varargin, 'a', 1, 'b', [124 124])

varargin = struct('a', 6, 'b', 'c');
options = cvhci_process_options(varargin, default_options)

varargin = struct('a', 6, 'b', 'c');
options = cvhci_process_options(varargin, 'a', 1, 'b', [125 125], 'c', 'c')

varargin = {struct('a', 6, 'c', 'd')};
options = cvhci_process_options(varargin, 'a', 1, 'b', [125 125], 'c', 'c')

end