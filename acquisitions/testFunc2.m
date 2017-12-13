function testFunc2(obj)
% computing Elapsed Time
ElapsedTime = (height(obj.ExelData)-obj.ExelFigure.LastFrame) / ...
    obj.SamplingFrequency;

% If ElapsedTime > 1/3 s, so plotting
if ElapsedTime > 0.3333
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
    
    % getting line
    switch obj.ExelName
        case 'EXLs3_0159'
            % homer
            Line = 1;
        case 'EXLs3_0067'
            % thorax
            Line = 2;
    end
    
    % computing Angle
    angle2 = computeHomerAngle2( ...
        obj.ExelData.AccX(ind,1), ...
        obj.ExelData.AccY(ind,1), ...
        obj.ExelData.AccZ(ind,1)  ...
        );
    
    addpoints(obj.ExelFigure.Lines(Line,1),time,angle2);
    
    % showing now new values
    drawnow
    
    % updating last frame
    obj.ExelFigure.LastFrame = height(obj.ExelData);
end
end