function obj = testFunc(obj)
if height(obj.ImuData)-obj.UserData.LastFrame >= obj.SamplingFrequency/5
    % getting current axis
    cAxes = find(ismember(obj.UserData.ImuNames,obj.ImuName));
    
    % computing time
    time = (obj.UserData.LastFrame+1:height(obj.ImuData))'/ ...
        obj.SamplingFrequency;
    
    % setting new XLim if necessary
    if any(time > obj.UserData.Axes(cAxes,1).XLim(1,2))
        obj.UserData.Axes(cAxes,1).XLim = ...
            obj.UserData.Axes(cAxes,1).XLim + 10;
    end
    
    % adding points
    for j = 1:size(obj.UserData.VarNames,2)
        addpoints(obj.UserData.Lines(cAxes,j), ...
            time, ...
            obj.ImuData.(obj.UserData.VarNames{cAxes,j})( ...
            obj.UserData.LastFrame+1:end,1));
    end
    
    % showing now new values
    drawnow
    
    % updating last frame
    obj.UserData.LastFrame = height(obj.ImuData);
end
end