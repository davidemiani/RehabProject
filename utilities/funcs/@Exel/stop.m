function stop(obj)
% STOP Stop the data stream with an Exel IMU.
%
%     STOP(OBJ) stops to acquire data from the Exel IMU associated to the
%     Exel object OBJ. If the data stream was off, the method has no
%     effect.
%
%     Example:
%        obj = Exel('EXLs3_0067');
%        connect(obj)
%        start(obj)
%        stop(obj)
%
%     See also Exel, Exel/connect, Exel/disconnect, Exel/start

% checking for multidimensional array
if numel(obj)>1
    arrayfun(@stop,obj)
    return
end

% quitting if not started
if strcmp(obj.AcquisitionStatus,'off')
    return
end

% stopping
fwrite(obj.Instrument,char(hex2dec('3A')))
pause(0.5), flushinput(obj.Instrument)
obj.AcquisitionStatus = 'off';
end