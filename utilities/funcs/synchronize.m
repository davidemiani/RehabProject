function  [obj,MissingPacketsReport] = synchronize(obj,MaxforInterp,plotAcc) 
%% MISSING PACKETS MANAGEMENT
%%
Nobjs = numel(obj);
Ts = 1/obj(1,1).SamplingFrequency;

if isempty(MaxforInterp) || Nobjs == 1
    MaxforInterp = 0;
end

%% ProgrNum sorting and Missing Packets Checking 
%as ProgrNum ranges from 0 to 9999, than the counter restarts

for j = 1:Nobjs
    if height(obj(j,1).ExelData)>10000
        obj(j,1).ExelData.ProgrNum = ProgrNumSorting(obj(j,1).ExelData.ProgrNum);
    end
    MissingPacketsReport(j,1) = CheckMissPack(obj(j,1));
end

%% adding rows
for j = 1:Nobjs
    if MissingPacketsReport(j,1).ismiss
        obj(j,1).ExelData = AddMissRow(...
            MissingPacketsReport(j,1),obj(j,1).ExelData,MaxforInterp,obj(j,1).PacketName);
    end
end

 %% final checking
% for j = 1:Nobjs
%     MissingPacketsReport(j,1) = CheckMissPack(obj(j,1));
% end


%% SYNCHRONIZATION AND EQUALIZING LENGTHS
%%
if Nobjs>1
    hobj = zeros(1,Nobjs);
    DataStart = zeros(Nobjs,1);
    for j = 1:Nobjs
        hobj(j) = height(obj(j,1).ExelData);
        %seconds of each datetime considering the time lag between start function and the first packet,too
        DataStart(j,1) = second(obj(j,1).StartTime) + Ts*obj(j,1).ExelData.ProgrNum(1);
    end
    
    %getting the last in time obj
    [~,lastObjStart] = max(DataStart);
    
    %getting time beetween each DataStart and the last one
    timeToLastObj    = abs(DataStart-DataStart(lastObjStart));
    
    %computing samples difference
    samplesToLastObj = floor(timeToLastObj/Ts);
    
    if nnz(samplesToLastObj)
        for j = 1:Nobjs
            obj(j,1).ExelData = obj(j,1).ExelData(samplesToLastObj(j)+1:end,:);
            obj(j,1).ExelData.ProgrNum = ...
                obj(j,1).ExelData.ProgrNum - samplesToLastObj(j);
        end
    end
    
    if nnz(diff(hobj))>0
        %looking for the shorter obj
        [~,shorterObj] = min(hobj);
        %deleting the longer objs in excess samples
        for j = 1:Nobjs
            obj(j,1).ExelData = obj(j,1).ExelData(1:hobj(shorterObj),:);
        end
    end
    
end

%% plotting
if plotAcc
    for j = 1:Nobjs
        figure
        subplot(311),plot(obj(j,1).ExelData{:,3}),title([obj(j,1).Segment,' AccX']);
        subplot(312),plot(obj(j,1).ExelData{:,4}),title([obj(j,1).Segment,' AccY']);
        subplot(313),plot(obj(j,1).ExelData{:,5}),title([obj(j,1).Segment,' AccZ']);
    end
end

%%
function vProgr = ProgrNumSorting(v)
%sorting the ProgrNum vector deleting the 0-10000 limits
M = 9999;

%finding the restarting ProgrNum or missing packets indixes 
dneg = find(diff(v)~=1)';

if ~isempty(dneg) 
    v = v';
    %dividing v vector in ranges with progressive numeration 
    vcell = mat2cell(v,1,[dneg(1) diff(dneg) length(v)-dneg(end)]);
    
    n_int = numel(vcell);
    first = vcell{1}(1);
    
    %new sorted vector
    vProgr = first:vcell{1}(end);
    
    %analising all the gaps between each two consecutive vectors     
    for i = 2:n_int
        Ncell = numel(vcell{i});
        
        if vcell{i-1}(end) == M && vcell{i}(1) == 0
            Miss = 0;
            
        elseif vcell{i-1}(end) == M && vcell{i}(1) > 0
            Miss = vcell{i}(1);
            
        elseif vcell{i-1}(end) < M && vcell{i}(1) == 0
            Miss = M-vcell{i-1}(end);
            
        elseif vcell{i-1}(end) < M && vcell{i}(1) > 0 && vcell{i-1}(end) > vcell{i}(1)
            Miss = vcell{i}(1) + M-vcell{i-1}(end);
            
        elseif vcell{i-1}(end) < vcell{i}(1)
            Miss = vcell{i}(1) - vcell{i-1}(end) - 1;
            
        end
        
        vProgr = [vProgr vProgr(end) + Miss + 1 : vProgr(end) + Ncell + Miss];
    end
    vProgr = vProgr';
