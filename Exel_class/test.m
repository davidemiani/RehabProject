clc, close all, clearExcept BluetoothHandle rawData ImuData

Ka = 2 * 9.807 / 32768;

HeaderByte = hex2dec('20');
PacketCode = hex2dec('81');
PacketHead = [HeaderByte,PacketCode];

PacketSize = 11; % bytes stored in one pkt
PacketsBuffered = 6; % pkt stored in
BufferSize = PacketsBuffered * PacketSize;

DataNumber = 7;
ByteGroups = {0;1;[2;3];[4;5];[6;7];[8;9];10};
ByteTypes  = {'uint8';'uint8';'uint16';'int16';'int16';'int16';'uint8'};
DataNames = {'ByteZero','PacketType','ProgrNum','AccX','AccY','AccZ','CheckSum'};
Multiplier = [1;1;1;Ka;Ka;Ka;1];

Displacement = 0;
ImuVars = {'ProgrNum','PacketType', ...
    'AccX','AccY','AccZ', ...
    'GyrX','GyrY','GyrZ', ...
    'MagX','MagY','MagZ', ...
    'Q0','Q1','Q2','Q3',  ...
    'Vbat'}; 
%ImuData = cell2table(cell(0,numel(ImuVars)),'VariableNames',ImuVars);

if ~exist('rawData','var') %|| numel(rawData) ~= BufferSize
    % creating BluetoothHandle
    if ~exist('BluetoothHandle','var')
        BluetoothHandle = Bluetooth('EXLs3',1); pause(1)
    end
    
    % setting BufferSize
    BluetoothHandle.InputBufferSize = BufferSize; pause(1)
    
    % opening communication
    fopen(BluetoothHandle);
    
    % starting data stream
    fwrite(BluetoothHandle,char(hex2dec('3D')))
    
    % flushing initial data
    flushinput(BluetoothHandle), pause(PacketsBuffered/50)
    
    % reading a banch of data
    rawData = fread(BluetoothHandle);
    
    % stopping data stream
    fwrite(BluetoothHandle,char(hex2dec('3A')))
    
    % closing comunication
    fclose(BluetoothHandle); pause(1)
end

if numel(rawData) >= BufferSize
    % finding new pkt starts indexes
    pktStartIndexes = strfind(rawData',PacketHead)';
    
    % getting pkt lengths
    PktLength = [diff(pktStartIndexes);BufferSize-pktStartIndexes(end,1)+1];
    
    % filtering only full packets
    pktStartIndexes = pktStartIndexes(PktLength == PacketSize);
    PacketsRetrived = numel(pktStartIndexes);
    
    % computing displacement for next step
    Displacement = pktStartIndexes(1) - 1;
    
    % getting current row in ImuData
    cRow = height(ImuData);
    
    % adding new rows on ImuData
    ImuData = [ImuData; ...
        array2table(zeros(PacketsRetrived,numel(ImuVars)), ...
        'VariableNames',ImuVars)];
    
    % filling new rows
    for iPkt = 1:PacketsRetrived
        for iData = 1:numel(DataNames)
            cVar = DataNames{1,iData};
            if ismember(cVar,ImuVars)
                cPktIndexes = pktStartIndexes(iPkt) + ByteGroups{iData,1};
                cData = rawData(cPktIndexes,1);
                cByteType = ByteTypes{iData,1};
                cMultiplier = Multiplier(iData,1);
                ImuData.(cVar)(cRow+iPkt,1) = cMultiplier * ...
                    double(typecast(uint8(cData),cByteType));
            end
        end
    end
end