timers = timerfindall;
for i = 1 : numel( timers )
    try
        stop( timers(i) )
        delete( timers(i) );
    catch ME
    end
end
clear i timers 