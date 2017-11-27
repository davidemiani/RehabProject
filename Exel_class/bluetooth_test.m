clc, close all, clearExcept obj

obj.ImuName = 'EXLs3_0067';
obj.Autostop = 10;
obj.SamplingFrequency = 50;
obj.SamplesRequired = obj.Autostop * obj.SamplingFrequency;

obj.Ka = 2 * 9.807 / 32768;
obj.Kg = 250 / 32768;
obj.Km = 0.007629;
obj.qn = 1 / 16384;

obj.PacketSize = 11;
obj.PacketsBuffered = 6;
obj.BufferSize = obj.PacketsBuffered * obj.PacketSize;
obj.DisplacedData = [];

obj.HeaderByte = hex2dec('20');
obj.PacketType = hex2dec('81');
obj.PacketHead = [obj.HeaderByte, obj.PacketType];
obj.PacketComm = [hex2dec('64'),hex2dec('01'), ...
    hex2dec('38'),hex2dec('00'),obj.PacketType];
obj.PacketComm = [obj.PacketComm,mod(sum(obj.PacketComm),256)];

obj.DataNumber = 7;
obj.ByteGroups = {0;1;[2;3];[4;5];[6;7];[8;9];10};
obj.ByteTypes = {'uint8';'uint8';'uint16';'int16';'int16';'int16';'uint8'};
obj.DataNames = {'PacketHeader','PacketType','ProgrNum','AccX','AccY','AccZ','CheckSum'};
obj.Multiplier = [1;1;1;obj.Ka;obj.Ka;obj.Ka;1];

obj.ExelVars = {'ProgrNum','PacketType', ...
    'AccX','AccY','AccZ', ...
    'GyrX','GyrY','GyrZ', ...
    'MagX','MagY','MagZ', ...
    'Q0','Q1','Q2','Q3',  ...
    'Vbat'};
obj.ExelData = cell2table(cell(0,16),'VariableNames',obj.ExelVars);
obj.Counter = 0;

if ~isfield(obj,'Blue')
    obj.Blue = Bluetooth(obj.ImuName,1);
    obj.Blue.InputBufferSize = obj.BufferSize * 2;
    obj.Blue.BytesAvailableFcnMode = 'byte';
    obj.Blue.BytesAvailableFcnCount = obj.BufferSize;
    obj.Blue.BytesAvailableFcn = @instrcallback;
end

% opening communication
fopen(obj.Blue);

% adding UserData and starting data stream
obj.Blue.UserData = obj;
fwrite(obj.Blue,char(hex2dec('3D')))
obj.StartTime = datetime('now');

% waiting for get data from bluetooth obj
% waitfor(obj.Blue.Status,'closed')
% obj = obj.Blue.UserData;
% disp('DONE')

function obj = instrcallback(Blue,~)
% getting obj
obj = Blue.UserData;

% reading data from COM port
rawData = [obj.DisplacedData,fread(Blue,obj.BufferSize - numel(obj.DisplacedData))];

% recording time
obj.LastSampleTime = datetime('now');

% finding new pkt starts indexes
pktStartIndexes = strfind(rawData',obj.PacketHead)';

% getting pkt lengths
pktLength = [diff(pktStartIndexes); numel(rawData) - pktStartIndexes(end,1)+1];

% filtering only full packets
pktStartIndexes = pktStartIndexes(pktLength == obj.PacketSize);

% computing PacketsRetrived
obj.PacketsRetrived = numel(pktStartIndexes);

% cutting away displaced data
if pktLength(end,1) ~= obj.PacketSize
    obj.DisplacedData = rawData(numel(rawData) - ...
        (obj.PacketSize-pktLength(end,1)):end,1);
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
        cVar = obj.DataNames{1,iData};
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

obj.Counter = obj.Counter + 6;

if obj.Counter >= obj.SamplesRequired
    fwrite(Blue,char(hex2dec('3A')))
    pause(0.5)
    flushinput(Blue)
    fclose(Blue);
end

% resetting UserData
Blue.UserData = obj;
end