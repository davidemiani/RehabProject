% Script per la valutazione della precisione del calcolo degli angoli con
% inclinometro
% 22/11/2017

clear 
close all
clc
addpath(fullfile(fileparts(fileparts(pwd)),'davefuncs')) % aggiungo al path cartella davefuncs
addpath(fullfile(fileparts(fileparts(pwd)),'frafuncs')) % aggiungo al path cartella frafuncs
addpath(fullfile(pwd,'data')) % aggiungo al path data
addpath(fullfile(fileparts(pwd),'24-11-2017', 'data')) % aggiungo le acquisizioni del 24/11

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
    [angoliCalcolatiFront.(campoAngolo).acos, ...
    angoliCalcolatiFront.(campoAngolo).atan] = ...
    computeFrontalAngle(datiPerAngolo(:,5),datiPerAngolo(:,6));
end

% Plottiamo i risultati di acos e atan rispetto al valore ideale
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
set(h, 'Name', 'Piano Frontale')

% Salviamo i plot
savefig2(h, fullfile(pwd, 'grafici', 'confrontoValutazioneAngoliFront.fig'), 'ScreenSize', false)

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
set(h2, 'Name', 'Piano Frontale')

% Salviamo i plot
savefig2(h2, fullfile(pwd, 'grafici', 'indiciValutazioniAngoliFront.fig'), 'ScreenSize', false)

%% Piano sagittale

% Carico i dati
datiSag = struct('deg0', [], 'deg45', [], 'deg90', [], 'deg135', []);
angoli = {'0', '45', '90', '135'};
nAngoli = length(angoli);
piano = 'S';
nAcqu = 5;
struttura = load('0_1S');
% carico 0 separatamente (causa dati salvati in maniera differente)
datiSag.deg0 = struttura.dataHum;
struttura = load('0_2S');
datiSag.deg0 = [datiSag.deg0; struttura.dataHum];
struttura = load('0_345S');
datiSag.deg0 = [datiSag.deg0; struttura.dataHum];
% carico angoli da 45 a 135
for j = 2:nAngoli 
    nomeFile = [angoli{1, j}, '_12345', piano];
    struttura = load(nomeFile);
    datiSag.(['deg' angoli{j}]) = struttura.dataHum;
end

% Calcolo gli angoli (algoritmo tutor)
angoliCalcolatiSag = struct('deg0', struct('atan', [], 'acos', []), ...
    'deg45', struct('atan', [], 'acos', []), ...
    'deg90', struct('atan', [], 'acos', []), ...
    'deg135', struct('atan', [], 'acos', []));
for j = 1:nAngoli
    campoAngolo = ['deg' angoli{j}];
    if j == nAngoli
        datiPerAngolo = datiSag.(campoAngolo); % a 135 i dati sono già a normalizzati a g
    else 
        datiPerAngolo = datiSag.(campoAngolo) * 2 * 9.807 / 32768;
    end
    [angoliCalcolatiSag.(campoAngolo).acos, ...
    angoliCalcolatiSag.(campoAngolo).atan] = ...
    computeSagittalAngle(datiPerAngolo(:,4),datiPerAngolo(:,5));
end

% Plottiamo
h = figure;
legin = {'valore ideale', 'acos', 'atan'};
for j = 1:nAngoli
    campoAngolo = ['deg' angoli{j}];
    subplot(2, 2, j)
    plot(ones(size(angoliCalcolatiSag.(campoAngolo).acos))*str2double(angoli{j}), ...
        'LineWidth', 2) % plotto valore ideale
    hold on
    plot(angoliCalcolatiSag.(campoAngolo).acos) % plotto acos
    plot(angoliCalcolatiSag.(campoAngolo).atan) % plotto atan
    hold off
    title([angoli{j} ' gradi'])
    legend(legin)
end
set(h, 'Name', 'Piano Sagittale')

% Salviamo i plot
savefig2(h, fullfile(pwd, 'grafici', 'confrontoValutazioneAngoliSag.fig'), 'ScreenSize', false)

% Valutiamo media, varianza e differenza
mediaValutazioni = struct('atan', zeros(nAngoli, 1), 'acos', zeros(nAngoli, 1));
stdvarValutazioni = struct('atan', zeros(nAngoli, 1), 'acos', zeros(nAngoli, 1));
diffValutazioni = struct('atan', zeros(nAngoli, 1), 'acos', zeros(nAngoli, 1));
for j = 1:nAngoli
    campoAngolo = ['deg' angoli{j}];
    mediaValutazioni.atan(j) = mean(angoliCalcolatiSag.(campoAngolo).atan); % salvo media per di atan per ogni angolo
    mediaValutazioni.acos(j) = mean(angoliCalcolatiSag.(campoAngolo).acos); % salvo media per di acos per ogni angolo
    stdvarValutazioni.atan(j) = std(angoliCalcolatiSag.(campoAngolo).atan); % salvo std per di atan per ogni angolo
    stdvarValutazioni.acos(j) = std(angoliCalcolatiSag.(campoAngolo).acos); % salvo std per di acos per ogni angolo
    diffValutazioni.atan(j) = mean(angoliCalcolatiSag.(campoAngolo).atan) - str2double(angoli{j}); % salvo std per di atan per ogni angolo
    diffValutazioni.acos(j) = mean(angoliCalcolatiSag.(campoAngolo).acos) - str2double(angoli{j}); % salvo std per di acos per ogni angolo
end
valutazioniIndici.mediaValutazioni = mediaValutazioni;
valutazioniIndici.stdvarValutazioni = stdvarValutazioni;
valutazioniIndici.diffValutazioni = diffValutazioni;

angolid = str2double(angoli); % definisco gli angoli in double
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
set(h2, 'Name', 'Piano Sagittale')

% Salviamo i plot
savefig2(h2, fullfile(pwd, 'grafici', 'indiciValutazioniAngoliSag.fig'), 'ScreenSize', false)