function connect(obj)
% CONNECT Open a communication with an Exel IMU.
%
%     CONNECT(OBJ) connects the Exel IMU associated to the Exel object OBJ.
%     This method has three different steps:
%         1) create a Bluetooth object;
%         2) open a channel with the fopen function;
%         3) send some packets to the IMU in order to obtain the right data
%            during the acquisition.
%
%     Example:
%        obj = Exel('EXLs3_0067');
%        connect(obj)
%
%     See also Exel, Exel/disconnect, Exel/start, Exel/stop

% printing
fprintf('--- CONNECTING    %s ---\n',obj.ExelName)

% updating BluetoothFcn properties
obj.BluetoothObj.InputBufferSize = obj.BufferSize * 2;
obj.BluetoothObj.BytesAvailableFcnMode = 'byte';
obj.BluetoothObj.BytesAvailableFcnCount = obj.BufferSize;
obj.BluetoothObj.BytesAvailableFcn = @obj.instrcallback;

% once the Bluetooth object is created, we have to open the
% communication, thanks to a simple use of fopen
try
    fopen(obj.BluetoothObj);
    obj.ConnectionStatus = 'open';
    fprintf('    Connection opened\n')
catch ME
    fprintf('    Connection error\n\n')
    rethrow(ME)
end

% we have to say the sensor what packet type it has to send us
try
    fwrite(obj.BluetoothObj,uint8(obj.PacketTypeCommand))
    fprintf('    PacketType sent\n')
catch ME
    fprintf('    PacketType error\n\n')
    disconnect(obj.BluetoothObj);
    rethrow(ME)
end

% printing success (state reached only without exceptions)
fprintf('    SUCCESS!! :-)\n\n')
end