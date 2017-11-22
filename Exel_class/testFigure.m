function FigureHandle = testFigure(ImuNames)
% imu numbers
nPlots = numel(ImuNames);

% creating figure
Figure = figure('Visible','off');

% setting desired colors
c = {'r','b','k'};

% creating subplots and animated plots
for i = 1:nPlots
    Axes(i,1) = subplot(nPlots,1,i); %#okAGROW
    for j = 1:3
        Lines(i,j) = animatedline(Axes(i,1),'Color',c{1,j}); %#okAGROW
        % other options here
    end
    title(ImuNames{i,1},'Interpreter','none')
    xlabel('time (s)')
    ylabel('acc (m\cdot s^{-2})')
    legend('acc x','acc y','acc z')
end
linkaxes(Axes,'x')

% setting FigureHandle fields
FigureHandle.Axes = Axes;
FigureHandle.Lines = Lines;
FigureHandle.Figure = Figure;
FigureHandle.ImuNames = ImuNames;
FigureHandle.LastFrame = 0;
end