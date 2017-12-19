function uialert2(f,message,title,varargin)
narginchk(3, 9);
nargoutchk(0,0);
varargin = [{'Icon','Error','Options',{'OK'}},varargin];
selection = uiconfirm(f,message,title,varargin{:}); %#okAGROW
end