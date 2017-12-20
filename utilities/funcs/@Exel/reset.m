function reset(obj)
obj.ExelData = cell2table(cell(0,16), ...
    'VariableNames',obj.ExelVars);
obj.LastFrame = 0;
obj.SamplesRequired = 0;
if strcmp(obj.ExelFigureMode,'Default')
    arrayfun(@clearpoints,obj.ExelFigure.Lines)
    obj.ExelFigure.Axes(1,1).XLim = [0,obj.ExelFigure.AxesWidth];
end
end