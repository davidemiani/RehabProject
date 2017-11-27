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
                error('Segment must be char')
            end
            
        case 'AutoStop'
            % validating AutoStop
            mustBeNumeric(PropertyValue)
            mustBePositive(PropertyValue)
            obj.AutoStop = PropertyValue;
            
        case 'PacketName'
            % validating PacketName
            mustBeMember(PropertyValue,{'A'})              % values missing
            obj.PacketName = PropertyValue;
            
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
            
        case 'SamplingFcn'
            % validating SamplingFcn
            if isa(PropertyValue,'function_handle')
                obj.SamplingFcn = PropertyValue;
            else
                error('SamplingFcn must be a valid function handle')
            end
            
        case 'ExelFigure'
            % validating ExelFigure
            obj.ExelFigure = PropertyValue;
            obj.ExelFigureMode = 'Custom';
            
        otherwise
            % The user is trying to set a private or hidden property
            error(['You cannot set the property ',PropertyName])
    end
else
    % The user is trying to set a not valid property
    error([PropertyName,' is not a valid property'])
end
end