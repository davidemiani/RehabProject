function ExelFigure = testFigure1()
% plot delle accelerazioni e degli angoli

% creating figure
Figure = figure('Visible','off');

% defining VarNames
VarNames = {'AccX','AccY','AccZ'; ...
    'Angle','empty','empty'};

% defining sizes
[nAxes,nLines] = size(VarNames);

% defining colors, titles and measurment unit
c = repmat({'r','b','k'},nAxes,1);
t = {'Accelerations';'Angle'};
u = {'Acc (m\cdot s^{-2})';'Degrees (\circ)'};
AxesWidth = 15;

% creating Axes and Lines
for i = 1:nAxes
    Axes(i,1) = subplot(nAxes,1,i); %#okAGROW
    Axes(i,1).XLim = [0,AxesWidth]; %#okAGROW
    Axes(i,1).FontSize = 15; %#okAGROW
    Axes(i,1).YMinorGrid = 'on'; %#okAGROW
    Axes(i,1).YMinorTick = 'on'; %#okAGROW
    for j = 1:nLines
        Lines(i,j) = animatedline(Axes(i,1), ...
            'Color',c{i,j},'LineWidth',2); %#okAGROW
    end
    title(t{i,1},'Interpreter','none')
    legend(VarNames(i,:))
    xlabel('time (s)')
    ylabel(u{i,1})
end
linkaxes(Axes,'x')

% assigning Internal Figure fields
ExelFigure.Axes = Axes;
ExelFigure.Lines = Lines;
ExelFigure.Figure = Figure;
ExelFigure.VarNames = VarNames;
ExelFigure.AxesWidth = AxesWidth;
ExelFigure.LastFrame = 0;
end