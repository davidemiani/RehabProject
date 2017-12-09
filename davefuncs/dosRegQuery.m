function [status,result] = dosRegQuery(KEY,varargin)
%DOSREGQUERY Execute dos REG QUERY.
%   [STATUS,RESULT] = DOSREGQUERY(KEY,OPT1,OPT2,...) returns the table
%   associated with the query specified by KEY and options OPT1,OPT2 ecc.
%   The querying routine is performed using the Microsoft Windows syntax.
%   You can find more information on dos REG QUERY at the link below:
%   https://technet.microsoft.com/en-us/library/cc742028(v=ws.11).aspx
%
%   KEY can be also a key shortcut; supported ones are:
%       * HKLM for HKEY_LOCAL_MACHINE
%       * BTHENUM for HKLM\SYSTEM\CurrentControlSet\Enum\BTHENUM
%       * ... help needed to add shortcuts!
%
%   Examples:
%       % querying the registry for subkeys starting from the BTHENUM KEY
%       % position:
%         [status,result] = dosRegQuery('BTHENUM');
%
%       % querying the registry recursively for all subkeys from the
%       % BYHENUM KEY POSITION:
%         [status,result] = dosRegQuery('BTHENUM','/s');
%
%       % quering the registry for Bluetooth devices PortName values:
%         [status,result] = dosRegQuery('BTHENUM','/s','/v','PortName');
%
%
%       % quering the registry only for Bluetooth devices with a certain
%       % PortName value:
%         [status,result] = dosRegQuery('BTHENUM','/s','/f','COM3');
%
%       % querying only for exact matches:
%         [status,result] = dosRegQuery('BTHENUM','/s','/f','COM3','/e');
%
%   See also dos, system, computer, getBluetoothPort
%
%   ------------------------------------
%   CREDITS:     Davide Miani (dec 2017)
%   LAST REVIEW: Davide Miani (dec 2017)
%   MAIL TO:     davide.miani2@gmail.com
%   ------------------------------------

% validating machine
mustBePc()

% checking if key is a shortcut
switch KEY
    case 'HKLM'
        KEY = 'HKEY_LOCAL_MACHINE';
    case 'BTHENUM'
        KEY = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\BTHENUM';
end

% creating query expression
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

% querying the registry
[status,result] = dos(['REG QUERY ',EXP]);

% outputting
if status == 0
    % cleaning up dos query result
    result = strsplit(result,newline)';
    result = result(2:end-1);
    
    KeyIndexes = [find(cellfun(@issubkey,result, ...
        repmat({KEY},size(result))));numel(result)+1];
    
    for i = 1:numel(KeyIndexes)-1
        Reg(i,1).Key = result{KeyIndexes(i,1),1}; %#okAGROW
        
        cCell = result(KeyIndexes(i,1)+1:KeyIndexes(i+1,1)-1);
        if not(isempty(cCell))
            cCell = cellfun(@strsplit,cCell, ...
                repmat({'    '},size(cCell)),'UniformOutput',false);
            cCell = [cCell{:}]';
            
            Name = cCell(2:4:end,1);
            Data = cCell(4:4:end,1);
            for ii = 1:numel(Name)
                Reg(i,1).(Name{ii,1}) = Data{ii,1};
            end
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
%ISSUBKEY Check if a char string is a subkey.
%
%   ------------------------------------
%   CREDITS:     Davide Miani (dec 2017)
%   LAST REVIEW: Davide Miani (dec 2017)
%   MAIL TO:     davide.miani2@gmail.com
%   ------------------------------------

% support for cellfun calling
if iscell(str)
    str = str{1,1};
end
if iscell(KEY)
    KEY = KEY{1,1};
end

% checking if subkey
if length(str)>=length(KEY) && strcmp(str(1:length(KEY)),KEY)
    bool = true;
else
    bool = false;
end
end

function bool = isblank(str)
%ISBLANK Check if a char str is a blank space.
%
%   ------------------------------------
%   CREDITS:     Davide Miani (dec 2017)
%   LAST REVIEW: Davide Miani (dec 2017)
%   MAIL TO:     davide.miani2@gmail.com
%   ------------------------------------
if strcmp(str,' ')
    bool = true;
else
    bool = false;
end
end