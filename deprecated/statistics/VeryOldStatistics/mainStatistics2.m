% mainStatistics


%% INIT
%%
csd = fileparts(mfilename('fullpath')); % current script directory
acqpath = fileparts(csd); % acquisition path
repopath = fileparts(acqpath); % repository path

% adding key paths
addpath(fullfile(repopath,'frafuncs'))
addpath(fullfile(repopath,'davefuncs'))
addpath(fullfile(repopath,'Exel_class'))

% cleaning up, ready for the next steps
clc, close all, clearExcept csd acqpath

% preallocating data structure
angles = {'20';'30';'40';'50';'60';'70';'90';'120'}; nAngles = numel(angles);
subjects = {'CM94';'FM94';'FP94';'GL94';'MC94';'DM94'}; nSubjects = numel(subjects);
exelnames = [repmat({'EXLs3_0070'},4,1);repmat({'EXLs3_0067'},2,1)];

rotations = {'E'; 'I'; 'N'}; nRotations = numel(rotations);
for k1 = 1:nSubjects
    for k2 = 1:nAngles
        for k3 = 1:nRotations
            data.(subjects{k1,1}).(['deg',angles{k2,1}]).(rotations{k3}) = ...
                struct('gold',[],'comp1',[],'comp2',[]);
        end
    end
end


%% LOADING DATA
%%
% setting directories to analize
directories = {'2017-12-05'}; % aggiungine altre qui, in colonna

% getting files and paths
files = {};
paths = {};
for i = 1:numel(directories)
    % ottengo tutti i file nella cartella i-esima con files2cell
    [cFiles,cPaths] = files2cell(fullfile(acqpath, ...
        directories{i,1}),'.mat');
    
    % concateno
    files = cat(1,files,cFiles);
    paths = cat(1,paths,cPaths);
end

% loading, computing angles and adding to the structure
for i = 1:numel(files)
    nameSplitted = strsplit(files{i,1},'_'); % splitto le stringhe divise da trattini bassi
    cAngStr = ['deg',nameSplitted{1,1}]; % trovo l'angolo
    cAngNum = str2double(nameSplitted{1,1}); % converto l'angolo in double
    cRot = nameSplitted{1,2}(2); % trovo la rotazione
    cSbj = nameSplitted{1,3}(1:end-4); % trovo il soggetto
    load(paths{i,1}) % carico il dato
    if isempty(dataHum) % se vuoto ciaone
        angles1 = [];
        angles2 = [];
        angles3 = [];
    else % altrimenti calcolo gli angoli
        % creo un oggetto fittizio
        if isnumeric(dataHum)
            obj.ExelData.AccX = dataHum(:,4);
            obj.ExelData.AccY = dataHum(:,5);
            obj.ExelData.AccZ = dataHum(:,6);
            obj.ExelName = exelnames{i,1};
        end
        % calcolo gli angoli
        angles1 = computeHomerAngle1(dataHum(:,4:6));
        angles2 = computeHomerAngle2(dataHum(:,4:6));
        %angles3 = computeHomerAngle3(dataHum(:,4:6))'; % trasposizione: computeHomerAngle3 esce una riga e non una colonna
    end
    
    % popolo la struttura
    data.(cSbj).(cAngStr).(cRot).gold = ...
        repmat(cAngNum,size(angles1)); 
    
    data.(cSbj).(cAngStr).(cRot).comp1 = ...
        angles1;
    
    data.(cSbj).(cAngStr).(cRot).comp2 = ...
        angles2;
    
    %data.(cSbj).(cAngStr).(cRot).comp3 = ...
        angles3;
end


%% PLOTTING ANGLES
%%
for k1 = 1:nSubjects
    % getting current subject
    cSbj = subjects{k1,1};
    
    % creating current figure
    h = figure('Name',cSbj,'Position',get(0,'ScreenSize'));
    
    % cycling for subplots
    for k2 = 1:nAngles
        % getting current angle
        cAng = ['deg',angles{k2,1}];
        
        % getting current data
        cComp1 = [];
        cComp2 = [];
        cComp3 = [];
        cGold = [];
        for r = 1:nRotations
            cComp1 = [cComp1; data.(cSbj).(cAng).(rotations{r}).comp1];
            cComp2 = [cComp2; data.(cSbj).(cAng).(rotations{r}).comp2];
            cComp3 = [cComp3; data.(cSbj).(cAng).(rotations{r}).comp3];
            cGold = [cGold; data.(cSbj).(cAng).(rotations{r}).gold];
        end

        % computing mean squared error
        MSE1 = mean((cGold-cComp1).^2);
        MSE2 = mean((cGold-cComp2).^2);
        MSE3 = mean((cGold-cComp3).^2);
        
        % subplotting
        subplot(2,4,k2), hold on, grid minor
        plot(cComp1,'LineWidth',1,'Color',[0,0.8,0.8]);
        plot(cComp2,'LineWidth',1,'Color',[0,0.8,0]);
        plot(cComp3,'LineWidth',1,'Color',[0.8,0.8,0])
        plot(cGold, 'LineWidth',3,'Color',[0,0,0.8]);
        title([cAng, '; ', 'Rotazione: Extra, Intra, Normale'])
        xlabel('Samples (adim)')
        ylabel('Degrees (\circ)')
        legend(sprintf('Metodo Trigonometrico 1 (MSE = %s)',num2str(MSE1)), ...
            sprintf('Metodo Proiezione (MSE = %s)',num2str(MSE2)), ...
            sprintf('Metodo Trigonometrico 2 (MSE = %s)',num2str(MSE2)), ...
            'Location','southoutside')
    end
    
    % saving results
    savefig2(h,fullfile(csd,'figSensor0070Abs_addedTrig3',[cSbj,'.fig']),'ScreenSize',false)
    savefig2(h,fullfile(csd,'jpgSensor0070Abs_addedTrig3',[cSbj,'.jpg']),'ScreenSize', true)