else  %initial ProgrNum has only progressive number
    vProgr = v;
end
end
function ExelData = AddMissRow(MissingPacketsReport,ExelData,MaxforInterp,PacketName)
%the function fills in the gaps of the missing samples with Nan if the gap
%length is more than MaxforInterp, while connects the no consecutive
%samples with a linear interpolation

for int = 1:size(MissingPacketsReport.WhereMiss)
    
    if istable(MissingPacketsReport.WhereMiss)
        lastProgrNum = MissingPacketsReport.WhereMiss.CutProgrNum(int);
        deltaSample = MissingPacketsReport.WhereMiss.SamplesNum(int);
    else
        lastProgrNum = MissingPacketsReport.WhereMiss;
        deltaSample = MissingPacketsReport.MissSamplesTot;
    end
    
    
    %filling in the gaps with zeros lines
    ExelData{ find( ExelData.ProgrNum == lastProgrNum) + 1 : end+deltaSample, :} = ...
        [ zeros(deltaSample,16);
        ExelData{ find( ExelData.ProgrNum == lastProgrNum) + 1 : end, :}];
        
    %resetting ProgrNum with missing numbers
    ExelData.ProgrNum(...
        lastProgrNum + 2 : lastProgrNum + deltaSample + 1) = ...
        (lastProgrNum + 1 : lastProgrNum + deltaSample)';
    
    
    %resetting PacketType and Vbat with the last value before breack
    ExelData{...
        lastProgrNum + 2 : lastProgrNum + deltaSample + 1,[2 end]} = ...
        ExelData{lastProgrNum + 1,[2 end]}.*ones(deltaSample,2);
    
    
    if deltaSample > MaxforInterp
         
        %filling in with nan
        ExelData{...
            lastProgrNum+2 : lastProgrNum + deltaSample + 1,3:15} = ...
            nan.*ones(deltaSample,13);
        
    else
        %linear interpolation
        ExelData = InterpMissData(ExelData,lastProgrNum,deltaSample,PacketName);
        
    end
end
end
function ExelData = InterpMissData(ExelData,lastProgrNum,deltaSample,PacketName)
%linear interpolation of missing packets with polyfit and polyval
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
% For each obj, the MissingPackets struct gives:
% Name
% Segment
% StartWithZero     1 if the first ProgrNum is 0
% ismiss            1 if there are missing packets
% MissSamplesTot    how many samples are missing
% PercSamples       percentage of missing samples on the whole acquisition
% MissTime          corresponding missing time
% WhereMiss         if there is only one range of missing packets, is the
%                   index of breack point. If there are more than one
%                   range, is a table that for each range gives:
%                   corresponding time, index of breack point and the
%                   number of missing samples

%%
fprintf(obj.Segment,' \n\n');

MissingPackets = struct(...
        'ExelName',obj.ExelName,'Segment',obj.Segment,...
        'StartWithZero',obj.ExelData.ProgrNum(1) == 0,...
        'ismiss',false,'MissSamplesTot',0,'PercSamples',0,...
        'MissTime',0,'WhereMiss',[]);

%if there are missing packets, "diff" is not a ones vector
DeltaSamples = diff(obj.ExelData.ProgrNum); 
%DeltaSamples has Nsamples-1 values

missvec = DeltaSamples-1;
missint = nnz(missvec);

% filling in the struct if there are missing packets
if missint>0 
    fprintf('\nOps! Some packets miss!\n\n');
    
    if missint == 1
        MissingPackets.WhereMiss = obj.ExelData.ProgrNum(DeltaSamples>1);
    else
        MissingPackets.WhereMiss = table;
        MissingPackets.WhereMiss.CutProgrNum  = obj.ExelData.ProgrNum(DeltaSamples>1); 
        %that is if find=2, than between 2nd and 3th samples there are missing samples
        MissingPackets.WhereMiss.SamplesNum    = DeltaSamples(DeltaSamples>1)-1;
        MissingPackets.WhereMiss.Time          = MissingPackets.WhereMiss.SamplesNum/obj.SamplingFrequency;
    end
    
    MissingPackets.ismiss = true;
    MissingPackets.MissSamplesTot = sum(missvec);
    MissingPackets.PercSamples    = MissingPackets.MissSamplesTot/(obj.ExelData{end,1}+1)*100;
    MissingPackets.MissTime       = MissingPackets.MissSamplesTot/obj.SamplingFrequency;
    
    figure,stem([obj.ExelData.ProgrNum(1); DeltaSamples-1]),
    title([obj.Segment, ' Missing Samples'])
    xlabel('Sample Index'),ylabel('Missing Samples');

else
    fprintf('\nNo miss packets! :)\n\n')

end
end
%%



end




