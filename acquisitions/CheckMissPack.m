function MissingPackets = CheckMissPack(obj)
% fornisco in ingresso il singolo sensore
% Per ogni sensore:
% Name
% Segment
% ismiss            comunica se sono stati persi campioni
% MissSamplesTot    quanti campioni sono stati persi
% PercSamples       � la percentuale rispetto al numero che avrebbe dovuto
%                   acquisire
% MissTime          dice il tempo a cui corrispondono i pacchetti persi
% WhereMiss         � una tabella che dice per ogni pezzo perso quanti campioni
%                   consecutivi, a che altezza e il tempo corrispondente.
%                   Se il sensore ha perso in un solo intervallo, � un
%                   numero
%%
fprintf(obj.Segment,' \n\n');

Nsamples = height(obj.ExelData);

MissingPackets = struct(...
        'ExelName',obj.ExelName,'Segment',obj.Segment,...
        'StartWithZero',obj.ExelData.ProgrNum(1) == 0,...
        'ismiss',0,'MissSamplesTot',0,'PercSamples',0,...
        'MissTime',0,'WhereMiss',[]);

DeltaSamples = diff(obj.ExelData.ProgrNum); 
DeltaSamples(DeltaSamples==-10000) = 1;
% %DeltaSamples ha Nsamples-1 valori

missvec = DeltaSamples-1;
missint = nnz(missvec);

if missint>0 
    fprintf('\nOps! Some packets miss!\n\n');
    
    if missint == 1
        MissingPackets.WhereMiss = find(DeltaSamples>1);
    else
        MissingPackets.WhereMiss = table;
        MissingPackets.WhereMiss.CutPointIndex = find(DeltaSamples>1); %se find=2 vuol dire che tra il campione 2 e 3 ho perso pacchetti
        MissingPackets.WhereMiss.SamplesNum    = DeltaSamples(MissingPackets.WhereMiss.CutPointIndex)-1;
        MissingPackets.WhereMiss.Time          = MissingPackets.WhereMiss.SamplesNum/fs;
    end
    
    MissingPackets.ismiss = 1;
    MissingPackets.MissSamplesTot = sum(missvec);
    MissingPackets.PercSamples    = MissingPackets.MissSamplesTot/Nsamples*100;
    MissingPackets.MissTime       = MissingPackets.MissSamplesTot/obj.SamplingFrequency;
    
    figure,stem([obj.ExelData.ProgrNum(1); DeltaSamples-1]),
    title([obj.Segment, ' Missing Samples'])
    xlabel('Sample Index'),ylabel('Missing Samples');

else
    fprintf('\nNo miss packets! :)\n\n')

end
end
