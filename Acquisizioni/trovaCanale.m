pulisci
b = Bluetooth('EXLs3_0067');

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
        i = i+1;
        fprintf('Channel #%d not supported\n',i)
    end
end