function [success, msg] = touch(directory)
%TOUCH check dir existance and create it if unexistent.
%   RES = TOUCH(DIRECTORY)
%   DIRECTORY must be a path.

    if not(isdir(directory))
        [success, msg] = mkdir(directory);
        if not(success)
            if strcmp(msg,'Permission denied')
                [success, msg] = sudo(['mkdir ', directory]);
            end
        end
    end
    
end
        