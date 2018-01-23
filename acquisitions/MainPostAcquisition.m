%% MISSING PACKETS MANAGEMENT
%%
pulisci
%% loading 
acqdir = cd;
cd(fullfile(cd,'2017-12-05'));  %data directory
load('DM94_20.mat');            %data file
cd(acqdir);

Nobjs = numel(obj); %2
Ts = 1/obj(1,1).SamplingFrequency;

objold = obj;

%% sorting
for i = 1:Nobjs
    %if height(obj(i,1).ExelData)>10001
        obj(i,1).ExelData.ProgrNum = ProgrNumSorting(obj(i,1).ExelData.ProgrNum);
    %end
end

%% checking
for i = 1:Nobjs
    MissingPacketsReport(i,1) = CheckMissPack(obj(i,1));
end
%pause
%% adding rows
for i = 1:Nobjs
    MaxforInterp = 200;
    if MissingPacketsReport(i,1).ismiss
        obj(i,1).ExelData = AddMissRow(MissingPacketsReport(i,1),obj(i,1).ExelData,MaxforInterp,obj(i,1).PacketName);
    end
end


%% synchronization 
if Nobjs>1
    for i = 1:Nobjs
        %seconds of each datetime considering the time lag between start function and the first packet,too
        DataStart(i,1) = second(obj(i,1).StartTime) + Ts*obj(i,1).ExelData.ProgrNum(1);
    end
    
    %getting the last in time obj
    [~,lastObjStart] = max(DataStart);
    
    %getting time beetween each DataStart and the last one
    timeToLastObj    = abs(DataStart-DataStart(lastObjStart));
    
    %computing samples difference
    samplesToLastObj = floor(timeToLastObj/Ts);
    
    if nnz(samplesToLastObj)
        for i = 1:Nobjs
            obj(i,1).ExelData = obj(i,1).ExelData(samplesToLastObj(i)+1:end,:);
            obj(i,1).ExelData.ProgrNum = ...
                obj(i,1).ExelData.ProgrNum - samplesToLastObj(i);
        end
    end
end
 %% final checking
% for i = 1:Nobjs
%     MissingPacketsReport(i,1) = CheckMissPack(obj(i,1));
% end
% %pause

function vProgr = ProgrNumSorting(v)
%ordinamento del vettore ProgrNum di ExelData eliminando i limiti 0-10000
M = 9999;

%trovo le posizioni in cui ricomincia la numerazione oppure c'è un salto
dneg = find(diff(v)~=1)';

if ~isempty(dneg) 
    v = v';
    %divido il vettore v in intervalli aventi numerazione consecutiva
    vcell = mat2cell(v,1,[dneg(1) diff(dneg) length(v)-dneg(end)]);
    
    n_int = numel(vcell);
    first = vcell{1}(1);
    
    %nuovo vettore riordinato
    vProgr = first:vcell{1}(end);
    
    %nel for vengono analizzati tutti i casi di passaggio da un intervallo
    %all'altro
    
    for i = 2:n_int
        Ncell = numel(vcell{i});
        
        if vcell{i-1}(end) == M & vcell{i}(1) == 0
            Miss = 0;
            
        elseif vcell{i-1}(end) == M & vcell{i}(1) > 0
            Miss = vcell{i}(1);
            
        elseif vcell{i-1}(end) < M & vcell{i}(1) == 0
            Miss = M-vcell{i-1}(end);
            
        elseif vcell{i-1}(end) < M & vcell{i}(1) > 0 & vcell{i-1}(end) > vcell{i}(1)
            Miss = vcell{i}(1) + M-vcell{i-1}(end);
            
        elseif vcell{i-1}(end) < vcell{i}(1)
            Miss = vcell{i}(1) - vcell{i-1}(end) - 1;
            
        end
        
        vProgr = [vProgr vProgr(end) + Miss + 1 : vProgr(end) + Ncell + Miss];
    end
    vProgr = vProgr';
else  %il vettore ProgrNum ha tutti numeri consecutivi
    vProgr = v;
end
end
function ExelData = AddMissRow(MissingPacketsReport,ExelData,MaxforInterp,PacketName)