end

%% COMPUTING STATISTICS
%%

% metodi di valutazione
metodi = {'TrigEval1', 'SphEval', 'TrigEval2'};
% definisco gli angoli in double
anglesd = NaN(nAngles, 1);
% definisco la struttura errore
for a = 1:nAngles
    % definisco l'angolo ideale in double
    anglesd(a) = str2double(angles{a});
    goldd = anglesd(a);
    for r = 1:nRotations
        for s = 1:nSubjects
            % prendo gli angoli valutati per ogni angolo, per ogni
            % rotazione, per ogni soggetto (angoli correnti)
            currentAngles = data.(subjects{s, 1}).(['deg', angles{a, 1}]).(rotations{r});
            
            % divido le due valutazioni considerando la rotazione corrente
            currentTrigEval1 = currentAngles.comp1;
            currentSphericalEval = currentAngles.comp2;
            currentTrigEval2 = currentAngles.comp3;
            
            % valutare l'errore medio sul soggetto per entrambe le valutazioni
            errorCurrTrigEval1 = abs(mean(currentTrigEval1) - goldd);
            errorCurrSphEval = abs(mean(currentSphericalEval) - goldd);
            errorCurrTrigEval2 = abs(mean(currentTrigEval2) - goldd);
            
            % alloco l'errore nella struttura
            errore.(rotations{r,1}).(['deg', angles{a,1}]).(metodi{1}).(subjects{s,1}) = ...
                errorCurrTrigEval1;
            errore.(rotations{r,1}).(['deg', angles{a,1}]).(metodi{2}).(subjects{s,1}) = ...
                errorCurrSphEval;
            errore.(rotations{r,1}).(['deg', angles{a,1}]).(metodi{3}).(subjects{s,1}) = ...
                errorCurrTrigEval2;
        end
        % valuto l'errore medio totale su tutti i soggetti
        errore.(rotations{r,1}).(['deg', angles{a,1}]).(metodi{1}).('totale') = ...
            mean(cell2mat(struct2cell(...
            errore.(rotations{r,1}).(['deg', angles{a,1}]).(metodi{1})...
            )));
        errore.(rotations{r,1}).(['deg', angles{a,1}]).(metodi{2}).('totale') = ...
            mean(cell2mat(struct2cell(...
            errore.(rotations{r,1}).(['deg', angles{a,1}]).(metodi{2})...
            )));
        errore.(rotations{r,1}).(['deg', angles{a,1}]).(metodi{3}).('totale') = ...
            mean(cell2mat(struct2cell(...
            errore.(rotations{r,1}).(['deg', angles{a,1}]).(metodi{3})...
            )));
    end
end

%% PLOTTING STATISTICS
%%
nSubplots = nRotations; % definisco il numero di subplot

% grafico l'errore totale
h = figure; % apro la figura
set(h, 'Name', 'ErrorPlot');
for r = 1:nRotations
    subplot(1,nSubplots,r)
    
    % valuto il vettore dell'errore totale su entrambi i metodi
    erroreTotaleTrigEval1 = NaN(nAngles, 1);
    erroreTotaleSphEval = NaN(nAngles, 1);
    erroreTotaleTrigEval2 = NaN(nAngles, 1);
    for a = 1:nAngles
        erroreTotaleTrigEval1(a) = errore.(rotations{r}).(['deg' angles{a}]).(metodi{1}).totale;
        erroreTotaleSphEval(a) = errore.(rotations{r}).(['deg' angles{a}]).(metodi{2}).totale;
        erroreTotaleTrigEval2(a) = errore.(rotations{r}).(['deg' angles{a}]).(metodi{3}).totale;
    end
    
    % plotto
    plot(anglesd, erroreTotaleTrigEval1, 'o--', ... 
        anglesd, erroreTotaleSphEval, 'o-', ...
        anglesd, erroreTotaleTrigEval2, 'ko-.', ...
        anglesd,zeros(size(anglesd)))
    grid minor
    ylabel('gradi (�)')
    xlabel('gradi (�)')
    legend('Metodo Trigonometrico 1', 'Metodo Proiezione', 'Metodo Trigonometrico 2')
    title(['Errore totale per ogni angolo per la rotazione ', rotations{r}])
end
savefig2(h,fullfile(csd,'jpgSensor0070Abs_addedTrig3',[get(gcf, 'Name'),'.jpg']),'ScreenSize', false)
savefig2(h,fullfile(csd,'figSensor0070Abs_addedTrig3',[get(gcf, 'Name'),'.fig']),'ScreenSize', false)