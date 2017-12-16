function pos = centerfig(fig1,fig2)
narginchk(1,2)
nargoutchk(0,1)
if nargin==1
    fig2 = fig1;
    fig1 = 'ScreenSize';
end

pos1 = validate(fig1);
pos2 = validate(fig2);

parenW = pos1(3);
childW = pos2(3);

parenH = pos1(4);
childH = pos2(4);

parenX = pos1(1);
parenY = pos1(2);

pos = [parenX+parenW/2-childW/2,parenY+parenH/2-childH/2,childW,childH];
end

function pos = validate(obj)
switch class(obj)
    case 'matlab.ui.Figure'
        pos = obj.Position;
    case {'double','single', ...
            'int8','int16','int32','int64', ...
            'uint8','uint16','uint32','uint64'}
        if isequal(size(obj),[1,4])
            pos = obj;
        else
            error('centerfig:validate:numericInput', ...
                'If input is numeric, it must be 1x4.')
        end
    case 'char'
        if ismember(obj,{'screen','Screen', ...
                'screensize','screenSize','Screensize','ScreenSize'})
            pos = get(0,'screensize');
        end
    otherwise
        error('centerfig:validate:invalidInput', ...
            'Input must be matlab.ui.Figure, numeric or char.')
end
end