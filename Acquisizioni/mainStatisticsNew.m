% mainStatistics


%% INIT
%%
csd = fileparts(mfilename('fullpath')); % fornisce la directory del main
repopath = fileparts(csd); % fornisce il percorso della repo

% aggiungo al path le cartelle chiave
addpath(fullfile(repopath,'frafuncs'))
addpath(fullfile(repopath,'davefuncs'))
addpath(fullfile(repopath,'Exel_class'))

% prealloco la struttura data
angoli = {'10','40','70','90','110','130'};
nAngoli = numel(angoli);
for i =1:nAngoli
    data.(['deg' angoli{1,i}]) = struct('F',[],'M',[],'S',[]);
end


%% CARICAMENTO DATI
%%
% dichiaro le directory da analizzare
directories = {'30-11-2017'}; % aggiungine altre qui, in colonna

% prendo nomi dei file e relativi percorsi
files = {};
paths = {};
for i = 1:numel(directories)
    % ottengo tutti i file nella cartella i-esima con files2cell
    [cFiles,cPaths] = files2cell(fullfile(csd,directories{i,1}),'.mat');
    
    % concateno
    files = cat(1,files,cFiles);
    paths = cat(1,paths,cPaths);
    
end

% creo le altre colonne 
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

t = table(files,angle,nTest,plane,sbj,paths);

for i = 1:size(t,1)
    %cd(fileparts(paths{i}));
    %load(files{i});
    % MATLAB può fare la load anche di percorsi interi
    load(paths{i})
    campoAngolo = ['deg' num2str(angle(i))];
    campoPiano = char(plane(i));
    sub = char(sbj(i));
    campoAcq = [sub(1:4) '_' num2str(nTest(i))];

    data.(campoAngolo).(campoPiano).(campoAcq) = dataHum;
    
end
   
cd(csd)  
%% CALCOLO ANGOLI
%%
angoliCalcolati = struttura;
nAngoli = length(angoli);
for i = 1:size(t,1)
    campoAngolo = ['deg' num2str(t.angle(i))];
    campoPiano = char(t.plane(i));
    sub = char(t.sbj(i));
    campoAcq = [sub(1:4) '_' num2str(t.nTest(i))];
    
    if ~isempty(data.(campoAngolo).(campoPiano).(campoAcq))
        AccX = data.(campoAngolo).(campoPiano).(campoAcq)(:,4);
        AccY = data.(campoAngolo).(campoPiano).(campoAcq)(:,5);
        AccZ = data.(campoAngolo).(campoPiano).(campoAcq)(:,6);
        
        angoliCalcolati.(campoAngolo).(campoPiano).(campoAcq) = ...
            computeHomerAngle(AccX,AccY,AccZ);
    else
        angoliCalcolati.(campoAngolo).(campoPiano).(campoAcq) = [];
    end
end
clearExcept csd t strutturaDati angoli struttura angoliCalcolati


%% !!!!!!!!!!!!!!
%% -----------------DA QUI IN POI � DA MODIFICARE--------------------
%% !!!!!!!!!!!!!!!!
%%
% Plottiamo i risultati di acos e atan rispetto al valore ideale

h = figure;
legin = {'valore ideale', 'acos', 'atan'};
for j = 1:nAngoli
    campoAngolo = ['deg' angoli{j}];
    subplot(3, 7, j)
    plot(ones(size(angoliCalcolatiFront.(campoAngolo).acos))*str2double(angoli{j}), 'LineWidth', 2) % plotto valore ideale
    hold on
    plot(angoliCalcolatiFront.(campoAngolo).acos) % plotto acos
    plot(angoliCalcolatiFront.(campoAngolo).atan) % plotto atan
    hold off
    title([angoli{j} ' gradi'])
end
legend(legin)
set(h, 'Name', 'Piano Frontale')

% Salviamo i plot
savefig2(h, fullfile(pwd, 'grafici', 'confrontoValutazioneAngoliFront.fig'), 'ScreenSize', false)

%% Valutiamo media, varianza e differenza
mediaValutazioni = struct('atan', zeros(nAngoli, 1), 'acos', zeros(nAngoli, 1));
stdvarValutazioni = struct('atan', zeros(nAngoli, 1), 'acos', zeros(nAngoli, 1));
diffValutazioni = struct('atan', zeros(nAngoli, 1), 'acos', zeros(nAngoli, 1));
for j = 1:nAngoli
    campoAngolo = ['deg' angoli{j}];
    mediaValutazioni.atan(j) = mean(angoliCalcolatiFront.(campoAngolo).atan); % salvo media per di atan per ogni angolo
    mediaValutazioni.acos(j) = mean(angoliCalcolatiFront.(campoAngolo).acos); % salvo media per di acos per ogni angolo
    stdvarValutazioni.atan(j) = std(angoliCalcolatiFront.(campoAngolo).atan); % salvo std per di atan per ogni angolo
    stdvarValutazioni.acos(j) = std(angoliCalcolatiFront.(campoAngolo).acos); % salvo std per di acos per ogni angolo
    diffValutazioni.atan(j) = mean(angoliCalcolatiFront.(campoAngolo).atan) - str2double(angoli{j}); % salvo std per di atan per ogni angolo
    diffValutazioni.acos(j) = mean(angoliCalcolatiFront.(campoAngolo).acos) - str2double(angoli{j}); % salvo std per di acos per ogni angolo
end
valutazioniIndici.mediaValutazioni = mediaValutazioni;
valutazioniIndici.stdvarValutazioni = stdvarValutazioni;
valutazioniIndici.diffValutazioni = diffValutazioni;

angolid = str2double(angoli);
legin = {'acos', 'atan'};
h2 = figure;
indice = {'media', 'deviazione standard', 'differenza media dal valore vero'};
indiceBreve = {'media', 'stdvar', 'diff'};
for i = 1:3
    subplot(1, 3, i)
    plot(angolid, valutazioniIndici.([indiceBreve{i} 'Valutazioni']).acos, '-o', ...
        angolid, valutazioniIndici.([indiceBreve{i} 'Valutazioni']).atan, '-o')
    title(indice{i})
    xlabel('angoli')
    grid minor
    legend(legin)
end
set(h2, 'Name', 'Piano Frontale')

% Salviamo i plot
savefig2(h2, fullfile(pwd, 'grafici', 'indiciValutazioniAngoliFront.fig'), 'ScreenSize', false)

