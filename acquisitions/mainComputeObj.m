clc,clear all,close all

%% INIT
csd = fileparts(mfilename('fullpath')); % current script directory
repopath = fileparts(csd); 

% adding key paths
addpath(fullfile(repopath,'utilities','funcs'))
addpath(fullfile(repopath,'deprecated','frafuncs'))
addpath(fullfile(csd,('davetest')))

%% LOADING files
DataDir = '2017-12-05';
[files,paths] = files2cell(fullfile(csd,DataDir),'.mat');

%% compute
nFiles = length(files);

Anglesd = [20:10:70 90 120];
for i = 1:length(Anglesd)
    anglesc{i,1} = char(strcat('deg',num2str(Anglesd(i))));
end
dataTable = table('RowNames',anglesc);
anglesStruct = struct(...
    'I',struct('Trigonometrico',dataTable,'Proiezione',dataTable),...
    'N',struct('Trigonometrico',dataTable,'Proiezione',dataTable),...
    'E',struct('Trigonometrico',dataTable,'Proiezione',dataTable));

for i = 1:nFiles
    load(char(paths(i)));
    
    cGold = obj.UserData.GoldStandard;
    cTest = obj.UserData.TestName;
    cSbj = obj.Subject;
    
    anglesTrig = computeHomerAngle1(obj.ExelData{:,3:5}); %trigonometrico
    anglesPro = computeHomerAngle2(obj.ExelData{:,3:5}); %proiezione
    
    anglesStruct.(cTest).Trigonometrico.(cSbj){['deg',cGold]} = mean(anglesTrig);
    anglesStruct.(cTest).Proiezione.(cSbj){['deg',cGold]} = mean(anglesPro);
end

save('Angles_2017_12_05','anglesStruct');

