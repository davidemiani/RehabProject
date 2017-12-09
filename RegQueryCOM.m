pulisci

ExelName = 'EXLs3_0158';
ComPort = getCOM(ExelName);


function COM = getCOM(FriendlyName)
% validating machine
mustBePc()

% quering for bluetooth devices written in registry
[~,Reg] = dosRegQuery( ...
    'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\BTHENUM','/s');

% getting device Key and ContainerID from Friendly Name
DevKey = Reg.Key(Reg.FriendlyName == FriendlyName);
if isempty(DevKey)
    error('getCOM:unknownDevice', ...
        'Device with FriendlyName %s not present in the registry.', ...
        FriendlyName)
end
DevContainer = Reg.ContainerID(Reg.FriendlyName == FriendlyName);

% looking for the device with the same container
SameContainerKeys = Reg.Key(Reg.ContainerID == DevContainer);
OtherDevWithSameContainerKey = setdiff(SameContainerKeys,DevKey);
DevParametersKey = string(fullfile(OtherDevWithSameContainerKey{1,1}, ...
    'Device Parameters'));

% getting COM port
COM = Reg.PortName(Reg.Key == DevParametersKey);
COM = COM{1,1};
end

function [status,result] = dosRegQuery(KEY,varargin)

mustBePc()
% creating query
EXP = KEY;
for j = 1:numel(varargin)
    cInput = varargin{1,j};
    if not(isblank(EXP(end)) || isblank(cInput(1)))
        EXP = cat(2,EXP,' ');
    end
    if not(strcmp(cInput(1),'/') || strcmp(cInput(1),'"'))
        cInput = cat(2,'"',cInput);
    end
    if not(strcmp(cInput(1),'/') || strcmp(cInput(end),'"'))
        cInput = cat(2,cInput,'"');
    end
    EXP = cat(2,EXP,cInput);
end

% query
[status,result] = dos(['REG QUERY ',EXP]);

% outputting
if status == 0
    % cleaning up dos query result
    result = strsplit(result,newline)';
    result = result(2:end-1);
    result(strfind(cellfun(@issubkey,result, ...
        repmat({KEY},size(result)))',[1,1])) = [];
    if issubkey(result{end,1},KEY),result(end) = [];end
    
    KeyIndexes = [find(cellfun(@issubkey,result, ...
        repmat({KEY},size(result))));numel(result)+1];
    
    for i = 1:numel(KeyIndexes)-1
        Reg(i,1).Key = result{KeyIndexes(i,1),1}; %#okAGROW
        
        cCell = result(KeyIndexes(i,1)+1:KeyIndexes(i+1,1)-1);
        cCell = cellfun(@strsplit,cCell, ...
            repmat({'    '},size(cCell)),'UniformOutput',false);
        cCell = [cCell{:}]';
        
        Name = cCell(2:4:end,1);
        Data = cCell(4:4:end,1);
        for ii = 1:numel(Name)
            Reg(i,1).(Name{ii,1}) = Data{ii,1};
        end
    end   
    varNames = fieldnames(Reg)';
    Reg = struct2cell(Reg)'; Reg(cellfun(@isempty,Reg)) = {''};
    Reg = string(Reg);
    result = array2table(Reg,'VariableNames',varNames);  
else
    % checking for 0 elements found
    if length(result)>6 && strcmp(result(2:6),'Error')
        error('dosRegQuery:queryError',result)
    else
        status = 0;
        result = {};
    end
end
end

function bool = issubkey(str,KEY)
if iscell(str)
    str = str{1,1};
end
if iscell(KEY)
    KEY = KEY{1,1};
end
if length(str)>=length(KEY) && strcmp(str(1:length(KEY)),KEY)
    bool = true;
else
    bool = false;
end
end

function bool = isblank(str)
if strcmp(str,' ')
    bool = true;
else
    bool = false;
end
end