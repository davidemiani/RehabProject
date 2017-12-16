function confcommand(obj,CommandType)
% help

% hiding unsuccessfulRead warning for Bluetooth objects
warning('off','instrument:fread:unsuccessfulRead')

success = 0;
nAttempts = 0;
while success == 0 && nAttempts < 3
    fwrite(obj.Instrument,uint8(obj.(CommandType)))
    acknowledgement = fread(obj.Instrument,1);
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
    flushinput(obj.Instrument)
else
    error('Exel:confcommand:acknowledgementError', ...
        ['Acknowledgement byte for %s not received ', ...
        'or it is not equal to 1.'],CommandType)
end

% dehiding the same warnings
warning('on','instrument:fread:unsuccessfulRead')
end
        