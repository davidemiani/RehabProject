function UserData = InitFigure()
            % creating figure
            Figure = figure('Visible','off');
            
            % defining AxesWidth (in sec)
            AxesWidth = 15;
            
            % defining var names
            VarNames = { ...
                'AccX','AccY','AccZ'; ...
                'Acos','Atan','empty'; ...
                'Acos','Atan','empty' ...
                };
            
            % defining colors, titles and measurement units
            c = {'r','b','k'};
            t = {'Acc'; 
                'Frontal Angles'; ...
                'Sagittal Angles'};
            u = {'Acc (m\cdot s^{-2})'; ...
                'degrees (\circ)'; ...
                'degrees (\circ)'};
            
            % defining sizes
            nAxes = 3;
            nLines = 3;
            
            % creating Axes and Lines
            for i = 1:nAxes
                Axes(i,1) = subplot(nAxes,1,i); %#okAGROW
                Axes(i,1).XLim = [0,AxesWidth]; %#okAGROW
                Axes(i,1).FontSize = 15; %#okAGROW
                Axes(i,1).YMinorGrid = 'on'; %#okAGROW
                Axes(i,1).YMinorTick = 'on'; %#okAGROW
                for j = 1:nLines
                    Lines(i,j) = animatedline(Axes(i,1),'Color',c{1,j}); %#okAGROW
                end
                title(t{i,1})
                legend(VarNames(i,:))
                xlabel('time (s)')
                ylabel(u{i,1})
            end
            linkaxes(Axes,'x')
            
            % assigning Internal Figure fields
            UserData.Axes = Axes;
            UserData.Lines = Lines;
            UserData.Figure = Figure;
            UserData.VarNames = VarNames;
            UserData.AxesWidth = AxesWidth;
            UserData.LastFrame = 0;
            
            % setting SamplingFcn
            UserData.SamplingFcn = @SamplingFcn;
        end