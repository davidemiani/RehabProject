function [dirs,paths] = deepDirs2cell(folder_path)
    
    if nargin==0
        folder_path = pwd;
    end
    
    if isdir(folder_path)
        [dirs,paths] = dirs2cell(folder_path);
        if not(isempty(paths))
            for i=1:length(paths)
                [d,p] = deepDirs2cell(paths{i});
                dirs = [dirs;d];
                paths = [paths;p];
            end
        end
    end
    
end