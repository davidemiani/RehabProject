% Evaluation of joint angle from acquisition
clear
close all
clc

%% INIT
date = {'2018-01-29'}; % set date(s) of acquisition
%subjects = {'NS00'}; % set subject(s) code
%acqNumber = {'01', '02', '03', '04', '05', '06', '07', '08', '09', '10', ...
%    '11', '12', '13', '14', '15', '16', '17', '18', '19'};

%% EVALUATE ANGLES
paths = [];
for i = 1:numel(date)
    [~,tempPaths] = files2cell(fullfile(csd,date{1}),'.mat');
    paths = [paths; tempPaths];
end

% DA FINIRE