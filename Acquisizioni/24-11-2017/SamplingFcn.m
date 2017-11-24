function obj = SamplingFcn(obj)
if height(obj.ImuData)-obj.UserData.LastFrame >= obj.SamplingFrequency/5
    % getting indexes
    ind = (obj.UserData.LastFrame+1:height(obj.ImuData))';
    
    % computing time
    time = ind/obj.SamplingFrequency;
    
    % setting new XLim if necessary
    if any(time > obj.UserData.Axes(1,1).XLim(1,2))
        obj.UserData.Axes(1,1).XLim = ...
            obj.UserData.Axes(1,1).XLim + ...
            obj.UserData.AxesWidth;
    end
    
    % getting accs
    AccX = obj.ImuData.AccX(ind,1);
    AccY = obj.ImuData.AccY(ind,1);
    AccZ = obj.ImuData.AccZ(ind,1);
    [AcosF,AtanF] = computeFrontalAngle(AccY,AccZ);
    [AcosS,AtanS] = computeSagittalAngle(AccX,AccY);
    
    % adding points
    addpoints(obj.UserData.Lines(1,1),time,AccX);
    addpoints(obj.UserData.Lines(1,2),time,AccY);
    addpoints(obj.UserData.Lines(1,3),time,AccZ);
    addpoints(obj.UserData.Lines(2,1),time,AcosF);
    addpoints(obj.UserData.Lines(2,2),time,AtanF);
    addpoints(obj.UserData.Lines(3,1),time,AcosS);
    addpoints(obj.UserData.Lines(3,2),time,AtanS);
    
    % showing now new values
    drawnow
    
    % updating last frame
    obj.UserData.LastFrame = height(obj.ImuData);
end
end