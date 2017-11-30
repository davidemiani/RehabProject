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

% call builtin set if OBJ isn't an Exel object.
if ~isa(obj,'Exel')
    try
	    builtin('set', obj, PropertyName, PropertyValue);
    catch ME
        rethrow(ME);
    end
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
            obj.ValuesRequired = obj.AutoStop * obj.SamplingFrequency;
            
        case 'PacketName'
            % validating PacketName
            mustBeMember(PropertyValue,{'A'})              % values missing
            obj.PacketName = PropertyValue;
            switch obj.PacketName
                case 'A'
                    obj.PacketType = hex2dec('81');
                    obj.PacketHead = [obj.HeaderByte, obj.PacketType];
                    obj.PacketTypeCommand = [hex2dec('64'), ...
                        hex2dec('01'),hex2dec('38'), ...
                        hex2dec('00'),obj.PacketType];
                    obj.PacketTypeCommand = [obj.PacketTypeCommand, ...
                        mod(sum(obj.PacketTypeCommand),256)];
                    
                    obj.PacketSize = 11;
                    obj.BufferSize = obj.PacketsBuffered * obj.PacketSize;
                    
                    obj.DataNumber = 7;
                    obj.ByteGroups = {0;1;[2;3];[4;5];[6;7];[8;9];10};
                    obj.ByteTypes = {'uint8';'uint8';'uint16';'int16'; ...
                        'int16';'int16';'uint8'};
                    obj.DataNames = {'PacketHeader','PacketType', ...
                        'ProgrNum','AccX','AccY','AccZ','CheckSum'};
                    obj.Multiplier = [1;1;1;obj.Ka;obj.Ka;obj.Ka;1];
                otherwise
                    error('Exel:set:notSupportedPacketName', ...
                        '''%s'' PacketName still not supported.', ...
                        obj.PacketName)
            end
            
        case 'AccFullScale'
            % validating AccFullScale
            mustBeNumeric(PropertyValue)
            mustBeMember(PropertyValue,[2,4,8,16])
            obj.AccFullScale = PropertyValue;
            
        case 'GyrFullScale'
            % validating GyrFullSCale
            mustBeNumeric(PropertyValue)
            mustBeMember(PropertyValue,[250,500,1000,2000])
            obj.AccFullScale = PropertyValue;
            
        case 'SamplingFrequency'
            % validating SamplingFrequency
            mustBeNumeric(PropertyValue)
            mustBeMember(PropertyValue, ...
                [300,200,100,50,33.33,25,20,16.67,12.5,10,5])
            obj.SamplingFrequency = PropertyValue;
            obj.ValuesRequired = obj.AutoStop * obj.SamplingFrequency;
            
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