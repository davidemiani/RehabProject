% Evaluation of joint angle from acquisition
clear
close all
clc

%% INIT
cartelleAcquisizioni = {'PosizioniPossibiliGiorgio'};
funzioneEval = @projection2mod;

A = evalAnglesFromAcquisition(cartelleAcquisizioni, funzioneEval);


%% PLOTTING DATA
realAngles = [0; 0; 0; 0; 0; 0; 45; 90; 135; 180; 30; 45; 90; 30; 60; 45; 90; 135; 180; 45; 90; 120; 45; 90; 30; 75];
meanError = abs(A.meanJoint - realAngles);
rowsSubplot = 4;
colsSubplot = 7;

figure
for i = 1:26
    subplot(rowsSubplot, colsSubplot, i)
    plot(A.joint{i})
    hold on
    plot(1:numel(A.joint{i}), ones(1, numel(A.joint{i}))*realAngles(i))
    hold off
    ylim([-180 180])
    title(['RealAng: ' num2str(realAngles(i)) newline ...
        'MeanAbsError: ' num2str(meanError(i)) newline ...
        ' SD: ' num2str(A.sdJoint(i))])
end
legend('measured', 'real')

%% PLOTTing IMAGES
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