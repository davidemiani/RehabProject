function start(obj)
% START Start the data stream with an Exel IMU.
%
%     START(OBJ) starts to acquire data from the Exel IMU associated to the
%     Exel object OBJ. If the connection was not opened, the connect method
%     is called first.
%
%     Example:
%        obj = Exel('EXLs3_0067');
%        connect(obj)
%        start(obj)
%
%     See also Exel, Exel/connect, Exel/disconnect, Exel/stop

% checking if communication is open
if any(string({obj.ConnectionStatus})=="closed")
    arrayfun(@connect,obj)
end

% checking for multidimensional array
if numel(obj)>1
    arrayfun(@start,obj)
    return
end

% updating ValuesRequired
obj.ValuesRequired = obj.ValuesRequired + ...
    obj.AutoStop * obj.SamplingFrequency;

% showing ExelFigure
obj.ExelFigure.Figure.Visible = 'on';

% starting data stream
fwrite(obj.Instrument,char(hex2dec('3D')))
obj.StartTime = datetime('now');
obj.AcquisitionStatus = 'on';
end