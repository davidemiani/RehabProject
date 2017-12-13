% mainAcquisition


%% PATHS INDEXING
%%
clc, clearvars, close all
csd = fileparts(mfilename('fullpath')); % current script dir
dataPath = fullfile(csd,'data');

repoPath = fileparts(fileparts(csd));
addpath(fullfile(repoPath,'davefuncs'))
addpath(fullfile(repoPath,'Exel_class'))
addpath(fullfile(repoPath,'frafuncs'))


%% INIT
%%
ExelName = 'EXLs3_0067'; % inserire qui nome del sensore che si sta usando


%% ACQUISITION
%%
ExelObj = Exel(ExelName,'AutoStop',10);
try
    start(ExelObj)
catch ME
    disconnect(ExelObj)
    rethrow(ME)
end


%% SAVING DATA
%%
% waiting for the acquisition stop
waitfor(ExelObj,'AcquisitionStatus','off')

% picking data to save
dataHum = [repmat(32,height(ExelObj.ExelData),1), ...
    ExelObj.ExelData.PacketType, ...
    ExelObj.ExelData.ProgrNum, ...
    ExelObj.ExelData.AccX, ...
    ExelObj.ExelData.AccY, ...
    ExelObj.ExelData.AccZ, ...
    floor(255*rand(height(ExelObj.ExelData),1))]; 

% jumping to data directory
cd(dataPath)

% asking the user for saving
uisave('dataHum','test_name')

% coming back to the current script directory
cd(csd)

