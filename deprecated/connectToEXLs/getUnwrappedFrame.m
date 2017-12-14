function [frame, s185] = getUnwrappedFrame( frame, s185 )

% getUnwrappedFrame
%
% -------------------------------------------------------------------------
% INPUT
%
% -------------------------------------------------------------------------
% OUTPUT
%
% -------------------------------------------------------------------------
% EXAMPLE
% getUnwrappedFrame
%
% -------------------------------------------------------------------------
% SEE ALSO
% CALLED BY
%
% -------------------------------------------------------------------------
% RUN
%
% -------------------------------------------------------------------------
% AUTHOR
% Alberto Ferrari
% mailto: alberto.ferrari@unibo.it
%
% -------------------------------------------------------------------------
% REVIEW
% Feb 2013

% for i = 1 : length( frame )
%     
%     frame( i ) = frame( i ) + s185(1);% - startPlottingFrame;
%     
%     if mod( frame( i ), 185) == 0 && s185(2) == 0
%         
%         s185(1) = s185(1) + 186;
%         
%         s185(2) = 1;
%         
%     elseif mod( frame( i ), 440) == 0 && s185(2) == 1
%         
%         s185(1) = s185(1) + 256;
%         
%         s185(2) = 2;
%         
%     elseif mod( frame( i ), 255) == 0 && s185(2) == 2
%         
%         s185(1) = s185(1) + 256;
%         
%         s185(2) = 2;
%     end
% end

for i = 1 : length( frame )
    
    frame( i ) = frame( i ) + s185(1);% - startPlottingFrame;
    
    if mod( frame( i ), 1000 ) == 0 && s185(2) == 0
        
        s185(1) = s185(1) + 1001;
        
        s185(2) = 1;
    end
end

