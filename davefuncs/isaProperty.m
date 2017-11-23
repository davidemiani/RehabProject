function bool = isaProperty(obj,prop,attribute,value)
mc = metaclass(obj);
propList = mc.PropertyList;
propNames = {propList(:).Name}';
propIndex = find(strcmp(propNames,prop));
switch attribute
    case {'Name','Description','DetailedDescription', ...
            'GetAccess','SetAccess'}
        bool = strcmp(propList(propIndex,1).(attribute),value);
    otherwise
        bool = propList(propIndex,1).(attribute)==value;
end
end
