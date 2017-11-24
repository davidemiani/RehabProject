function [Acos,Atan] = computeSagittalAngle(AccX,AccY)
% computing Atan    
Atan = atan2d(AccX,AccY);
    
% preallocating Acos
Acos = zeros(size(Atan));

% getting AccY>=0 indexes
ind1 = AccY>=0;
ind2 = ~ind1;

% computing Acos
Acos(ind1,1) = real(acosd(round(AccX(ind1,1)/9.807,1)))-90;
Acos(ind2,1) = real(acosd(round(AccX(ind2,1)/9.807,1))); 
end