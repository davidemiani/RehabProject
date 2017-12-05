function bluetouch(obj)
persistent channel
if isempty(channel)
    channel = 0;
end

% getting Exel object dimensions
[m,n] = size(obj);

% main cycle (on dimensions)
for i = 1:m
    for j = 1:n
        % getting instruments already created with the same ExelName
        instrfound = instrfind('RemoteName',obj(i,j).ExelName);
        
        % updating channel
        channel = channel + 1;
        
        % if not already creating, we have to create it
        if isempty(instrfound)
            obj(i,j).BluetoothObj = Bluetooth( ...
                obj(i,j).ExelName,channel);
        else
            obj(i,j).BluetoothObj = instrfound;
            obj(i,j).BluetoothObj.Channel = channel;
        end
        
        % checking existence
        if isempty(obj(i,j).BluetoothObj.RemoteID)
            delete(obj(i,j).BluetoothObj)
            error('Exel:invalidBluetoothRemoteName', ...
                'Exel sensor with RemoteName "%s" not found', ...
                obj(i,j).ExelName)
        end
    end
end
end