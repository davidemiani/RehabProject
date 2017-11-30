clc
close all
clear all

csd=fileparts(mfilename('fullpath'));
repopath=fileparts(csd);
addpath(fullfile(repopath,'davefuncs')) % aggiungo al path cartella davefuncs
addpath(fullfile(repopath,'Frafuncs'))% aggiungo al path cartella frafuncs
rmpath(fullfile(repopath,'Acquisizioni'))
rmpath(fullfile(repopath,'Acquisizioni','Dati 2811-2017','data21')) 
addpath(fullfile(repopath,'Acquisizioni','Dati 2811-2017','data26')) %acquisizioni con classe;
rmpath(fullfile(repopath,'Acquisizioni','Dati 2811-2017','data24'))
rmpath(fullfile(repopath,'Acquisizioni','28-11-2017 umano'))% acquisizioni con classe con umano;

load('100_1S.mat')
AccX=dataHum(:,4);
AccY=dataHum(:,5);
AccZ=dataHum(:,6);
x=abs(AccZ)>abs(AccX);

[Angle] = computeHomerAngle(AccX,AccY,AccZ);