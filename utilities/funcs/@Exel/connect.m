function connect(obj)
% CONNECT Open a communication with an Exel IMU.
%
%     CONNECT(OBJ) connects the Exel IMU associated to the Exel object OBJ.
%     This method opens a communication via the fopen method for Bluetooth
%     objects, then sends the configuration commands (to be sure that we
%     will receive the data we want).
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

% quitting if not connected
if strcmp(obj.ConnectionStatus,'open')
    return
end

% updating BluetoothFcn properties
obj.Instrument.InputBufferSize = obj.BufferSize * 2;
obj.Instrument.BytesAvailableFcnMode = 'byte';
obj.Instrument.BytesAvailableFcnCount = obj.BufferSize;
obj.Instrument.BytesAvailableFcn = @obj.instrcallback;
obj.Instrument.Timeout = 2;

% once the Bluetooth object is created, we have to open the
% communication, thanks to a simple use of fopen
if strcmp(obj.ConnectionStatus,'closed')
    % opening communication
    fopen(obj.Instrument);
    obj.ConnectionStatus = 'open';
    
    % sending configuration commands
    confcommand(obj,'PacketTypeCommand')
elseif strcmp(obj.AcquisitionStatus,'off')
    % sending configuration commands anyway
    confcommand(obj,'PacketTypeCommand')
else
    % warning if the sensor is still/already running
    warning('Exel:connect:connectOnRunningObj', ...
        ['This Exel object is acquiring data: the connect method\n', ...
        'will not have any effect.'])
end
end