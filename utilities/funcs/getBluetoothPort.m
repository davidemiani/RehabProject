function port = getBluetoothPort(FriendlyName)
%GETBLUETOOTHPORT Get serial port for a Bluetooth device.
%   PORT = GETBLUETOOTHPORT(FRIENDLYNAME) returns the serial port
%   associated with a device with a specified FRIENDLYNAME.
%
%   You can use this PORT result to construct a serial port object with the
%   SERIAL class.
%
%   Example:
%       % getting serial port for a Bluetooth device:
%         PORT = GETBLUETOOTHPORT('MyDevFriendlyName');
%       % creating a serial object
%         s = serial(PORT);
%
%   See also serial, dosRegQuery, fopen, fread, fclose
%
%   ------------------------------------
%   CREDITS:     Davide Miani (dec 2017)
%   LAST REVIEW: Davide Miani (dec 2017)
%   MAIL TO:     davide.miani2@gmail.com
%   ------------------------------------
if ispc
    % quering for bluetooth devices written in registry
    [~,REG] = dosRegQuery('BTHENUM','/s');
    
    % getting device Key and ContainerID from Friendly Name
    DevKey = REG.Key(REG.FriendlyName == FriendlyName);
    if isempty(DevKey)
        error('getCOM:Win:unknownDevice', ...
            'Device with FriendlyName %s not present in the registry.', ...
            FriendlyName)
    end
    DevContainer = REG.ContainerID(REG.FriendlyName == FriendlyName);
    
    % looking for the device with the same container
    SameContainerKeys = REG.Key(REG.ContainerID == DevContainer);
    OtherDevWithSameContainerKey = setdiff(SameContainerKeys,DevKey);
    DevParametersKey = string(fullfile( ...
        OtherDevWithSameContainerKey{1,1},'Device Parameters'));
    
    % getting COM port
    port = REG.PortName(REG.Key == DevParametersKey);
    port = port{1,1};
    
    
elseif ismac
    % setting initial part of the port name
    port = ['/dev/tty.',FriendlyName,'-'];
    
    % getting serial list
    list = seriallist()';
    
    % cycling to find corrispondencies
    lp = length(port);
    for i = 1:length(list)
        if length(list{i,1}) > lp
            if strcmp(list{i,1}(1:lp),port)
                port = list{i,1};
                return
            end
        end
    end
    
    % if here, no device found
    error('getCOM:Mac:unknownDevice', ...
        'Device with FriendlyName %s not present in dev.', ...
        FriendlyName)
    
    
else % linux case
    error('getBluetoothPort:unsupportedMachine', ...
        'Still not supported on linux machines.')
end
end