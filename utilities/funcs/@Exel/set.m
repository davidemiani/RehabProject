function set(obj,PropertyName,PropertyValue)
% SET Configure Exel object properties.
%
%     SET(OBJ,'PropertyName',PropertyValue,...) configures the property, 
%     PropertyName, to the specified value, PropertyValue, for Exel 
%     object OBJ. OBJ can be a single Exel object or a vector of Exel 
%     objects, in which case set configures the property values for all
%     the timer objects specified.
%
%     Example:
%        obj = Exel('EXLs3_0067');
%        set(obj,'AutoStop',60)
%
%     See also Exel, Exel/get

% checking for multidimensional inputs
if numel(obj)>1
    [m,n] = size(obj);
    for i = 1:m
        for j = 1:n
            set(obj(i,j),PropertyName,PropertyValue)
        end
    end
    return
end

% to avoid empty indexing
if isempty(obj)
    return
end

% checking for prop existency
if isprop(obj,PropertyName)
    % switching between cases
    switch PropertyName
        case 'Segment'
            % validating Segment
            if ischar(PropertyValue)
                obj.Segment = PropertyValue;
            else
                error('Exel:set:invalidSegmentPropertyValue', ...
                    'The ''Segment'' property must be char.')
            end
            
        case 'AutoStop'
            % validating AutoStop
            mustBeNumeric(PropertyValue)
            mustBePositive(PropertyValue)
            obj.AutoStop = PropertyValue;
            
        case 'Subject'
            % validating Subject
            mustBeCharacter(PropertyValue)
            obj.Subject = PropertyValue;
            
        case 'PacketName'
            % validating PacketName
            mustBeMember(PropertyValue,{'A','AGMOB'})              % values missing
            obj.PacketName = PropertyValue;
            switch obj.PacketName
                case 'A'
                    obj.PacketType = hex2dec('81');
                    obj.PacketHead = [obj.HeaderByte,obj.PacketType];
                    obj.PacketTypeCommand = [ ...
                        hex2dec('64'), ...
                        hex2dec('01'), ...
                        hex2dec('38'), ...
                        hex2dec('00'), ...
                        obj.PacketType];
                    obj.PacketTypeCommand = [ ...
                        obj.PacketTypeCommand, ...
                        mod(sum(obj.PacketTypeCommand),256)];
                    
                    obj.DataNames = { ...
                        'HeaderByte'; ...
                        'PacketType'; ...
                        'ProgrNum'; ...
                        'AccX'; ...
                        'AccY'; ...
                        'AccZ'; ...
                        'CheckSum'};
                    obj.ByteGroups = { ...
                        0; ... % HeaderByte
                        1; ... % PacketType
                        [2;3]; ... % ProgrNum
                        [4;5]; ... % AccX
                        [6;7]; ... % AccY
                        [8;9]; ... % AccZ
                        10}; % CheckSum
                    obj.ByteTypes = { ...
                        'uint8'; ... % HeaderByte
                        'uint8'; ... % PacketType
                        'uint16'; ... % ProgrNum
                        'int16'; ... % AccX
                        'int16'; ... % AccY
                        'int16'; ... % AccZ
                        'uint8'}; % CheckSum
                    obj.Multiplier = [ ...
                        1; ... % HeaderByte
                        1; ... % PacketType
                        1; ... % ProgrNum
                        obj.Ka; ... % AccX
                        obj.Ka; ... % AccY
                        obj.Ka; ... % AccZ
                        1]; % CheckSum
                    
                    obj.DataNumber = size(obj.DataNames,1);
                    obj.PacketSize = sum(cellfun(@numel,obj.ByteGroups));
                    obj.BufferSize = obj.PacketsBuffered * obj.PacketSize;
                case 'AGMOB'
                    obj.PacketType = hex2dec('9F');
                    obj.PacketHead = [obj.HeaderByte,obj.PacketType];
                    obj.PacketTypeCommand = [ ...
                        hex2dec('64'), ...
                        hex2dec('01'), ...
                        hex2dec('38'), ...
                        hex2dec('00'), ...
                        obj.PacketType];
                    obj.PacketTypeCommand = [ ...
                        obj.PacketTypeCommand, ...
                        mod(sum(obj.PacketTypeCommand),256)];
                    
                    obj.DataNames = { ...
                        'HeaderByte'; ...
                        'PacketType'; ...
                        'ProgrNum'; ...
                        'AccX'; ...
                        'AccY'; ...
                        'AccZ'; ...
                        'GyrX'; ...
                        'GyrY'; ...
                        'GyrZ'; ...
                        'MagX'; ...
                        'MagY'; ...
                        'MagZ'; ...
                        'Q0'; ...
                        'Q1'; ...
                        'Q2'; ...
                        'Q3'; ...
                        'VBat'; ...
                        'CheckSum'};
                    obj.ByteGroups = { ...
                        0; ... % HeaderByte
                        1; ... % PacketType
                        [2;3]; ... % ProgrNum
                        [4;5]; ... % AccX
                        [6;7]; ... % AccY
                        [8;9]; ... % AccZ
                        [10;11]; ... % GyrX
                        [12;13]; ... % GyrY
                        [14;15]; ... % GyrZ
                        [16;17]; ... % MagX
                        [18;19]; ... % MagY
                        [20;21]; ... % MagZ
                        [22;23]; ... % Q0
                        [24;25]; ... % Q1
                        [26;27]; ... % Q2
                        [28;29]; ... % Q3
                        [30;31]; ... % VBat
                        32}; % CheckSum
                    obj.ByteTypes = { ...
                        'uint8'; ... % HeaderByte
                        'uint8'; ... % PacketType
                        'uint16'; ... % ProgrNum
                        'int16'; ... % AccX
                        'int16'; ... % AccY
                        'int16'; ... % AccZ
                        'int16'; ... % GyrX
                        'int16'; ... % GyrY
                        'int16'; ... % GyrZ
                        'int16'; ... % MagX
                        'int16'; ... % MagY
                        'int16'; ... % MagZ
                        'int16'; ... % Q0
                        'int16'; ... % Q1
                        'int16'; ... % Q2
                        'int16'; ... % Q3
                        'uint16'; ... % VBat
                        'uint8'}; % CheckSum
                    obj.Multiplier = [ ...
                        1; ... % HeaderByte
                        1; ... % PacketType
                        1; ... % ProgrNum
                        obj.Ka; ... % AccX
                        obj.Ka; ... % AccY
                        obj.Ka; ... % AccZ
                        obj.Kg; ... % GyrX
                        obj.Kg; ... % GyrY
                        obj.Kg; ... % GyrZ
                        obj.Km; ... % MagX
                        obj.Km; ... % MagY
                        obj.Km; ... % MagZ
                        obj.Qn; ... % Q0
                        obj.Qn; ... % Q1
                        obj.Qn; ... % Q2
                        obj.Qn; ... % Q3
                        1; ... % VBat
                        1]; % CheckSum
                    
                    obj.DataNumber = size(obj.DataNames,1);
                    obj.PacketSize = sum(cellfun(@numel,obj.ByteGroups));
                    obj.BufferSize = obj.PacketsBuffered * obj.PacketSize;
                otherwise
                    error('Exel:set:notSupportedPacketName', ...
                        '''%s'' PacketName still not supported.', ...
                        obj.PacketName)
            end
            
        case 'Calibration'
            % validating Calibration
            mustBeNumeric(PropertyValue)
            [m,n] = size(PropertyValue);
            if m==3 && n==3
                obj.Calibration = PropertyValue;
            end
            
        case 'AccFullScale'
            % validating AccFullScale
            mustBeNumeric(PropertyValue)
            mustBeMember(PropertyValue,[2,4,8,16])
            obj.AccFullScale = PropertyValue;
            obj.Ka = obj.AccFullScale / 32768;
            set(obj,'PacketName',get(obj,'PacketName'))
            
        case 'GyrFullScale'
            % validating GyrFullSCale
            mustBeNumeric(PropertyValue)
            mustBeMember(PropertyValue,[250,500,1000,2000])
            obj.AccFullScale = PropertyValue;
            obj.Kg = obj.GyrFullScale / 32768;
            set(obj,'PacketName',get(obj,'PacketName'))
            
        case 'SamplingFrequency'
            % validating SamplingFrequency
            mustBeNumeric(PropertyValue)
            mustBeMember(PropertyValue, ...
                [300,200,100,50,33.33,25,20,16.67,12.5,10,5])
            obj.SamplingFrequency = PropertyValue;
            
        case 'SamplingFcn'
            % validating SamplingFcn
            if isa(PropertyValue,'function_handle')
                obj.SamplingFcn = PropertyValue;
            else
                error('Exel:set:invalidSamplingFcn', ...
                    'SamplingFcn must be a valid function handle.')
            end
            
        case 'ExelFigure'
            % validating ExelFigure
            obj.ExelFigure = PropertyValue;
            obj.ExelFigureMode = 'Custom';
            
        case 'UserData'
            % validating UserData
            obj.UserData = PropertyValue;
            
        otherwise
            % The user is trying to set a private or hidden property
            error('Exel:set:cannotSetPrivateProperty', ...
                'You cannot set the property %s.',PropertyName)
    end
else
    % The user is trying to set a not valid property
    error('Exel:set:invalidPropertyName', ...
        '%s is not a valid PropertyName.',PropertyName)
end
end