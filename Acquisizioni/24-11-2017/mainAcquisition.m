% mainAcquisition


%% PATHS INDEXING
%%
csd = fileparts(mfilename('fullpath')); % current script dir
dataPath = fullfile(csd,'data');

repoPath = fileparts(fileparts(csd));
addpath(fullfile(repoPath,'davefuncs'))
addpath(fullfile(repoPath,'Exel_class'))
addpath(fullfile(repoPath,'frafuncs'))

clc
close all
timerdeleteall
clearExcept csd dataPath ExelObj


%% INIT
%%
<<<<<<< HEAD
ExelName = 'EXLs3_0159'; % inserire qui nome del sensore che si sta usando
=======
ExelName = 'EXLs3_0067'; % inserire qui nome del sensore che si sta usando
<<<<<<< HEAD
ExelFigure = InitFigure();
%Segment = 'Homer'; % o Thorax
%TestingTime = 120; % inserire qui il TestingTime, in secondi
=======
>>>>>>> d33eb242fa27acabced73707ec22527ce1a5f840
Segment = 'Homer'; % o Thorax
TestingTime = 120; % inserire qui il TestingTime, in secondi
UserData = InitFigure();
>>>>>>> fba4b1f5645ea855036dfd6cda686483015fd084


%% ACQUISITION
%%
% if Exel Object already created, clean up the old cleanable fields with
% the internal reference method. In this way I am not deleting every time
% all the object, but only a few fields, so the initialization of the
% bluetooth connection is sensibly faster.
if ~exist('ExelObj','var')
    % in this case, we have to recreate the object
    % slow procedure, but necessary
    ExelObj = Exel(ExelName);
    %set(ExelObj,'ExelFigure',ExelFigure)
end

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


%% ENDING
%%
warning('on','MATLAB:structOnObject')
clearExcept ExelObj

