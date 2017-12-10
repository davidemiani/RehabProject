function instrtouch(obj)

% getting Exel object dimensions
[m,n] = size(obj);

% main cycle (on dimensions)
for i = 1:m
    for j = 1:n
        if ispc
        obj(i,j).Instrument = serial(getBluetoothPort(obj(i,j).ExelName));
%         % getting instruments already created with the same ExelName
%         instrfound = instrfind('RemoteName',obj(i,j).ExelName);
%         
%         % if not already creating, we have to create it
%         if isempty(instrfound)
%             obj(i,j).Instrument = Bluetooth( ...
%                 obj(i,j).ExelName,1);
%         else
%             obj(i,j).Instrument = instrfound;
%             %obj(i,j).Instrument.Channel = channel;
%         end
%         
%         % checking existence
%         if isempty(obj(i,j).Instrument.RemoteID)
%             delete(obj(i,j).Instrument)
%             error('Exel:invalidBluetoothRemoteName', ...
%                 'Exel sensor with RemoteName "%s" not found', ...
%                 obj(i,j).ExelName)
%         end
    end
end
end