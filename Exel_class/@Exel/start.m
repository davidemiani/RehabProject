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

% checking if communication is opened
if isempty(obj.BluetoothObj) || strcmp(obj.ConnectionStatus,'closed')
    connect(obj)
end

% printing
fprintf('--- STARTING   %s ---\n',obj.ExelName)

% updating ValuesRequired
obj.ValuesRequired = obj.ValuesRequired + ...
    obj.AutoStop * obj.SamplingFrequency;

% showing ExelFigure
obj.ExelFigure.Figure.Visible = 'on';

% starting data stream
try
    fwrite(obj.BluetoothObj,char(hex2dec('3D')))
    obj.StartTime = datetime('now');
    obj.AcquisitionStatus = 'on';
    fprintf('    Data stream started\n')
catch ME
    fprintf('    Starting error\n\n')
    rethrow(ME)
end

% printing success (state reached only without exceptions)
fprintf('    SUCCESS!! :-)\n\n')
end