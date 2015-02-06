function [ s ] = empty_struct( varargin )
%EMPTY_STRUCT Create an empty struct with fields.
%   S = EMPTY_STRUCT(field1, field2, ...)

s = struct([]);
% this seems to be a loophole in matlab to allow setting fields
% for empty struct arrays
for f = 1:length(varargin)
    [s(:).(varargin{f})] = deal([]);
end

end

