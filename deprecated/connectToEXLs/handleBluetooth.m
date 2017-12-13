function [ok, h] = handleBluetooth( imuName, serialBufSize, i, run, h )

% openSerialPort
%
% -------------------------------------------------------------------------
% INPUT
% -------------------------------------------------------------------------
% OUTPUT
%
% -------------------------------------------------------------------------
% EXAMPLE
%
% -------------------------------------------------------------------------
% SEE ALSO
% CALLED BY
%
% -------------------------------------------------------------------------
% RUN
%
% -------------------------------------------------------------------------
% AUTHOR
% Alberto Ferrari
% mailto: alberto.ferrari@unibo.it
%
% -------------------------------------------------------------------------
% REVIEW
% Feb 2013

nAttemps = 0;

while nAttemps < 2
    
    % in case the port has to be opened for the first time
    if ~isfield( h, 's' ) || length( h.s ) < i
        
        h.s(i) = Bluetooth( imuName, 1 );
        
        set(h.s(i), 'InputBufferSize', serialBufSize ); %config.serialBufSize of bytes in input buffer
        % set(h.s(i), 'FlowControl', 'none');
        % set(h.s(i), 'BaudRate', 115200); % 115200
        % set(h.s(i), 'Parity', 'none');
        % set(h.s(i), 'DataBits', 8);
        % set(h.s(i), 'StopBit', 1);
        % set(h.s(i), 'Timeout',4);
        
        % in case the port is closed
    elseif strcmp( get( h.s(i), 'status' ), 'closed' )
        
        notOpened = 0;
        while notOpened < 3 && strcmp( get( h.s(i), 'status' ), 'closed' )
            
            try
                % pause(.01)
                % configure according the serial port of the node
                fopen( h.s(i) ); %opens the serial port
                
                ok = 1;
                
                fprintf( '\n Connection %s - opened \n', imuName );
                return
                
            catch ME
                
                pause(.5)
                notOpened = notOpened + 1;
                disp( ME.message )
                
                if notOpened == 3
                    
                    ok = 0;
                    return
                end
            end
        end
    end
    
    if run == 1
        
        notRunning = 0;
        while notRunning < 3
            
            try
                % START send the command that starts data streaming
                fwrite( h.s(i), '=' )
                
                pause(.8)
                
                if  h.s( i ).BytesAvailable == 0
                    error('not started')
                end
                ok = 1;
                
                fprintf( '\n %s - running \n', imuName )
                return
                
            catch ME
                
                disp( ME.message )
                notRunning = notRunning + 1;
            end
        end
        
    elseif run == 0
        
        notClosed = 0;
        while notClosed < 3
            
            try
                
                % STOP send the command that starts data streaming
                % fread( h.s( i ), h.s( i ).BytesAvailable );
                
                % data flush
                flushinput( h.s( i ) )
                
                % send command stop streaming
                fwrite( h.s(i), ':' )
                
                ok = 1;
                
                fprintf( '\n %s - stop running \n', imuName );
                
                % pause(.5)
                % fclose( h.s(i) );
                % fprintf( '\n %s - closed \n', imuCOM );
                return
                
            catch ME
                pause(.1)
                disp( ME.message )
                notClosed = notClosed + 1;
            end
        end
    end
    
    nAttemps = nAttemps + 1;
end
if nAttemps == 2 && run > -1
    
    ok = 0;
end

