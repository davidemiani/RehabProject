function angle = inclinometer(varargin)
if nargin == 1
    A = varargin{1};
elseif nargin == 3
    A = [varargin{1},varargin{2},varargin{3}];
else
    error('Wrong input number.')
end
angle = 2*acosd(vecnorm(A./vecnorm(A,2,2)-[0,-1,0],2,2)/2);
end