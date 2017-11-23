function clearExcept(varargin)
vars = setdiff(evalin('base','who'),varargin);
for k = 1:numel(vars)
    evalin('base',['clear ',vars{k}])
end
end