function stopRecording( varargin )

tmr = varargin{1};
i = varargin{3};
u = get( tmr, 'UserData' );

if i == 1
    % profile off
    % profile viewer
end

[ok, u.h] = handleBluetooth( u.imu.(u.segments{i}).name, u.serialBufSize, i, 0, u.h );

if not( ok )
    
    handleBluetooth( u.imu.(u.segments{i}).name, u.serialBufSize, i, 0, u.h );
end

if i == 2
    set( gcf, 'Name', 'RealTimeData' )
end
end
