function [dirs, paths] = dirs2cell(folder_path)
%DIRS2CELL puts in a cell array names/paths of subdirectories in a folder.
%   [DIRS,PATHS] = DIRS2CELL(FOLDER_PATH)
%   -------------------------------------------
%   INPUTS:
%   * NO INPUTS: folder_path will be setted on current directory;
%   * FOLDER_PATH: it must be a valid folder path.
%   OUTPUTS:
%   * DIRS: cell array of char that contains the names of subdirectories;
%   * PATHS: cell array of char that contains the paths of subdirectories.
%   -------------------------------------------
%   CREDITS:
%   Davide Miani (jul 2016),
%   -------------------------------------------
%   LAST REVIEW:
%   Davide Miani (nov 2016).
%   -------------------------------------------
%   MAIL TO:
%   * davide.miani2@gmail.com

    if nargin==0
        folder_path = pwd;
    end
    
    if isempty(fileparts(folder_path))
        error('You have to specify the absolute path of the folder.')
    end
    
    if isdir(folder_path)
        list = dir(folder_path);
        list_size = size(list, 1);
        dirs  = cell(list_size,1);
        paths = cell(list_size,1);
        if list_size>0
            j = 1;
            for i=1:list_size
                path = fullfile(folder_path,list(i,1).name);
                if isdir(path)
                    dirs{j} = list(i,1).name;
                    paths{j} = path;
                    j = j+1;
                end
            end
            j = j-1;

            dirs = dirs(1:j);
            paths = paths(1:j);

            i = 1;
            while i<=length(dirs)
                if strcmp(dirs{i}(1),'.')
                    dirs(i)  = [];
                    paths(i) = [];
                else
                    i = i+1;
                end
            end
        end
    else
        error('Specified path not existent or not a directory')
    end
    
end

