function i = discIntegral(x,y)
%DISCINTEGRAL calculates integral of a discrete signal.
%   I = DISCINTEGRAL(X,Y)
%   -------------------------------------------
%   INPUTS:
%   * X: x-values of the signal, it must be an array nx1 or 1xn;
%   * Y: y-values of the signal, it must be an array nx1 or 1xn.
%   OUTPUT:
%   * I: integral signal, it will be an array nx1 or 1xn.
%   -------------------------------------------
%   CREDITS:
%   Davide Miani (apr 2017)
%   -------------------------------------------
%   LAST REVIEW:
%   Davide Miani, (apr 2017)
%   -------------------------------------------
%   MAIL TO:
%   * davide.miani2@gmail.it
%   -------------------------------------------
%   -------------------------------------------

    i = zeros(size(x));
    for k=2:length(x)
        i(k) = i(k-1)+trapz([x(k-1),x(k)],[y(k-1),y(k)]);
    end
    
end

