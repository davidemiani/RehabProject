function [files,paths] = deepFiles2cell(folder_path,ext)
%DEEPFILES2CELL puts in a cell array names/paths of all files found
%in folders and subfolders starting from an input directory.
%   [FILES,PATHS] = DEEPFILES2CELL(FOLDER_PATH,EXT)
%   -------------------------------------------
%   INPUTS:
%   * NO INPUTS: folder_path will be setted on current directory;
%   * FOLDER_PATH: it must be a valid folder path;
%   * EXT: it must be a string with format '.XXX'; if it is not specified, 
%          all files in the folder will be loaded.
%   OUTPUTS:
%   * FILES: cell array of char that contains filenames;
%   * PATHS: cell array of char that contains filepaths.
%   -------------------------------------------
%   CREDITS:
%   Davide Miani (nov 2016).
%   -------------------------------------------
%   LAST REVIEW:
%   Davide Miani (nov 2016).
%   -------------------------------------------
%   MAIL TO:
%   * davide.miani@hotmail.it
%   * davide.miani2@studio.unibo.it
    
    if nargin<=1
        ext = '';
        if nargin==0
            folder_path = pwd;
        end
    end
    
    if isdir(folder_path)
        [files,paths] = files2cell(folder_path,ext);
        [~,dirs_path] = dirs2cell(folder_path);
        if not(isempty(dirs_path))
            parfor i=1:length(dirs_path)
                [f,p] = deepFiles2cell(dirs_path{i},ext);
                files = [files;f];
                paths = [paths;p];
            end
        end
    end
    
end