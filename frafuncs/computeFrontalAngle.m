function [Acos,Atan] = computeFrontalAngle(AccY,AccZ)
% computing Atan    
Atan = atan2d(AccZ,AccY);
    
% preallocating Acos
Acos = zeros(size(Atan));

% getting AccY>=0 indexes
ind1 = AccY>=0;
ind2 = ~ind1;

% computing Acos
Acos(ind1,1) = real(acosd(round(-AccZ(ind1,1)/9.807,3)))-90;
Acos(ind2,1) = real(acosd(round(AccZ(ind2,1)/9.807,3)))+90; 
end