function TestFigure = testFigure(ImuNames)
% questa testFigure plotterà un subplot per ogni sensore con le rispettive
% accelerazioni come animatedlines.

% creating figure
Figure = figure('Visible','off');

% defining VarNames
VarNames = repmat({'AccX','AccY','AccZ'},numel(ImuNames),1);

% defining colors, titles and measurment unit
c = {'r','b','k'};
t = ImuNames;
u = repmat({'Acc (m\cdot s^{-2})'},numel(ImuNames),1);

% defining sizes
[nAxes,nLines] = size(VarNames);

% creating Axes and Lines
for i = 1:nAxes
    Axes(i,1) = subplot(nAxes,1,i); %#okAGROW
    Axes(i,1).XLim = [0,10]; %#okAGROW
    Axes(i,1).FontSize = 15; %#okAGROW
    Axes(i,1).YMinorGrid = 'on'; %#okAGROW
    Axes(i,1).YMinorTick = 'on'; %#okAGROW
    for j = 1:nLines
        Lines(i,j) = animatedline(Axes(i,1),'Color',c{1,j}); %#okAGROW
    end
    title(t{i,1},'Interpreter','none')
    legend(VarNames(i,:))
    xlabel('time (s)')
    ylabel(u{i,1})
end
linkaxes(Axes,'x')

% assigning Internal Figure fields
TestFigure.Axes = Axes;
TestFigure.Lines = Lines;
TestFigure.Figure = Figure;
TestFigure.VarNames = VarNames;
TestFigure.ImuNames = ImuNames;
TestFigure.LastFrame = 0;
end