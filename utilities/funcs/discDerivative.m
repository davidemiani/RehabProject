function der = discDerivative(Y,t0)
%DISCDERIVATIVE calculates the derivative of a signal
%   DER = DISCDER(Y,sf)
    
    if not(min(size(Y))==1)
        disp('Only vectors please!')
        return
    elseif length(Y)<3
        disp('Length >3 please!')
        return
    end
    
    der = zeros(size(Y));
    for i=2:length(Y)-1
        der(i) = (Y(i+1)-Y(i-1))/(2*t0);
    end
    
    der(1) = der(2);
    der(end) = der(end-1);
    
end

