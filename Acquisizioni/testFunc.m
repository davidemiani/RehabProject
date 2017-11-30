function testFunc(obj)
timeElapsed = (height(obj.ExelData)-obj.ExelFigure.LastFrame) / ...
    obj.SamplingFrequency;
if timeElapsed > 0.3333
    % computing indexes
    ind = (obj.ExelFigure.LastFrame+1:height(obj.ExelData))';
    
    % computing time
    time = ind / obj.SamplingFrequency;
    
    % setting new XLim if necessary
    if any(time > obj.ExelFigure.Axes(1,1).XLim(1,2))
        obj.ExelFigure.Axes(1,1).XLim = ...
            obj.ExelFigure.Axes(1,1).XLim + ...
            obj.ExelFigure.AxesWidth;
    end
    
    addpoints(obj.ExelFigure.Lines(1,1),time,obj.ExelData.AccX(ind,1));
    addpoints(obj.ExelFigure.Lines(1,2),time,obj.ExelData.AccY(ind,1));
    addpoints(obj.ExelFigure.Lines(1,3),time,obj.ExelData.AccZ(ind,1));
    
    angle = computeHomerAngle( ...
        obj.ExelData.AccX(ind,1), ...
        obj.ExelData.AccY(ind,1), ...
        obj.ExelData.AccZ(ind,1)  ...
        );
    
    addpoints(obj.ExelFigure.Lines(2,1),time,angle.Sagittal);
    
    % showing now new values
    drawnow
    
    % updating last frame
    obj.ExelFigure.LastFrame = height(obj.ExelData);
end
end