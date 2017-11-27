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

PropertyValue = obj.(PropertyName);
end