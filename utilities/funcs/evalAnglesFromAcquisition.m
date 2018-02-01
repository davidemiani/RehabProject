function [Angles] = evalAnglesFromAcquisition(cartelleAcquisizioni, funzioneEval)
% FUNCTION TO EVALUATE ANGLES FROM ACQUISTION DATA.
% INPUT:
%   - cartelleAcquisizioni: cell array containing the names of the
%     directory containing the acquisition files (.mat)
%   - funzioneEval: function to evaluate angles (e.g. projection, projection2, etc.)
% OUTPUT:
%   - Angles: struct containg all angles 



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
    homerAngles{i} = tempHomerAngles; % save in a variable
    thoraxAngles{i} = tempThoraxAngles; % save in a variable
    meanJointAngles(i) = mean(jointAngles{i}); % save mean joint angle
    sdJointAngles(i) = std(jointAngles{i}); % save sd joint angle
end


Angles.joint = jointAngles;
Angles.homer = homerAngles;
Angles.thorax = thoraxAngles;
Angles.meanJoint = meanJointAngles;
Angles.sdJoint = sdJointAngles;

end

