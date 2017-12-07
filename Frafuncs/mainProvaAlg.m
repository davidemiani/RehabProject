clc
close all
clear all

csd=fileparts(mfilename('fullpath'));
repopath=fileparts(csd);
addpath(fullfile(repopath,'davefuncs')) % aggiungo al path cartella davefuncs
addpath(fullfile(repopath,'Frafuncs'))% aggiungo al path cartella frafuncs
rmpath(fullfile(repopath,'Acquisizioni'))
rmpath(fullfile(repopath,'Acquisizioni','Dati 2811-2017','data21')) 
rmpath(fullfile(repopath,'Acquisizioni','Dati 2811-2017','data26')) %acquisizioni con classe;
rmpath(fullfile(repopath,'Acquisizioni','Dati 2811-2017','data24'))
addpath(fullfile(repopath,'Acquisizioni','2017-12-05'))% acquisizioni con classe con umano;

load('120_1E_FM94.mat')
AccX=dataHum(:,4);
AccY=dataHum(:,5);
AccZ=dataHum(:,6);


Angle = Calcola_Angoli_metodo_sagittale(AccX,AccY,AccZ)
plot(Angle)