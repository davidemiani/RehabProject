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
angles = {'10';'40';'70';'90';'110';'130'}; nAngles = numel(angles);
subjects = {'CM94';'FM94'}; nSubjects = numel(subjects);
for k1 = 1:nSubjects
    for k2 = 1:nAngles
        data.(subjects{k1,1}).(['deg',angles{k2,1}]) = ...
            struct('gold',[],'comp1',[],'comp2',[]);
    end
end


%% LOADING DATA
%%
% setting directories to analize
directories = {'30-11-2017'}; % aggiungine altre qui, in colonna

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
    nameSplitted = strsplit(files{i,1},'_');
    cAngStr = ['deg',nameSplitted{1,1}];
    cAngNum = str2double(nameSplitted{1,1});
    cSbj = nameSplitted{1,3}(1:end-4);
    load(paths{i,1})
    if isempty(dataHum)
        angles1 = [];
        angles2 = [];
    else
        angles1 = computeHomerAngle1(dataHum(:,4:6));
        angles2 = computeHomerAngle2(dataHum(:,4:6));
    end
    data.(cSbj).(cAngStr).gold = ...
        cat(1,data.(cSbj).(cAngStr).gold,repmat(cAngNum,size(angles1)));
    
    data.(cSbj).(cAngStr).comp1 = ...
        cat(1,data.(cSbj).(cAngStr).comp1,angles1);
    
    data.(cSbj).(cAngStr).comp2 = ...
        cat(1,data.(cSbj).(cAngStr).comp2,angles2);
end


%% PLOTTING
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
        cComp1 = data.(cSbj).(cAng).comp1;
        cComp2 = data.(cSbj).(cAng).comp2;
        cGold = data.(cSbj).(cAng).gold;
        
        % computing mean squared error
        MSE1 = mean((cGold-cComp1).^2);
        MSE2 = mean((cGold-cComp2).^2);
        
        % subplotting
        subplot(2,3,k2), hold on, grid minor
        plot(cComp1,'LineWidth',1,'Color',[0,0.8,0.8]);
        plot(cComp2,'LineWidth',1,'Color',[0,0.8,0]);
        plot(cGold, 'LineWidth',3,'Color',[0,0,0.8]);
        title(cAng)
        xlabel('Samples (adim)')
        ylabel('Degrees (\circ)')
        legend(sprintf('Metodo Sagittale (MSE = %s)',num2str(MSE1)), ...
            sprintf('Metodo Proiezione (MSE = %s)',num2str(MSE2)), ...
            'Location','southoutside')
    end
    
    % saving results
    savefig2(h,fullfile(csd,'fig',[cSbj,'.fig']),'ScreenSize',false)
    savefig2(h,fullfile(csd,'jpg',[cSbj,'.jpg']),'ScreenSize', true)
end