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
ExelName = 'EXLs3_0067'; % inserire qui nome del sensore che si sta usando
Segment = 'Homer'; % o Thorax
TestingTime = 120; % inserire qui il TestingTime, in secondi
UserData = InitFigure();


%% ACQUISITION
%%
% if Exel Object already created, clean up the old cleanable fields with
% the internal reference method. In this way I am not deleting every time
% all the object, but only a few fields, so the initialization of the
% bluetooth connection is sensibly faster.
if exist('ExelObj','var') && isa(ExelObj,'Exel') && ...
        strcmp(ExelObj.ImuName,ExelName) && ...
        strcmp(ExelObj.Segment,Segment) && ...
        ExelObj.AutoStop == TestingTime
    % if no properties is changed, cleaning up old cleanable fields
    ExelObj = ExelClean(ExelObj);
    %ExelObj.UserData = UserData;
else
    % in this case, we have to recreate the object
    % slow procedure, but necessary
    ExelObj = Exel(ExelName,'Segment',Segment,'AutoStop',TestingTime); %, ...
        %'UserData',UserData,'SamplingFcn',@SamplingFcn);
end

try
    % connecting if necessary
    if strcmp(ExelObj.ConnectionStatus,'closed')
        ExelObj = ExelConnect(ExelObj);
    end
    
    % showing figure
    %ExelObj.UserData.Figure.Visible = 'on';
    
    % starting if necessary
    if strcmp(ExelObj.ConnectionStatus,'open') && ...
            strcmp(ExelObj.AcquisitionStatus,'off')
        ExelObj = ExelStart(ExelObj);
    end
catch ME
    warnaME(ME)
    ExelObj = ExelStop(ExelObj);
end


%% SAVING DATA
%%
% waiting for the acquisition stop
waitfor(ExelObj.Timer) % untill the timer is not deleted

% picking data to save
dataHum = [repmat(32,height(ExelObj.ImuData),1), ...
    ExelObj.ImuData.PacketType, ...
    ExelObj.ImuData.ProgrNum, ...
    ExelObj.ImuData.AccX, ...
    ExelObj.ImuData.AccY, ...
    ExelObj.ImuData.AccZ, ...
    floor(255*rand(height(ExelObj.ImuData),1))]; 

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

