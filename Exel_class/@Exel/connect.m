function connect(obj)
% CONNECT Open a communication with an Exel IMU.
%
%     CONNECT(OBJ) connects the Exel IMU associated to the Exel object OBJ.
%     This method opens a communication via the fopen method for Bluetooth
%     objects, then sends the right commands to be sure that we will
%     receive the data we want.
%
%     Example:
%        obj = Exel('EXLs3_0067');
%        connect(obj)
%
%     See also Exel, Exel/disconnect, Exel/start, Exel/stop

% checking for multidimensional array
if numel(obj)>1
    arrayfun(@connect,obj)
    return
end

% printing
fprintf('--- CONNECTING    %s ---\n',obj.ExelName)

% updating BluetoothFcn properties
obj.BluetoothObj.InputBufferSize = obj.BufferSize * 2;
obj.BluetoothObj.BytesAvailableFcnMode = 'byte';
obj.BluetoothObj.BytesAvailableFcnCount = obj.BufferSize;
obj.BluetoothObj.BytesAvailableFcn = @obj.exelcallback;
obj.BluetoothObj.Timeout = 2;

% once the Bluetooth object is created, we have to open the
% communication, thanks to a simple use of fopen
if strcmp(obj.ConnectionStatus,'closed')
    % opening communication
    try
        fopen(obj.BluetoothObj);
        obj.ConnectionStatus = 'open';
        fprintf('    Connection opened\n')
    catch ME
        fprintf('    Connection error\n\n')
        rethrow(ME)
    end
    
    % sending commands
    command(obj,'PacketTypeCommand')
    
    % printing success (state reached only without exceptions)
    fprintf('    SUCCESS!! :-)\n\n')
elseif strcmp(obj.AcquisitionStatus,'off')
    % if already connected but not running
    fprintf('    Already connected\n')
    
    % sending commands anyway
    command(obj,'PacketTypeCommand')
    
    % printing success (state reached only without exceptions)
    fprintf('    SUCCESS!! :-)\n\n')
else
    % warning if the sensor is still/already running
    warning('Exel:connect:connectOnRunningObj', ...
        ['This Exel object is acquiring data: the connect method\n', ...
        'will not have any effect.'])
end
end