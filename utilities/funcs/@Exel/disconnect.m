function disconnect(obj)
% DISCONNECT Close the communication with an Exel IMU.
%
%     DISCONNECT(OBJ) disconnects the Exel IMU associated to the Exel
%     object OBJ. If the connection was not opened, the method has no
%     effect. If the acquisition is running, the stop method is called
%     first.
%
%     Example:
%        obj = Exel('EXLs3_0067');
%        connect(obj)
%        disconnect(obj)
%
%     See also Exel, Exel/connect, Exel/start, Exel/stop

% checking for multidimensional array
if numel(obj)>1
    arrayfun(@disconnect,obj)
    return
end

% quitting if not connected
if strcmp(obj.ConnectionStatus,'closed')
    return
end

% stop acquisition if necessary
if strcmp(obj.AcquisitionStatus,'on')
    stop(obj)
end

% disconnect if necessary
if strcmp(obj.ConnectionStatus,'open')
    fclose(obj.Instrument);
    obj.ConnectionStatus = 'closed';
end
end