function [ndx] = FindSetNdx(LargeSet, SmallSet, varargin)

% function [ndx] = FindSetNdx(LargeSet, SmallSet)
%
% Locates the indices of each element of SmallSet in LargeSet. I.e. indices
% returned locate every SmallSet item in LargeSet, in order.
%   - LargeSet, SmallSet: cell arays of strings
%   - ndx: indices of SmallSet elements in LargeSet
%   - varargin:
%      - 'sort': (0/1) sort the output ndx array (default off)
%      - 'keepall': (0/1) return a zero for indices not found (default off)
%      - 'match': 'exact' = exact string match, 'pattern': match wildcard
%      string, case-insensitive, 'left': case-insensitive left characters
%      only. 'part': matches any string with a subset of characters
%      matching SmallSet. Default: 'exact'

sort=0;
keepall = 0;
match = 'exact';
cs = 0;
for v=1:2:length(varargin)
    switch varargin{v}
        case 'sort', sort = varargin{v+1};
        case 'keepall', keepall = varargin{v+1};
        case 'match', match = varargin{v+1};
        case 'case', cs = varargin{v+1};
    end
end

if ~iscell(SmallSet) && ~isstr(SmallSet)
    error('SmallSet must be a string or a cell array of strings')
end
if ~iscell(SmallSet)
    SmallSet = {SmallSet};
end

if strcmp(match,'part')
    for item=1:length(SmallSet)
        SmallSet{item} = ['*' SmallSet{item} '*'];
    end
    match = 'pattern';
end

ndx = [];
for s=1:length(SmallSet)
    if ~cs
        A = upper(SmallSet{s});
    end
    for l=1:length(LargeSet)
        if ~cs
            B = upper(LargeSet{l});
        end
        
        switch match
            case 'exact', 
                z=strcmp(A,B);
            case 'pattern', 
                z=regexp(B,regexptranslate('wildcard',A))==1;
            case 'left', 
                z=strncmp(A,B,length(SmallSet{s}));
            otherwise, error('FindSetNdx: unknown match type');
        end
        if iscell(z)
            if length(z)~=length(B)
                error('???')
            end
            for xx=1:length(z)
                if ~isempty(z{xx})
                    ndx = [ndx xx];
                end
            end
        elseif z
            ndx=[ndx l];
        end
    end
end

if ~keepall
    ndx=ndx(logical(ndx));
end

if sort
    ndx = sort(ndx);
end

            


