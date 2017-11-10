function varargout = userfolder()
%USERPFOLDER gets the user folder path.
%   PATH = USERFOLDER()
%   -------------------------------------------
%   INPUTS:
%   * no inputs required.
%   OUTPUT:
%   * PATH: the user folder path in a string
%   -------------------------------------------
%   CREDITS:
%   Davide Miani, adidas AG (mar 2017)
%   -------------------------------------------
%   LAST REVIEW:
%   Davide Miani, adidas AG (mar 2017)
%   -------------------------------------------
%   MAIL TO:
%   * davide.miani@adidas.it
%   -------------------------------------------
%   -------------------------------------------
    drivers = getdrives();
    user_name = username();
    for i=1:length(drivers)
        if islinux
            temp = fullfile(drivers{i,1},'home',user_name);
        else
            temp = fullfile(drivers{i,1},'Users',user_name);
        end
        if exist(temp,'dir')
            break
        end
    end
    path = temp;
    if nargout==0
        cd(path)
    else
        varargout{1} = path;
    end
end

