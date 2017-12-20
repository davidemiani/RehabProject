function angle = projection(obj,ind)
%PROJECTION Implement projection algorithm.
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
    ind = (1:height(obj.ExelData))';
end

% rotating acceleration (if thorax is calibrated, obj.Calibration~=eye(3))
A = obj.ExelData{ind,3:5} * obj.Calibration;

% computing angle with projection method
angle = 2*acosd(vecnorm(A./vecnorm(A,2,2)-[0,-1,0],2,2)/2);

% if Segment is Thorax, cheching AccZ for a negative rotation
if strcmp(obj.Segment,'Thorax')
    negRot = A(:,end)>0;
    angle(negRot) = -angle(negRot);
end
end