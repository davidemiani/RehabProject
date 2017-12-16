function ExelFigure = testFigure2()
% plot degli angoli di più sensori

% creating figure
Figure = figure('Visible','off','Position',get(0,'ScreenSize'));

% defining VarNames
VarNames = {'Homer Angle';'Thorax Angle'};

% defining sizes
[nAxes,nLines] = size(VarNames);

% defining colors, titles and measurment unit
t = VarNames;
u = repmat({'Degrees (\circ)'},size(VarNames));
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
            'Color','b','LineWidth',2); %#okAGROW
    end
    title(t{i,1})%,'Interpreter','none')
    %legend(VarNames(i,:))
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