% mainAcquisituon.m


%% INIT
%%
pulisci

% getting current script directory
csd = fileparts(mfilename('fullpath'));

% computing repository main dir
repopath = fileparts(csd);

% computing data dir
datapath = fullfile(repopath,'Acquisizioni', ...
    char(datetime('now','Format','dd-MM-yyyy')));

% assuring you have the right function paths
addpath(fullfile(repopath,'Exel_class'))
addpath(fullfile(repopath,'frafuncs'))
addpath(fullfile(repopath,'davefuncs'))

% checking if the datapath is existent. If it doesn't, touch will create it
touch(datapath);

% setting ExelName and Fig
ExelName = 'EXLs3_0067';
ExelFigure = testFigure1();

% creating the object
obj = Exel(ExelName,'ExelFigure',ExelFigure,'SamplingFcn',@testFunc);
set(obj,'AutoStop',10)

% starting it, if error, exiting
try
    start(obj)
catch ME
    disconnect(obj)
    rethrow(ME)
end


%% SAVING DATA
%%
% waiting for the acquisition stop
waitfor(obj,'AcquisitionStatus','off')

% picking data to save
dataHum = [repmat(32,height(obj.ExelData),1), ...
    obj.ExelData.PacketType, ...
    obj.ExelData.ProgrNum, ...
    obj.ExelData.AccX, ...
    obj.ExelData.AccY, ...
    obj.ExelData.AccZ, ...
    floor(255*rand(height(obj.ExelData),1))]; 

% jumping to data directory
cd(datapath)

% asking the user for saving
uisave('dataHum','test_name')

% coming back to the current script directory
cd(csd)

