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

% showing ExelFigure
obj.ExelFigure.Figure.Visible = 'on';

% updating the ValuesRequired property and flushing ExelData and ExelFigure
obj.ValuesRequired = obj.ValuesRequired + obj.BluetoothObj.ValuesReceived;
obj.ExelData = cell2table(cell(0,16),'VariableNames',obj.ExelVars);
% cancellare qui tutte le animated lines con clearpoints

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