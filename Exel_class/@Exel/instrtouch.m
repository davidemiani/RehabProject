function instrtouch(obj)

% getting Exel object dimensions
[m,n] = size(obj);

% main cycle (on dimensions)
for i = 1:m
    for j = 1:n
        % printing
        fprintf('--- CREATING INSTRUMENT OBJ FOR %s... ',obj(i,j).ExelName)
        
        % getting instruments already created with the same ExelName
        instruments = instrfind('UserData',obj(i,j).ExelName);
        
        % checking if already created
        if isempty(instruments)
            % if not already created
            if ispc
                % creating serial obj
                obj(i,j).Instrument = ...
                    serial(getBluetoothPort(obj(i,j).ExelName)); %#okAGROW
            elseif ismac
                % creating bluetooth obj
                obj(i,j).Instrument = ...
                    Bluetooth(obj(i,j).ExelName,1);
                
                % checking RemoteID for existence
                if isempty(obj(i,j).Instrument.RemoteID)
                    delete(obj(i,j).Instrument)
                    error('Exel:invalidBluetoothRemoteName', ...
                        'Exel sensor with RemoteName "%s" not found', ...
                        obj(i,j).ExelName)
                end
            else %linux case
                % ...
            end
            
            % setting the Instrument.UserData property to ExelName
            obj(i,j).Instrument.UserData = obj(i,j).ExelName;
        else
            % if already created, assigning it
            obj(i,j).Instrument = instruments(1,1);
        end
        
        % printing the end
        fprintf('DONE!!\n')
    end
end
fprintf('\n')
end