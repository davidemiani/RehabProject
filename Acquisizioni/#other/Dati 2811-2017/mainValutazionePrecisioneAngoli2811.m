% Script per la valutazione della precisione del calcolo degli angoli con
% inclinometro
% 22/11/2017
% Aggiunta Filtraggio dei dati

clear 
close all
clc
addpath(fullfile(fileparts(fileparts(pwd)),'davefuncs')) % aggiungo al path cartella davefuncs
addpath(fullfile(fileparts(fileparts(pwd)),'frafuncs')) % aggiungo al path cartella frafuncs
addpath(fullfile(pwd,'data21'))
addpath(fullfile(pwd,'data24')) 
addpath(fullfile(pwd,'data26')) 
addpath(fullfile(pwd,'HumFront'))
addpath(fullfile(pwd,'HumSag'))

strutturaDati = struct('deg0', [], 'deg10', [], 'deg20', [],...
'deg30', [],'deg40', [],'deg45', [],'deg50', [],'deg60', [],...
'deg70', [],'deg80', [], 'deg90',[],'deg100', [],'deg110', [],...
'deg120', [],'deg130', [],'deg135', [],'deg140', [],'deg150', [],...
'deg160', [],'deg170', [],'deg180', []);

strutturaAngoliCalcolati = struct(...
    'deg0', struct('atan', [], 'acos', []), ...
    'deg10', struct('atan', [], 'acos', []),...
    'deg20', struct('atan', [], 'acos', []),...
    'deg30', struct('atan', [], 'acos', []),...
    'deg40', struct('atan', [], 'acos', []),...
    'deg45', struct('atan', [], 'acos', []), ...
    'deg50', struct('atan', [], 'acos', []),...
    'deg60', struct('atan', [], 'acos', []),...
    'deg70', struct('atan', [], 'acos', []),...    
    'deg80', struct('atan', [], 'acos', []),...
    'deg90', struct('atan', [], 'acos', []), ...
    'deg100', struct('atan', [], 'acos', []),...
    'deg110', struct('atan', [], 'acos', []),...
    'deg120', struct('atan', [], 'acos', []), ...
    'deg130', struct('atan', [], 'acos', []), ...
    'deg135', struct('atan', [], 'acos', []), ...
    'deg140', struct('atan', [], 'acos', []), ...
    'deg150', struct('atan', [], 'acos', []), ...
    'deg160', struct('atan', [], 'acos', []), ...
    'deg170', struct('atan', [], 'acos', []), ...
    'deg180', struct('atan', [], 'acos', []));

angoli = {'0','10', '20','30','40','45','50','60','70','80','90',...
    '100','110','120','130','135','140','150','160','170','180'};
