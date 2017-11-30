function command(obj,CommandType)
% help

% hiding unsuccessfulRead warning for Bluetooth objects
warning('off','instrument:fread:unsuccessfulRead')

success = 0;
nAttempts = 0;
while success == 0 && nAttempts < 3
    fwrite(obj.BluetoothObj,uint8(obj.(CommandType)))
    acknowledgement = fread(obj.BluetoothObj,1);
    if isempty(acknowledgement)
        nAttempts = nAttempts + 1;
    else
        if acknowledgement == 1
            success = 1;
        else
            nAttempts = nAttempts + 1;
        end
    end
end
if success == 1
    flushinput(obj.BluetoothObj)
    fprintf('    %s sent\n',CommandType)
else
    fprintf('    %s error\n\n',CommandType)
    error('Exel:connect:command:acknowledgementError', ...
        ['Acknowledgement byte for %s not received ', ...
        'or it is not equal to 1.'],CommandType)
end

% dehiding the same warnings
warning('on','instrument:fread:unsuccessfulRead')
end
        