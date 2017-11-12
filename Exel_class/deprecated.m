%%
%%
% getting the persistent exlsconfig structure
persistent exls3config

% checking for erlier Bluetooth Devices Scan
if isempty(exls3config) || datetime('now') > ...
        exls3config.LastCheck + duration(0,10,0) || ...
        all([exls3config.Sensors.Associated])
    % Scanning for Bluetooth Devices
    waiting(true,'Looking for Bluetooth Devices')
    BluetoothInfo = instrhwinfo('Bluetooth');
    waiting(false)
    
    % if no Bluetooth device was detected
    if isempty(BluetoothInfo.RemoteIDs)
        error('MATLAB cannot find any Bluetooth Device')
    else
        % preallocating
        RemoteNames = [];
        RemoteIDs   = [];
        Associated  = [];
        
        % checking for EXLs3 and adding them to preallocated
        for i = 1:numel(BluetoothInfo.RemoteNames)
            if strcmp(BluetoothInfo. ...
                    RemoteNames{i,1}(1:5),'EXLs3')
                % adding RemotedNames
                RemoteNames = [RemoteNames; ...
                    BluetoothInfo.RemoteNames(i,1)]; %#okAGROW
                
                % adding RemoteIDs
                RemoteIDs = [RemoteIDs; ...
                    BluetoothInfo.RemoteIDs(i,1)]; %#okAGROW
                
                % adding Associated control bit
                Associated = [Associated; false]; %#okAGROW
            end
        end
        
        % creating exls3config structure
        exls3config.Sensors = ...
            table(RemoteNames,RemoteIDs,Associated);
        exls3config.LastCheck = datetime('now');
    end
end

%%
%%
% if no ImuName setted, setting the first available
if isempty(obj.ImuName)
    availableSensors = exls3config.Sensors.RemoteNames( ...
        not(exls3config.Sensors.Associated));
    if isempty(availableSensors)
        error('No EXLs3 sensor available')
    else
        obj.ImuName = availableSensors{1,1};
    end
end