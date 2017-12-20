function testFunc2(obj)
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
    case 'EXLs3_0067'
        % homer
        Line = 1;
    case 'EXLs3_0070'
        % thorax
        Line = 2;
end

% computing Angle
angle = projection( ...
    obj.ExelData.AccX(ind,1), ...
    obj.ExelData.AccY(ind,1), ...
    obj.ExelData.AccZ(ind,1)  ...
    );

% adding points to the animatedline
addpoints(obj.ExelFigure.Lines(Line,1),time,angle);

% showing now new values
drawnow limitrate

% updating last frame
obj.ExelFigure.LastFrame = height(obj.ExelData);
end