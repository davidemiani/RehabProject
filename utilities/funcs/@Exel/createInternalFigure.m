function createInternalFigure(obj)
% creating figure
Figure = figure('Visible','off','Position',get(0,'ScreenSize'));

% defining AxesWidth (in sec)
AxesWidth = 15;

% defining var names
VarNames = { ...
    'AccX','AccY','AccZ'; ...
    'GyrX','GyrY','GyrZ'; ...
    'MagX','MagY','MagZ'  ...
    };

% defining colors and titles
c = {'r','b','k'};
t = {'Acc';'Gyr';'Mag'};
u = {'Acc (m\cdot s^{-2})'; ...
    '\omega (rad\cdot s^{-1})'; ...
    'Mag Field (T)'};

% defining sizes
[nAxes,nLines] = size(VarNames);

% creating Axes and Lines
for i = 1:nAxes
    Axes(i,1) = subplot(nAxes,1,i); %#okAGROW
    Axes(i,1).XLim = [0,AxesWidth]; %#okAGROW
    Axes(i,1).FontSize = 15; %#okAGROW
    Axes(i,1).YMinorGrid = 'on'; %#okAGROW
    Axes(i,1).YMinorTick = 'on'; %#okAGROW
    for j = 1:nLines
        Lines(i,j) = animatedline(Axes(i,1), ...
            'Color',c{1,j},'LineWidth',2); %#okAGROW
    end
    title(t{i,1})
    legend(VarNames(i,:))
    xlabel('time (s)')
    ylabel(u{i,1})
end
linkaxes(Axes,'x')

% assigning Internal Figure fields
obj.ExelFigure.Axes = Axes;
obj.ExelFigure.Lines = Lines;
obj.ExelFigure.Figure = Figure;
obj.ExelFigure.VarNames = VarNames;
obj.ExelFigure.AxesWidth = AxesWidth;
obj.ExelFigure.LastFrame = 0;

% setting SamplingFcn
obj.SamplingFcn = @obj.updateInternalFigure;

% setting CloseRequestFcn
obj.ExelFigure.Figure.CloseRequestFcn = @obj.figCloseRequestFcn;
end