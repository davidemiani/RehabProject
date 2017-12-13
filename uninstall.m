clc, clearvars, close all
csd = fileparts(mfilename('fullpath'));
warning('off','MATLAB:rmpath:DirNotFound')
rmpath(fullfile(csd,'utilities','funcs'))
rmpath(fullfile(csd,'utilities','icons'))
warning('on','MATLAB:rmpath:DirNotFound')
savepath
clearvars