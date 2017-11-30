clc, close all

csd = fileparts(mfilename('fullpath')); %fornisce il percorso del main
repopath = fileparts(csd);  %fornisce la cartella a cui appartiene il main

addpath(fullfile(repopath,'frafuncs'))
addpath(fullfile(repopath,'davefuncs'))
addpath(fullfile(repopath,'Exel_class'))

clearExcept csd

directories = {'30-11-2017'}; % aggiungine altre qui, in colonna
files = {};
paths = {};
for i = 1:numel(directories)
    [cFiles,cPaths] = files2cell(fullfile(csd,directories{i,1}),'.mat');
    
    files = cat(1,files,cFiles);
    paths = cat(1,paths,cPaths);
    
end

angle = [];
nTest = [];
plane = {};
sbj = {};
for i = 1:numel(files)
    nameSplitted = strsplit(files{i,1},'_');
    angle = cat(1,angle,str2double(nameSplitted{1,1}));
    nTest = cat(1,nTest,str2double(nameSplitted{1,2}(1)));
    plane = cat(1,plane,nameSplitted{1,2}(2:end));
    sbj = cat(1,sbj,nameSplitted{1,3});
end

% se vuoi puoi gestire tutto con una table
t = table(files,angle,nTest,plane,sbj,paths);

% puoi ordinare il tutto secondo ordine alfabetico del soggetto, angoli, o
% altro
t = sortrows(t,'angle');
disp(t)

% ora in questa table hai tutto quello che ti serve, anche i percorsi in
% paths e puoi anche non rigenerarli mai più, ti basta ciclare e caricare
% con le load








