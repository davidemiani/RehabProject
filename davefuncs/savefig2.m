function savefig2(fhandle,filepath,dim,autoclose)
%SAVEFIG to save MATLAB figures in several formats.
%   SAVEFIG(FHANDLE,FILEPATH,EXT,DIM,AUTOCLOSE)
%   -------------------------------------------
%   INPUTS:
%   * FHANDLE: (Figure) a valid MATLAB figure handle;
%   * (FILEPATH): (char, default: 'pwd/figure.png') absolute path of the
%       file you want to save; you have to specify the extension here in
%       this name, or the default extension will be png.
%   * (DIM): (1x2 numeric/1x4 numeric/char, default: current dimension)
%       figure dimension you want; specify 'ScreenSize' if you want to
%       save the file at your screen dimension;
%   * (AUTOCLOSE): (bool, default: true) if true, close the figure at the
%       end of saving.
%   -------------------------------------------
%   CREDITS:
%   Davide Miani (jun 2017)
%   -------------------------------------------
%   LAST REVIEW:
%   Davide Miani (jun 2017)
%   -------------------------------------------
%   MAIL TO:
%   * davide.miani2@gmail.com
%   -------------------------------------------
%   -------------------------------------------

    % validating inputs
    if nargin==0
        error('At least one input required (a valid figure handle).')
    elseif nargin==1
        fhandle = validate1(fhandle);
        filepath = fullfile(pwd,'figure.png');
        ext = 'png';
        dim = get(fhandle,'Position');
        autoclose = true;
    elseif nargin==2
        fhandle = validate1(fhandle);
        [filepathNoExt,ext] = validate2(filepath);
        dim = get(fhandle,'Position');
        autoclose = true;
    elseif nargin==3
        fhandle = validate1(fhandle);
        [filepathNoExt,ext] = validate2(filepath);
        dim = validate3(dim);
        autoclose = true;
    else
        fhandle = validate1(fhandle);
        [filepathNoExt,ext] = validate2(filepath);
        dim = validate3(dim);
        autoclose = validate4(autoclose);
    end
    
    % saving figure
    set(fhandle,'Visible','on');
    set(fhandle,'Position',dim);
    set(fhandle,'PaperPositionMode','auto') % set paper pos for printing
    saveas(fhandle,filepathNoExt,ext)
    if autoclose
        close(fhandle)
        clear fhandle
        pause(0.02)
    end
end


%% subfunctions
function fhandle = validate1(fhandle)
    if ~ishandle(fhandle)
        error('fhandle must be a valid figure handle.')
    end
end

function [filepathNoExt,ext] = validate2(filepath)
    [folderpath,filename,ext] = fileparts(filepath);
    if isempty(folderpath)
        folderpath = pwd;
    end
    if isempty(filename)
        filename = 'figure';
    end
    if isempty(ext)
        ext = 'png';
    else
        ext = ext(2:end);
    end
    filepathNoExt = fullfile(folderpath,filename);
end

function dim = validate3(dim)
    if ischar(dim)
        if strcmp(dim,'ScreenSize')
            dim = get(0,'ScreenSize');
        else
            warning('The only valid char input for dim is ''ScreenSize''')
            dim = get(gcf,'Position');
        end
    elseif isnumeric(dim)
        [m,n] = size(dim);
        if m==1
            switch n
                case 2
                    dim = [1,1,dim];
                case 4
                otherwise
                    warning('dim must be an 1x4 numeric array')
                    dim = get(gcf,'Position');
            end
        else
            warning('dim must be an 1x4 numeric array')
            dim = get(gcf,'Position');
        end
    else
        dim = get(gcf,'Position');
    end
end

function autoclose = validate4(autoclose)
    if isnumeric(autoclose)
        if autoclose==1
            autoclose = true;
        else
            autoclose = false;
        end
    elseif islogical(autoclose)
    else
        warning('autoclose must be a logical input')
        autoclose = true;
    end
end