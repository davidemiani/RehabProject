%script per interpolazione
%ho in ingresso un CELL ARRAY con gli oggetti Exel. di ognuno prendo
%IMUdata 
%PER ORA considero che sono tutti sincronizzati e con la stessa fc
%Exel è il mio cell array con gli oggetti
clc,clear all,close all
path(path,fullfile(cd('../'),'davefuncs'));
Exel(1).IMUdata=exelLog2table('hom.txt');
Exel(2).IMUdata=exelLog2table('thx.txt');
%% simulazione pacchetti persi
%cutPacket mi genera un numero casuale intero per localizzare il punto in
%cui tagliare. L'indice della riga è maggiore di un'unità rispetto a ProgrNum
%Se CutPacket=10, taglierò ProgrNum da 9 a 9+NumCut
NumCut=20;
CutPacket1=randi(Exel(1).IMUdata.ProgrNum(end));
CutPacket2=randi(Exel(2).IMUdata.ProgrNum(end));
Exel(1).IMUdata(CutPacket1:CutPacket1+NumCut-1,:)=[];
Exel(2).IMUdata(CutPacket2:CutPacket2+NumCut-1,:)=[];
NumCut=1;
CutPacket1=randi(Exel(1).IMUdata.ProgrNum(end));
CutPacket2=randi(Exel(2).IMUdata.ProgrNum(end));
Exel(1).IMUdata(CutPacket1:CutPacket1+NumCut-1,:)=[];
Exel(2).IMUdata(CutPacket2:CutPacket2+NumCut-1,:)=[];

%%

Nobj = length(Exel); %2
MaxforInterp = 10;
for i = 1:Nobj
    %disp(Exel(i).IMUname)
    IMULost(i) = CheckLostPack(Exel(i).IMUdata);
    
    if IMULost(i).islost
            Exel(i).IMUdata = AddLostRow(IMULost(i),Exel(i).IMUdata,MaxforInterp);
    end

end


%%


