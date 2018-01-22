%% MISSING PACKETS MANAGEMENT
%%
pulisci
%% loading 
acqdir = cd;
cd(fullfile(cd,'2018-01-18'));  %data directory
load('MM17_08.mat');            %data file
cd(acqdir);

Nobjs = numel(obj); %2
Ts = 1/obj(1,1).SamplingFrequency;


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
%sensors synchronization removing the first rows of the 
%first starting obj if time between the StartTime > Ts
%reset ProgrNum from 0
for i = 1:Nobjs
    DataStart(i,1) = second(obj(i,1).StartTime) + Ts*obj(i,1).ExelData.ProgrNum(1);
end
[~,lastObjStart] = max(DataStart);
timeToLastObj    = abs(DataStart-DataStart(lastObjStart));
samplesToLastObj = floor(timeToLastObj/Ts);
if nnz(samplesToLastObj)
    for i = 1:Nobjs
        obj(i,1).ExelData = obj(i,1).ExelData(samplesToLastObj(i)+1:end,:);
        obj(i,1).ExelData.ProgrNum = ...
            obj(i,1).ExelData.ProgrNum - samplesToLastObj(i);
    end
end

%% ProgrNum
% ProgrNum ranges from 0 to 10000 -> the counter restart after 10001 samples 
for i = 1:Nobjs
    Nsamples = height(obj(i,1).ExelData)
    FirstSample = obj(i,1).ExelData.ProgrNum(1);
    
    if Nsamples > 10000
        ProgrNumNew = (FirstSample:(Nsamples-1)+FirstSample);  
        obj(i,1).ExelData{:,1} = ProgrNumNew;
    end
    Nsamples = height(obj(i,1).ExelData)
end



function ExelData = AddMissRow(MissingPacketsReport,ExelData,MaxforInterp,PacketName)

for int = 1:size(MissingPacketsReport.WhereMiss)
    
    if istable(MissingPacketsReport.WhereMiss)
        lastSampleIndex = MissingPacketsReport.WhereMiss.CutPointIndex(int);
        deltaSample = MissingPacketsReport.WhereMiss.SamplesNum(int);
    else
        lastSampleIndex = MissingPacketsReport.WhereMiss;
        deltaSample = MissingPacketsReport.MissSamplesTot;
    end
    
    
    %ampliamento tabella dati con zeri
    ExelData{ lastSampleIndex+1 : end+deltaSample, :} =...
        [ zeros(deltaSample,16);
        ExelData{lastSampleIndex+1 : end, :}];
    
    
    %reimposto la colonna ProgrNum inserendo numeri progressivi
    ExelData.ProgrNum(...
        lastSampleIndex+1 : lastSampleIndex + 1 + deltaSample) = ...
        (lastSampleIndex : lastSampleIndex+deltaSample)';
    
    
    %reimposto la colonna PacketType e Vbat inserendo l'ultimo
    %valore prima della perdita
    ExelData{...
        lastSampleIndex+1 : lastSampleIndex + deltaSample,[2 end]} = ...
        ExelData{lastSampleIndex,[2 end]}.*ones(deltaSample,2);
    
    
    if deltaSample > MaxforInterp
            
        ExelData{...
            lastSampleIndex+1 : lastSampleIndex + deltaSample,3:15} = ...
            nan.*ones(deltaSample,13);
        
    else
        
        ExelData = InterpMissData(ExelData,lastSampleIndex,deltaSample,PacketName);
        
    end
end
end
function ExelData = InterpMissData(ExelData,lastSampleIndex,deltaSample,PacketName)

x = ExelData{[lastSampleIndex lastSampleIndex+deltaSample+1],1};
GrInterp=1;
if  PacketName == 'A'
    lastcol = 5;
else
    lastcol = 15;
end

for column = 3:lastcol
    
    y = ExelData{[lastSampleIndex lastSampleIndex+deltaSample+1],column};
    coeff = polyfit(x,y,GrInterp);
    xnew=x(1):x(2);

    ExelData{...
        lastSampleIndex : lastSampleIndex + deltaSample + 1,column} = ...
        polyval(coeff,xnew)';
end
end