for int = 1:size(MissingPacketsReport.WhereMiss)
    int
    if istable(MissingPacketsReport.WhereMiss)
        lastProgrNum = MissingPacketsReport.WhereMiss.CutProgrNum(int);
        deltaSample = MissingPacketsReport.WhereMiss.SamplesNum(int);
    else
        lastProgrNum = MissingPacketsReport.WhereMiss;
        deltaSample = MissingPacketsReport.MissSamplesTot;
    end
    
    
    %ampliamento tabella dati con zeri
    ExelData{ find( ExelData.ProgrNum == lastProgrNum) + 1 : end+deltaSample, :} = ...
        [ zeros(deltaSample,16);
        ExelData{ find( ExelData.ProgrNum == lastProgrNum) + 1 : end, :}];
        
%     ExelData{ lastProgrNum+1 : end+deltaSample, :} =...
%         [ zeros(deltaSample,16);
%         ExelData{lastProgrNum+1 : end, :}];
    
    
    %reimposto la colonna ProgrNum inserendo numeri progressivi
    ExelData.ProgrNum(...
        lastProgrNum + 2 : lastProgrNum + deltaSample + 1) = ...
        (lastProgrNum + 1 : lastProgrNum + deltaSample)';
    
    
    %reimposto la colonna PacketType e Vbat inserendo l'ultimo
    %valore prima della perdita
    ExelData{...
        lastProgrNum + 2 : lastProgrNum + deltaSample + 1,[2 end]} = ...
        ExelData{lastProgrNum + 1,[2 end]}.*ones(deltaSample,2);
    
    
    if deltaSample > MaxforInterp
            
        ExelData{...
            lastProgrNum+1 : lastProgrNum + deltaSample,3:15} = ...
            nan.*ones(deltaSample,13);
        
    else
        
        ExelData = InterpMissData(ExelData,lastProgrNum,deltaSample,PacketName);
        
    end
end
end
function ExelData = InterpMissData(ExelData,lastProgrNum,deltaSample,PacketName)

x = [lastProgrNum lastProgrNum + deltaSample + 1];
GrInterp=1;
if  PacketName == 'A'
    lastcol = 5;
else
    lastcol = 15;
end

for column = 3:lastcol
    
    y = ExelData{[lastProgrNum + 1 lastProgrNum + 1 + deltaSample + 1],column}';
    coeff = polyfit(x,y,GrInterp);
    xnew=x(1):x(2);
    ynew=polyval(coeff,xnew)';
    ExelData{...
        lastProgrNum + 1 : lastProgrNum + 1 + deltaSample + 1,column} = ...
        ynew;
end
end
function MissingPackets = CheckMissPack(obj)
% fornisco in ingresso il singolo sensore
% Per ogni sensore:
% Name
% Segment
% StartWithZero     comunica se il vettore ProgrNum inizia con 0
% ismiss            comunica se sono stati persi campioni
% MissSamplesTot    quanti campioni sono stati persi
% PercSamples       è la percentuale rispetto al numero che avrebbe dovuto
%                   acquisire
% MissTime          dice il tempo a cui corrispondono i pacchetti persi
% WhereMiss         è una tabella che dice per ogni pezzo perso quanti campioni
%                   consecutivi, a che altezza e il tempo corrispondente.
%                   Se il sensore ha perso in un solo intervallo, è un
%                   numero
%%
fprintf(obj.Segment,' \n\n');

Nsamples = height(obj.ExelData);

MissingPackets = struct(...
        'ExelName',obj.ExelName,'Segment',obj.Segment,...
        'StartWithZero',obj.ExelData.ProgrNum(1) == 0,...
        'ismiss',false,'MissSamplesTot',0,'PercSamples',0,...
        'MissTime',0,'WhereMiss',[]);

DeltaSamples = diff(obj.ExelData.ProgrNum); 
%DeltaSamples ha Nsamples-1 valori

missvec = DeltaSamples-1;
missint = nnz(missvec);

if missint>0 
    fprintf('\nOps! Some packets miss!\n\n');
    
    if missint == 1
        MissingPackets.WhereMiss = obj.ExelData.ProgrNum(DeltaSamples>1);
    else
        MissingPackets.WhereMiss = table;
        MissingPackets.WhereMiss.CutProgrNum  = obj.ExelData.ProgrNum(DeltaSamples>1); %se find=2 vuol dire che tra il campione 2 e 3 ho perso pacchetti
        MissingPackets.WhereMiss.SamplesNum    = DeltaSamples(DeltaSamples>1)-1;
        MissingPackets.WhereMiss.Time          = MissingPackets.WhereMiss.SamplesNum/obj.SamplingFrequency;
    end
    
    MissingPackets.ismiss = true;
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








