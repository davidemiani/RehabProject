function [angle1,angle2] = newprojection(ExelObj,ind)
% checking inputs and outputs number
narginchk(1,2)
nargoutchk(1,2)

% validating inputs (TO BE COMPLETED)
if ~isa(ExelObj,'Exel') && ~isa(ExelObj,'ExelCompressed')
    error('newprojection:invalidInput', ...
        'Input must be a valid Exel/ExelCompressed array object.')
end
ExelObj = ExelObj(:); % making it a column array
if length(ExelObj)~=2
    error('newprojection:invalidLength', ...
        'Input must be a valid 2x1 or 1x2 Exel/ExelCompressed array.')
end

% if no index specified, getting all of them
if nargin==1
    ind = (1:height(ExelObj(1,1).ExelData))';
end

% getting homer & thorax indexes in obj array
Hind = 1;%string(ExelObj.Segment) == 'Homer';
Tind = 2;%string(ExelObj.Segment) == 'Thorax';

% getting accelerations
Hacc = ExelObj(Hind,1).ExelData{ind,3:5} * ExelObj(Hind,1).Calibration;
Tacc = ExelObj(Tind,1).ExelData{ind,3:5} * ExelObj(Tind,1).Calibration;

% old one
% angle = 2*acosd(vecnorm(A./vecnorm(A,2,2)-[0,-1,0],2,2)/2);
% so maybe we have to normalize both vectors right now


%% New Projection
% normalizing accelerations
Hacc = Hacc./vecnorm(Hacc,2,2);
Tacc = Tacc./vecnorm(Tacc,2,2);

% computing angle
angle1 = 2*acosd(vecnorm(Hacc+Tacc,2,2)/2);


%% Using scalar product formula
% getting norm vectors
Hnorm = vecnorm(Hacc,2,2);
Tnorm = vecnorm(Tacc,2,2);

% % computing angle
angle2 = acosd(dot(Hacc,Tacc,2)./(Hnorm.*Tnorm));


end

