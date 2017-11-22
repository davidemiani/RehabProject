function obj = testFunc(obj)
if height(obj.ImuData)-obj.FigureHandle.LastFrame >= obj.SamplingFrequency
    % getting current animated line handle
    subplot(ismember(obj.FigureHandle.ImuNames,obj.ImuName);
    
    % adding points to the graph
    addpoints(obj.FigureHandle.Lines(1,1),obj.ImuData.AccX(obj.FigureHandle.LastFrame:end,1));
    addpoints(obj.FigureHandle.Lines(2,1),obj.ImuData.AccY(obj.FigureHandle.LastFrame:end,1));
    addpoints(obj.FigureHandle.Lines(3,1),obj.ImuData.AccZ(obj.FigureHandle.LastFrame:end,1));
end
end