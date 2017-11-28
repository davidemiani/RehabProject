pulisci
b = Bluetooth('EXLs3');

i = 0;
run = true;
while i<=79 && run
    try
        b.Channel = i;
        tic
        fopen(b);
        run = false;
    catch
        toc
        
        fprintf('Channel #%d not supported\n',i)
        i = i+1;
    end
end