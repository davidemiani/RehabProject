function instrcallback(obj,~,~)
% INSTRCALLBACK
%
% See also 

% if acquisition is ended
if strcmp(obj.AcquisitionStatus,'off')
    return
end

% reading data from buffer
rawData = [obj.DisplacedData; ...
    fread(obj.Instrument,obj.BufferSize - numel(obj.DisplacedData))];

% finding new pkt starts indexes
pktStartIndexes = strfind(rawData',obj.PacketHead)';

% getting pkt lengths
pktLength = [diff(pktStartIndexes); ...
    numel(rawData) - pktStartIndexes(end,1)+1];

% filtering only full packets
pktStartIndexes = pktStartIndexes(pktLength == obj.PacketSize);

% computing PacketsRetrived
obj.PacketsRetrived = numel(pktStartIndexes);

% cutting away displaced data; putting them in the DisplacedData array
% property, in order to use them in the next callback call
if pktLength(end,1) ~= obj.PacketSize
    obj.DisplacedData = rawData(end-pktLength(end,1)+1:end,1);
end

% getting current row in ExelData
cRow = height(obj.ExelData);

% adding new rows on ExelData
obj.ExelData = [obj.ExelData; ...
    array2table(zeros(obj.PacketsRetrived,numel(obj.ExelVars)), ...
    'VariableNames',obj.ExelVars)];

% filling new rows
for iPkt = 1:obj.PacketsRetrived
    for iData = 1:numel(obj.DataNames)
        cVar = obj.DataNames{iData,1};
        if ismember(cVar,obj.ExelVars)
            cPktIndexes = pktStartIndexes(iPkt) + obj.ByteGroups{iData,1};
            cData = rawData(cPktIndexes,1);
            cByteType = obj.ByteTypes{iData,1};
            cMultiplier = obj.Multiplier(iData,1);
            obj.ExelData.(cVar)(cRow+iPkt,1) = cMultiplier * ...
                double(typecast(uint8(cData),cByteType));
        end
    end
end

% checking for the end
if height(obj.ExelData) >= obj.SamplesRequired
    stop(obj)
else
    if ~isempty(obj.SamplingFcn)
        % calling SamplingFcn
        obj.SamplingFcn(obj)
    end
end


end