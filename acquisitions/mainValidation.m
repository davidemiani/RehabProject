% mainValidation
clear
close all
clc

%% INIT VALIDATION
cartelleAcquisizioni = {'2018-01-31', '2018-02-01'};
acquisitions = {'CM94_01', 'CM94_02', 'FP94_01', 'FP94_02', 'GL94_01', 'GL94_02'};
funzioneEval = @projection;

coreValidation