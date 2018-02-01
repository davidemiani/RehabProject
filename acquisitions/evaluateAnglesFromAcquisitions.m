% Evaluation of joint angle from acquisition
clear
close all
clc

%% INIT
cartelleAcquisizioni = {'PosizioniPossibiliGiorgio'};
funzioneEval = @sagittal2;

%% GET ACQUISITIONS PATHS
paths = [];
for i = 1:numel(cartelleAcquisizioni)
    [~,tempPaths] = files2cell(fullfile(csd,cartelleAcquisizioni{i}),'.mat');
    paths = [paths; tempPaths];
end

%% EVALUATE ANGLES
homerAngles = cell(size(paths));
thoraxAngles = cell(size(paths));
jointAngles = cell(size(paths));
meanJointAngles = NaN(size(paths));
sdJointAngles = NaN(size(paths));
for i = 1:numel(paths)
    load(paths{i, 1}); % load acquisition
    tempHomerAngles = funzioneEval(obj(1, 1)); % evaluate homer angles
    tempThoraxAngles = funzioneEval(obj(2, 1)); % evaluate thorax angles
    minLength = min([length(tempHomerAngles), length(tempThoraxAngles)]); % get min length (in case of data loss)
    
    jointAngles{i} = tempHomerAngles(1:minLength) + tempThoraxAngles(1:minLength); % evaluate joint angle
%     if abs(mean(tempHomerAngles)) < 10
%         jointAngles{i} = abs(jointAngles{i});
%     end
    homerAngles{i} = tempHomerAngles; % save in a variable
    thoraxAngles{i} = tempThoraxAngles; % save in a variable
    meanJointAngles(i) = mean(jointAngles{i}); % save mean joint angle
    sdJointAngles(i) = std(jointAngles{i}); % save sd joint angle
end


%% PLOTTING DATA
realAngles = [0; 0; 0; 0; 0; 0; 45; 90; 135; 180; 30; 45; 90; 30; 60; 45; 90; 135; 180; 45; 90; 120; 45; 90; 30; 75];
meanError = abs(meanJointAngles - realAngles);
rowsSubplot = 4;
colsSubplot = 7;

figure
for i = 1:numel(paths)
    subplot(rowsSubplot, colsSubplot, i)
    plot(jointAngles{i})
    hold on
    plot(1:numel(jointAngles{i}), ones(1, numel(jointAngles{i}))*realAngles(i))
    hold off
    ylim([-180 180])
    title(['RealAng: ' num2str(realAngles(i)) newline ...
        'MeanAbsError: ' num2str(meanError(i)) newline ...
        ' SD: ' num2str(sdJointAngles(i))])
end
legend('measured', 'real')

%% PLOTTO IMMAGINI
for i = 1:numel(cartelleAcquisizioni)
    % load images
    [~,imPaths] = files2cell(fullfile(csd,cartelleAcquisizioni{i}, 'ImmaginiPosizioniValutate'),'.png');
    % ERRATO
end

figure
for i = 1:numel(imPaths)
    % load image
    [im, map] = imread(imPaths{i}, 'png');
    
    % subplot
    subplot(rowsSubplot, colsSubplot, i)
    imshow(im)
    colormap(map)
    title(['Immagine ' num2str(i)])
end