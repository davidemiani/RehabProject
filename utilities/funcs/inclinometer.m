function angle = inclinometer(obj,ind)
narginchk(1,2)
nargoutchk(1,1)
if nargin==1
    ind = (1:height(obj.ExelData))';
end
A = obj.ExelData{ind,3:5} * obj.Calibration;
angle = 2*acosd(vecnorm(A./vecnorm(A,2,2)-[0,-1,0],2,2)/2);
if strcmp(obj.Segment,'Thorax')
    negRot = A(:,end)>0;
    angle(negRot) = -angle(negRot);
end
end