function [files,paths] = files2cell(folder_path,ext)
%FILES2CELL puts in a cell array names/paths of files in a folder.
%   [FILES,PATHS] = FILES2CELL(FOLDER_PATH,EXT)
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
%   Remake by Davide Miani (nov 2016) from 'filesInFolderToCell.m',
%   by Andrea Giovanardi (apr 2015).
%   -------------------------------------------
%   LAST REVIEW:
%   Davide Miani (nov 2016).
%   -------------------------------------------
%   MAIL TO:
%   * a.giova83@gmail.com
%   * davide.miani2@gmail.com
    
    if nargin<=1
        ext = '';
        if nargin==0
            folder_path = pwd;
        end
    end
    
    if isempty(fileparts(folder_path))
        error('You have to specify the absolute path of the folder.')
    end
    
    if isdir(folder_path)
        files_struct = dir(fullfile(folder_path, ['*', ext]));
        dim = size(files_struct, 1);
        files = cell(dim, 1);
        paths = cell(dim, 1);
        if dim>0
            for i = 1:dim
                files{i,1} = files_struct(i,1).name;
                paths{i,1} = fullfile(folder_path, files_struct(i,1).name);
            end
            i = 1;
            while i<=length(files)
                if isdir(paths{i}) || strcmp(files{i}(1),'.')
                    files(i) = [];
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