%% PIANO FRONTALE
%%
piano = 'F';
datiFront = strutturaDati;
% Carico i dati .mat
%acquisiti con script Ferrari
angoliFerrari = {'0', '45', '90', '135'}; 
nAngoli = length(angoliFerrari);
nAcqu = 5;
for j = 1:nAngoli
    for i = 1:nAcqu
        nomeFile = [angoliFerrari{1, j}, '_', num2str(i), piano];
        struttura = load(nomeFile);
        datiFront.(['deg' angoliFerrari{j}]) = [datiFront.(['deg' angoliFerrari{j}]); struttura.dataHum];
        datiFrontFilt=datiFront.(['deg' angoliFerrari{j}]);
        datiFrontFilt(:,4:6) = filterAcc(datiFrontFilt(:,4:6)',50,'off')';
        datiFront.(['deg' angoliFerrari{j}])=datiFrontFilt;
    end
end
%acquisiti con mainAcquisition
angolimainAcq = {'100','110','120','130','140','150','160','170','180'}; 
nAngoli = length(angolimainAcq);
for j = 1:nAngoli 
    nomeFile = [angolimainAcq{1, j}, '_1', piano];
    struttura = load(nomeFile);
    datiFront.(['deg' angolimainAcq{j}]) = struttura.dataHum;
    datiFrontFilt=datiFront.(['deg' angolimainAcq{j}]);
    datiFrontFilt(:,4:6) = filterAcc(datiFrontFilt(:,4:6)',50,'off')';
    datiFront.(['deg' angolimainAcq{j}])=datiFrontFilt;

end
%acquisiti da tool di Exl
angolitxt = {'10', '20','30','40','50','60','70','80'}; 
nAngoli = length(angolitxt);
for j = 1:nAngoli
    nomeFile = [angolitxt{1, j}, '_1', piano, '.txt'];
    %carico dati .txt e converto in matrice di 16 colonne
    datitxt= table2array(readtable(nomeFile));
    %posiziono le colonne Acc nelle posizioni coerenti con quelle
    %provenienti dallo script di aquisizioni con matlab
    datitxt(:,[4 5 6]) = datitxt(:,[3 4 5]);    
    datiFront.(['deg' angolitxt{j}]) = datitxt;
    datiFrontFilt=datiFront.(['deg' angolitxt{j}]);
    datiFrontFilt(:,4:6) = filterAcc(datiFrontFilt(:,4:6)',50,'off')';
    datiFront.(['deg' angolitxt{j}])=datiFrontFilt;

end

%% calcolo angoli 
angoliCalcolatiFront = strutturaAngoliCalcolati;
nAngoli = length(angoli);
for j = 1:nAngoli
    campoAngolo = ['deg' angoli{j}];
    if ismember(angoli(j),angoliFerrari) || ismember(angoli(j),angolitxt)
        datiPerAngolo = datiFront.(campoAngolo) * 2 * 9.807 / 32768;
    else
        datiPerAngolo = datiFront.(campoAngolo);
    end
    [angoliCalcolatiFront.(campoAngolo).acos, ...
    angoliCalcolatiFront.(campoAngolo).atan] = ...
    computeFrontalAngle(datiPerAngolo(:,5),datiPerAngolo(:,6));
end

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
set(h, 'Name', 'Movimento sul Piano Frontale e osservazione Piano Frontale')

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
set(h2, 'Name', 'Movimento sul Piano Frontale e osservazione Piano Frontale')

% Salviamo i plot
savefig2(h2, fullfile(pwd, 'grafici', 'indiciValutazioniAngoliFront.fig'), 'ScreenSize', false)

%% PIANO SAGITTALE
%%
piano = 'S';
datiSag = strutturaDati;
% Carico i dati 
%acquisiti con script di Ferrari
angoliFerrari = {'0', '45', '90', '135'};
nAngoli = length(angoliFerrari);
struttura = load('0_1S');
% carico 0 separatamente (causa dati salvati in maniera differente)
datiSag.deg0 = struttura.dataHum;
struttura = load('0_2S');
datiSag.deg0 = [datiSag.deg0; struttura.dataHum];
struttura = load('0_345S');
datiSag.deg0 = [datiSag.deg0; struttura.dataHum];
% carico angoli da 45 a 135
for j = 2:nAngoli 
    nomeFile = [angoliFerrari{1, j}, '_12345', piano];
    struttura = load(nomeFile);
    datiSag.(['deg' angoliFerrari{j}]) = struttura.dataHum;
    datiSagFilt=datiSag.(['deg' angoliFerrari{j}]);
    datiSagFilt(:,4:6) = filterAcc(datiSagFilt(:,4:6)',50,'off')';
    datiSag.(['deg' angoliFerrari{j}])=datiSagFilt;
end
angoliFerrari(end)=[];
%acquisiti con mainAcquisition
angolimainAcq = {'100','110','120','130','140','150','160','170','180'};
nAngoli = length(angolimainAcq);
for j = 1:nAngoli 
    nomeFile = [angolimainAcq{1, j}, '_1', piano];
    struttura = load(nomeFile);
    datiSag.(['deg' angolimainAcq{j}]) = struttura.dataHum;
    datiSagFilt=datiSag.(['deg' angolimainAcq{j}]);
    datiSagFilt(:,4:6) = filterAcc(datiSagFilt(:,4:6)',50,'off')';
    datiSag.(['deg' angolimainAcq{j}])=datiSagFilt;
end
% acquisiti con tool Exl
angolitxt = {'10', '20','30','40','50','60','70','80'};
nAngoli = length(angolitxt);
for j = 1:nAngoli
    nomeFile = [angolitxt{1, j}, '_1', piano, '.txt'];
    %carico dati .txt e converto in matrice di 16 colonne
    datitxt= table2array(readtable(nomeFile));
    %posiziono le colonne Acc nelle posizioni coerenti con quelle
    %provenienti dallo script di aquisizioni con matlab
    datitxt(:,[4 5 6]) = datitxt(:,[3 4 5]);    
    datiSag.(['deg' angolitxt{j}]) = datitxt;
    datiSagFilt=datiSag.(['deg' angolitxt{j}]);
    datiSagFilt(:,4:6) = filterAcc(datiSagFilt(:,4:6)',50,'off')';
    datiSag.(['deg' angolitxt{j}])=datiSagFilt;
end


%% calcolo angoli 
angoliCalcolatiSag = strutturaAngoliCalcolati;
nAngoli = length(angoli);
for j = 1:nAngoli
    campoAngolo = ['deg' angoli{j}];
    if ismember(angoli(j),angoliFerrari) || ismember(angoli(j),angolitxt)
        datiPerAngolo = datiSag.(campoAngolo) * 2 * 9.807 / 32768;
    else
        datiPerAngolo = datiSag.(campoAngolo);
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
    subplot(3, 7, j)
    plot(ones(size(angoliCalcolatiSag.(campoAngolo).acos))*str2double(angoli{j}), ...
        'LineWidth', 2) % plotto valore ideale
    hold on
    plot(angoliCalcolatiSag.(campoAngolo).acos) % plotto acos
    plot(angoliCalcolatiSag.(campoAngolo).atan) % plotto atan
    hold off
    title([angoli{j} ' gradi'])
end
legend(legin)
set(h, 'Name', 'Movimento sul Piano Sagittale e osservazione Piano Sagittale')

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
set(h2, 'Name', 'Movimento sul Piano Sagittale e osservazione Piano Sagittale')

% Salviamo i plot
savefig2(h2, fullfile(pwd, 'grafici', 'indiciValutazioniAngoliSag.fig'), 'ScreenSize', false)