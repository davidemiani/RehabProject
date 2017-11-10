function handleData( varargin )

try
    tmr = varargin{1};
    i = varargin{3};
    u = get( tmr, 'UserData' );
    
    if  etime( datevec( now ), u.startTime ) * 100 < 100, flushinput( u.h.s( i ) ); return; end
    
    if u.k > 0
        
        fread( u.h.s( i ), u.k );
        u.k = 0; disp(['synch corrected, sensor: ', num2str(i)])
    end
    
    nBytes = u.h.s( i ).BytesAvailable;
    
    if nBytes >= u.serialBufSize - 1
        
        u.onLineTime = datevec( now );
        [u.data( 1 : u.numOfPacketsBuffered, 1 : u.channels ), u.k] = getDataFromIMU( u.h.s( i ), u.packetSize, u.numOfPacketsBuffered, u.channels, u.k ); % txtFiles{i}
        [ u.allFrameRetrieved((u.iii-1) * u.numOfPacketsBuffered + ( 1 : u.numOfPacketsBuffered )), u.s185 ] = getUnwrappedFrame( u.data( :, 3 ), u.s185 );
        u.frameRetrieved  = ( u.iii - 1 ) * u.numOfPacketsBuffered + ( 1 : u.numOfPacketsBuffered ); % sd(i).frame - startPlottingFrame(i) + 1;
        u.imuData( u.frameRetrieved', : ) = u.data;
        
        if i == 1 % thx
            u.sag = [u.sag atan2d( - u.imuData( u.frameRetrieved, 6 ),  u.imuData( u.frameRetrieved, 5 ))']; % lineHandle
            u.sagAcos = [u.sagAcos real( acosd( round( u.imuData( u.frameRetrieved, 6 ) .* 2 / 2^15, 1)))'-90]; % lineHandle
            
            u.front = [u.front atan2d( - u.imuData( u.frameRetrieved, 4 ),  u.imuData( u.frameRetrieved, 5 ))']; % lineHandle
            u.frontAcos = [u.frontAcos real(acosd( round( u.imuData( u.frameRetrieved, 4 ).* 2 / 2^15, 1)))'-90]; % lineHandle
        
        else % hum
            
            u.front = [u.front atan2d( u.imuData( u.frameRetrieved, 6 ),  u.imuData( u.frameRetrieved, 5 ))']; % lineHandle
            u.frontAcos = [u.frontAcos real(acosd( round( - u.imuData( u.frameRetrieved, 6 ).* 2 / 2^15, 1)))'-90]; % lineHandle 
            
            u.sag = [u.sag atan2d( u.imuData( u.frameRetrieved, 4 ),  u.imuData( u.frameRetrieved, 5 ))']; % lineHandle
            u.sagAcos = [u.sagAcos real(acosd( round( - u.imuData( u.frameRetrieved, 4 ) .* 2 / 2^15, 1)))'-90]; % lineHandle
        end
        
        plotAngle( u.sag( end - (u.numOfPacketsBuffered-1) : end), u.sagAcos( end - (u.numOfPacketsBuffered-1) : end),...
            u.front( end - (u.numOfPacketsBuffered-1) : end), u.frontAcos( end - (u.numOfPacketsBuffered-1) : end),...
            u.frameRetrieved', u.p, u.SF, i )
        
        u.iii = u.iii + 1;
        
        if u.iii >= u.tasktoexecute - 1
            
            stop(tmr)
        end
    elseif etime( datevec( now ), u.onLineTime ) * 100 > 800
        msgbox(['The IMU ', num2str(i),' might be disconnected, please check the sensors status and connection'],'Error connection', 'warn');
        stop(tmr);
        error('IMU disconnected, please check the sensors status and connection');
    end
    
    set( tmr, 'UserData', u );
catch ME
    stop(tmr);
    disp(ME)
end