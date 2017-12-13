function PropertyValue = get(obj,PropertyName)
% GET Get Exel object properties.
%
%      PropertyValue = GET(OBJ,'PropertyName') returns the value,
%      PropertyValue, of the specified property, PropertyName, for Exel
%      object OBJ.
%
%      Example:
%        obj = Exel('EXLs3_0067');
%        AutoStop = get(obj,'AutoStop')
%
%        AutoStop =
%
%            15
%
%     See also Exel, Exel/set

if numel(obj)>1
    [m,n] = size(obj);
    PropertyValue = cell(m,n);
    for i = 1:m
        for j = 1:n
            PropertyValue{i,j} = obj(i,j).(PropertyName);
        end
    end
else
    PropertyValue = obj.(PropertyName);
end
end