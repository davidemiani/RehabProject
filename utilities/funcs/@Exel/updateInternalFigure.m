function updateInternalFigure(obj,~,~)
timeElapsed = (height(obj.ExelData)-obj.ExelFigure.LastFrame) / ...
    obj.SamplingFrequency;
if timeElapsed > 0.3333
    % getting dimensions
    [nAxes,nLines] = size(obj.ExelFigure.VarNames);
    
    % computing time
    time = (obj.ExelFigure.LastFrame+1:height(obj.ExelData))'/ ...
        obj.SamplingFrequency;
    
    % setting new XLim if necessary
    if any(time > obj.ExelFigure.Axes(1,1).XLim(1,2))
        obj.ExelFigure.Axes(1,1).XLim = ...
            obj.ExelFigure.Axes(1,1).XLim + ...
            obj.ExelFigure.AxesWidth;
    end
    
    for i = 1:nAxes
        for j = 1:nLines
            addpoints(obj.ExelFigure.Lines(i,j), ...
                time, ...
                obj.ExelData.(obj.ExelFigure.VarNames{i,j})( ...
                obj.ExelFigure.LastFrame+1:end,1));
        end
    end
    
    % showing now new values
    drawnow
    
    % updating last frame
    obj.ExelFigure.LastFrame = height(obj.ExelData);
end
end