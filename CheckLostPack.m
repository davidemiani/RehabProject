function IMULost = CheckLostPack(IMUdata)
%la funzione restituisce una struct 1xNumeroSensori
%%
%% PER USARE LA FUNZIONE con file .txt 
% caricare dalla Command Window con il comando 
%% IMUdata=readtable(filename)
%%
%Per ogni sensore:
% islost            comunica se sono stati persi pacchetti
% NumberPackets     quanti campioni sono stati persi
% PercPAckets       è la percentuale rispetto al numero che avrebbe dovuto
%                   acquisire
% TimeLost          dice il tempo a cui corrispondono i pacchetti persi
% WhereLost         è una tabella che dice per ogni pezzo perso quanti campioni
%                   consecutivi, a che altezza e il tempo corrispondente
Nsamples = size(IMUdata,1);
FS=50;

%definisco la struttura
IMULost=struct('islost',0,'NumberPackets',0,'PercPackets',0,'TimeLost',0,'WhereLost',[]);

DeltaPackets=diff(IMUdata.ProgrNum); %ha dimensione pari a Nsample-1
IMULost.WhereLost=table;
IMULost.WhereLost.IndexSample=find(DeltaPackets>1); %se find=2 vuol dire che tra il campione 2 e 3 ho perso pacchetti
IMULost.WhereLost.NumSamples=DeltaPackets(IMULost.WhereLost.IndexSample)-1;
IMULost.WhereLost.Time=IMULost.WhereLost.NumSamples/FS;

if sum(DeltaPackets)==Nsamples-1
    disp('Nessun pacchetto perso');
else
    disp('Sono stati persi dei pacchetti!');
    
    IMULost.islost=1;
    IMULost.NumberPackets = sum(DeltaPackets)-(Nsamples-1);
    IMULost.PercPackets = IMULost.NumberPackets/(IMUdata.ProgrNum(end)+1)*100;
    IMULost.TimeLost = IMULost.NumberPackets/FS;
    
    figure,stem(DeltaPackets-1),
    title('LostPackets'),ylim([-1 Nsamples/100]),
    xlabel('Tempo'),ylabel('LostPackets');

end


end

