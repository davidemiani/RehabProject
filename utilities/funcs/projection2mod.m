function angle = projection2mod(obj,ind)
%PROJECTION Implement projection algorithm modified with controls on homer 
%accelerations.
% 
%    ANGLE = PROJECTION(OBJ) computes absolute angle between the sensor
%    and gravity using all value in the ExelData table of the Exel object
%    OBJ.
%
%    ANGLE = PROJECTION(OBJ,IND) compute absolute angle between the sensor
%    and gravity only for ExelData rows indicated by IND.
%
%    See also Exel, sagittal

% checking inputs and outputs number
narginchk(1,2)
nargoutchk(1,1)

% if no index specified, getting all of them
if nargin==1
    % getting rows number
    h = height(obj.ExelData);
    
    % getting indexes to plot
    ind = (1:h)';
else
    % getting sample number
    h = numel(ind);
end

% rotating acceleration (if thorax is calibrated, obj.Calibration~=eye(3))
A = obj.ExelData{ind,3:5} * obj.Calibration;
G = repmat([0,1,0],h,1);

% computing angle with projection method
%angle = 2*acosd(vecnorm(A./vecnorm(A,2,2)-[0,-1,0],2,2)/2);
angle = acosd(dot(A,G,2)./(vecnorm(A,2,2).*vecnorm(G,2,2)));

% Homer correction

if strcmp(obj.Segment,'Homer')
    if obj.UserData.isHomerRight == true
%     ind_SagittalRotation = (abs(A(:,1))) > abs(A(:,3)); % AccX > AccZ
%     ind_FrontalRotation = not(ind_SagittalRotation); % AccX < AccZ
        ind_dietro_vert = A(:,1)<0; %& A(:,3)>0; %Braccio indietro rispetto alla verticale
        ind_sx_vert = A(:,1)<0; %& A(:,3)<0; %Braccio a sx della verticale;
    
%     ind_SagittalToChange = ind_SagittalRotation & ind_AccXSmallerThan0;
        angle(ind_dietro_vert,1) = -angle(ind_dietro_vert,1);
    
%     ind_FrontalToChange = ind_FrontalRotation & ind_AccZSmallerThan0;
        angle(ind_sx_vert,1) = -angle(ind_sx_vert,1);
    
    else
        ind_dietro_vert = A(:,1)>0 & A(:,3)>0; %Braccio indietro rispetto alla verticale
        ind_sx_vert = A(:,1)<0 & A(:,3)>0; %Braccio a sx della verticale;
        angle(ind_dietro_vert,1) = -angle(ind_dietro_vert,1);
        angle(ind_sx_vert,1) = -angle(ind_sx_vert,1);
    end
end

% thorax corrections
if strcmp(obj.Segment,'Thorax')
    ind_SagittalRotation = abs(A(:,3))>abs(A(:,1));
    ind_FrontalRotation = not(ind_SagittalRotation);
    ind_AccXSmallerThan0 = A(:,1)<0;
    ind_AccZGreaterThan0 = A(:,3)>0;
    
    ind_SagittalToChange = ind_SagittalRotation & ind_AccZGreaterThan0;
    angle(ind_SagittalToChange,1) = -angle(ind_SagittalToChange,1);
    
    ind_FrontalToChange = ind_FrontalRotation & ind_AccXSmallerThan0;
    angle(ind_FrontalToChange,1) = -angle(ind_FrontalToChange,1);
    
end

end

