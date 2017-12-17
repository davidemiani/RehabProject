function updateInternalFigure(obj,~,~)
% getting init & stop
init = obj.LastFrame+1;
stop = height(obj.ExelData);

% computing elapsed time
timeElapsed = (stop - init) / obj.SamplingFrequency;

% if elapsed time greater than 1/3 s
if timeElapsed > 0.3333
    % computing indexes and time
    ind = (init : stop)';
    time = (ind-1)/obj.SamplingFrequency;
    
    % getting VarNames
    VarNames = obj.ExelFigure.VarNames;
    
    % getting dimensions
    [nAxes,nLines] = size(VarNames);
    
    % setting new XLim if necessary
    if time(end,1) > obj.ExelFigure.Axes(1,1).XLim(1,2)
        obj.ExelFigure.Axes(1,1).XLim = ...
            obj.ExelFigure.Axes(1,1).XLim + ...
            obj.ExelFigure.AxesWidth;
    end
    
    % adding points
    for i = 1:nAxes
        for j = 1:nLines
            addpoints( ...
                obj.ExelFigure.Lines(i,j), ...
                time, ...
                obj.ExelData.(VarNames{i,j})(ind,1) ...
                );
        end
    end
    
    % showing new values
    drawnow
    
    % updating last frame
    obj.LastFrame = stop;
end
end