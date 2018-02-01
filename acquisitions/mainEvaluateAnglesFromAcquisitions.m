% Evaluation of joint angle from acquisition
clear
close all
clc

%% INIT
cartelleAcquisizioni = {'2018-01-31', '2018-02-01'};
funzioneEval = @projection;

A = evalAnglesFromAcquisition(cartelleAcquisizioni, funzioneEval);


% %% PLOTTING DATA
% realAngles = [0; 0; 0; 0; 0; 0; 45; 90; 135; 180; 30; 45; 90; 30; 60; 45; 90; 135; 180; 45; 90; 120; 45; 90; 30; 75];
% meanError = abs(meanJointAngles - realAngles);
% rowsSubplot = 4;
% colsSubplot = 7;
% 
% figure
% for i = 1:numel(paths)
%     subplot(rowsSubplot, colsSubplot, i)
%     plot(jointAngles{i})
%     hold on
%     plot(1:numel(jointAngles{i}), ones(1, numel(jointAngles{i}))*realAngles(i))
%     hold off
%     ylim([-180 180])
%     title(['RealAng: ' num2str(realAngles(i)) newline ...
%         'MeanAbsError: ' num2str(meanError(i)) newline ...
%         ' SD: ' num2str(sdJointAngles(i))])
% end
% legend('measured', 'real')

% %% PLOTTing IMAGES
% for i = 1:numel(cartelleAcquisizioni)
%     % load images
%     [~,imPaths] = files2cell(fullfile(csd,cartelleAcquisizioni{i}, 'ImmaginiPosizioniValutate'),'.png');
%     % ERRATO
% end
% 
% figure
% for i = 1:numel(imPaths)
%     % load image
%     [im, map] = imread(imPaths{i}, 'png');
%     
%     % subplot
%     subplot(rowsSubplot, colsSubplot, i)
%     imshow(im)
%     colormap(map)
%     title(['Immagine ' num2str(i)])
% end

%% STATIC INTERVALS SELECTION

% show angles
figure
for i = 1:numel(A.joint)
    subplot(2,4,i)
    plot(A.joint{i})
end

% initializig cell array with clean data
jointAnglesNoJump = cell(size(A.joint));

% removing signal pre/post jump

% 1. CM94_01
[p, inds] = findpeaks(A.joint{1}, 'MinPeakHeight', 150);

figure
plot(A.joint{1})
hold on
plot(inds, p, '*');
hold off

jointAnglesNoJump{1} = A.joint{1}(inds(end-1):inds(end));

figure
plot(jointAnglesNoJump{1})

% 2. CM94_02
[p, inds] = findpeaks(A.joint{2}, 'MinPeakHeight', 150);

figure
plot(A.joint{2})
hold on
plot(inds, p, '*');
hold off

jointAnglesNoJump{2} = A.joint{2}(inds(end-1):inds(end));

figure
plot(jointAnglesNoJump{2})

% 3. FP94_01
[p, inds] = findpeaks(A.joint{3}, 'MinPeakHeight', 150);

figure
plot(A.joint{3})
hold on
plot(inds, p, '*');
hold off

jointAnglesNoJump{3} = A.joint{3}(inds(end-1):inds(end));

figure
plot(jointAnglesNoJump{3})

% 4. FP94_02
[p, inds] = findpeaks(A.joint{4}, 'MinPeakHeight', 150);

figure
plot(A.joint{4})
hold on
plot(inds, p, '*');
hold off

jointAnglesNoJump{4} = A.joint{4}(inds(end-2):inds(end-1));

figure
plot(jointAnglesNoJump{4})

% 5. GL94_01
[p, inds] = findpeaks(A.joint{7}, 'MinPeakHeight', 150);

figure
plot(A.joint{7})
hold on
plot(inds, p, '*');
hold off

jointAnglesNoJump{7} = A.joint{7}(inds(1):inds(end));

figure
plot(jointAnglesNoJump{7})

% 6. GL94_02
[p, inds] = findpeaks(A.joint{8}, 'MinPeakHeight', 150);

figure
plot(A.joint{8})
hold on
plot(inds, p, '*');
hold off

jointAnglesNoJump{8} = A.joint{8}(inds(1):end);

figure
plot(jointAnglesNoJump{8})