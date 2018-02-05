function varargout = BlandAltman(A,B,t)
%BLANDALTMAN Create BlandAltman plot.
%    BLANDALTMAN(A,B) where A and B are two N-length double array;
%    BLANDALTMAN(A,B,T) where T is the figure title;
%    H = BLANDALTMAN(A,B,T) where H is figure handle.

%compute mean of vectors
M = (A + B)/2;
%compute difference of vectors
D = A - B;

%mean of the difference
Mdiff = mean(D);
%standard deviation of the difference
SDdiff = std(D);

%Limits of Agreement
LOA_inf = Mdiff - 1.96*SDdiff;
LOA_sup = Mdiff + 1.96*SDdiff;

%plot bland altman
h = figure;
hold on
plot([min(M) max(M)],[LOA_inf LOA_inf], 'b');
plot([min(M) max(M)],[Mdiff Mdiff], '--r'); 
plot([min(M) max(M)],[LOA_sup LOA_sup], 'b'); 
plot(M,D,'ok');
plot([min(M) max(M)],[0 0], 'k');
legend('LOA','Mdiff');
title([t ' LOA = ' num2str(Mdiff,2) '\pm' num2str(1.96*SDdiff,2)]);

% outputting
if nargout > 0
    varargout{1,1} = h;
end

end