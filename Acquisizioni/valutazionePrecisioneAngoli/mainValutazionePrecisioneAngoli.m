% Script per la valutazione della precisione del calcolo degli angoli con
% inclinometro
% 22/11/2017

clear 
close all
clc
addpath(fullfile(fileparts(fileparts(pwd)), 'davefuncs')) % aggiungo al path cartella davefuncs
addpath(fullfile(fileparts(fileparts(pwd)), 'frafuncs'))
addpath(fullfile(pwd, 'Acquisiz_22112017'))

%% Piano frontale

% Carico i dati
datiFront = struct('deg0', [], 'deg45', [], 'deg90', [], 'deg135', []);
angoli = {'0', '45', '90', '135'};
nAngoli = length(angoli);
piano = 'F';
nAcqu = 5;
for j = 1:nAngoli
    for i = 1:nAcqu
        nomeFile = [angoli{1, j}, '_', num2str(i), piano];
        struttura = load(nomeFile);
        datiFront.(['deg' angoli{j}]) = [datiFront.(['deg' angoli{j}]); struttura.dataHum];
    end
end

% Calcolo gli angoli (algoritmo tutor)
angoliCalcolatiFront = struct('deg0', struct('atan', [], 'acos', []), ...
    'deg45', struct('atan', [], 'acos', []), ...
    'deg90', struct('atan', [], 'acos', []), ...
    'deg135', struct('atan', [], 'acos', []));
for j = 1:nAngoli
    campoAngolo = ['deg' angoli{j}];
    datiPerAngolo = datiFront.(campoAngolo) * 2 * 9.807 / 32768;
    [angoliCalcolatiFront.(campoAngolo).atan, ...
    angoliCalcolatiFront.(campoAngolo).acos] = ...
    computeFrontalAngle(datiPerAngolo(:,5),datiPerAngolo(:,6));
end

% Plottiamo
h = figure;
legin = {'valore ideale', 'acos', 'atan'};
for j = 1:nAngoli
    campoAngolo = ['deg' angoli{j}];
    subplot(2, 2, j)
    plot(ones(size(angoliCalcolatiFront.(campoAngolo).acos))*str2double(angoli{j}), 'LineWidth', 2) % plotto valore ideale
    hold on
    plot(angoliCalcolatiFront.(campoAngolo).acos) % plotto acos
    plot(angoliCalcolatiFront.(campoAngolo).atan) % plotto atan
    hold off
    title([angoli{j} ' gradi'])
    legend(legin)
end

% Salviamo i plot
savefig2(h, fullfile(pwd, 'grafici', 'confrontoValutazioneAngoli.fig'), 'ScreenSize', true)

% Valutiamo media, varianza e differenza
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

% Salviamo i plot
savefig2(h2, fullfile(pwd, 'grafici', 'indiciValutazioniAngoli.fig'), 'ScreenSize', true)