% Evaluation of joint angle from acquisition
clear
close all
clc

%% INIT
date = {'2018-01-29'}; 

%% GET ACQUISITIONS PATHS
paths = [];
for i = 1:numel(date)
    [~,tempPaths] = files2cell(fullfile(csd,date{1}),'.mat');
    paths = [paths; tempPaths];
end

%% EVALUATE ANGLES
homerAngles = cell(size(paths));
thoraxAngles = cell(size(paths));
jointAngles = cell(size(paths));
meanJointAngles = NaN(size(paths));
sdJointAngles = NaN(size(paths));
for i = 1:numel(paths)
    load(paths{i, 1}); % load acquisition
    tempHomerAngles = projection2(obj(1, 1)); % evaluate homer angles
    tempThoraxAngles = projection2(obj(2, 1)); % evaluate thorax angles
    minLength = min([length(tempHomerAngles), length(tempThoraxAngles)]); % get min length (in case of data loss)
    
    jointAngles{i} = tempHomerAngles(1:minLength) + tempThoraxAngles(1:minLength); % evaluate joint angle
    homerAngles{i} = tempHomerAngles; % save in a variable
    thoraxAngles{i} = tempThoraxAngles; % save in a variable
    meanJointAngles(i) = mean(jointAngles{i}); % save mean joint angle
    sdJointAngles(i) = std(jointAngles{i}); % save sd joint angle
end
