pulisci

fprintf('Creating Exel Objects... ')
obj = Exel('EXLs3', ...%{'EXLs3';'EXLs3_0159'}, ...
    'AutoStop',1, ...
    'PacketName','AGMOB', ...
    'ExelFigure','None');
set(obj(1,1),'Segment','Homer')
%set(obj(2,1),'Segment','Thorax')
fprintf('DONE!!\n')

try
    fprintf('Connecting... ')
    connect(obj)
    fprintf('DONE!!\n')
    
    fprintf('Acquiring... ')
    start(obj)
    waitfor(obj(1,1),'AcquisitionStatus','off')
    fprintf('DONE!!\n')
    
    fprintf('Disconnecting... ')
    disconnect(obj)
    fprintf('DONE!!\n')
catch ME
    fprintf('\n')
    warnaME(ME)
    stop(obj)
    disconnect(obj)
end


eul_hum = quat2eul(obj(1,1).ExelData{:,12:15}) .* (180/pi)

return
obj = ExelCompressed(obj);
h = min([height(obj(1,1).ExelData),height(obj(2,1).ExelData)]);
obj(1,1).ExelData = obj(1,1).ExelData(1:h,:);
obj(2,1).ExelData = obj(2,1).ExelData(1:h,:);

rotm_hum = quat2rotm(obj(1,1).ExelData{:,12:15});
rotm_thx = quat2rotm(obj(2,1).ExelData{:,12:15});
rotm_jnt = permute(rotm_thx,[2,1,3]) .* rotm_hum;

acc_hum = obj(1,1).ExelData{:,3:5};
acc_jnt = zeros(h,3);
for i = 1:h
    acc_jnt(i,:) = rotm_jnt(:,:,i) * acc_hum(i,:)';
end

theta = vecangle(acc_jnt,obj(2,1).ExelData{:,3:5});
plot(theta)



% eul_hum = quat2eul(obj(1,1).ExelData{:,12:15}) .* (180/pi);
% eul_thx = quat2eul(obj(2,1).ExelData{:,12:15}) .* (180/pi);
% eul_jnt = rotm2eul(rotm_jnt,'XYZ') .* (180/pi);

% figure
% subplot(3,1,1),plot(eul_hum),title('hum'),legend('\phi','\theta','\psi')
% subplot(3,1,2),plot(eul_thx),title('thx'),legend('\phi','\theta','\psi')
% subplot(3,1,3),plot(eul_jnt),title('jnt'),legend('\phi','\theta','\psi')





function ExelFigure = testFigure()
% creating figure
Figure = figure('Visible','off','Position',get(0,'ScreenSize'));

% defining AxesWidth (in sec)
AxesWidth = 10;

% defining var names
VarNames = { ...
    '\phi','\theta','\psi'; ...
    '\phi','\theta','\psi'; ...
    };

% defining colors and titles
c = {'r','b','k'};
t = {'Homerus';'Thorax'};
u = {'angle (deg)';'angle (deg)'};

% defining sizes
[nAxes,nLines] = size(VarNames);
Axes(nAxes,1) = axes();
Lines(nAxes,nLines) = animatedline();

% creating Axes and Lines
for i = 1:nAxes
    Axes(i,1) = subplot(nAxes,1,i);
    Axes(i,1).XLim = [0,AxesWidth];
    Axes(i,1).FontSize = 15;
    Axes(i,1).YMinorGrid = 'on';
    Axes(i,1).YMinorTick = 'on';
    for j = 1:nLines
        Lines(i,j) = animatedline(Axes(i,1), ...
            'Color',c{1,j},'LineWidth',2);
    end
    title(t{i,1})
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
end

function testFunction(obj,~,~)
% getting init & stop
init = obj.LastFrame+1;
stop = height(obj.ExelData);

% computing indexes and time
ind = (init : stop)';
time = (ind-1)/obj.SamplingFrequency;

% setting new XLim if necessary
if time(end,1) > obj.ExelFigure.Axes(1,1).XLim(1,2)
    obj.ExelFigure.Axes(1,1).XLim = ...
        obj.ExelFigure.Axes(1,1).XLim + ...
        obj.ExelFigure.AxesWidth;
end

% update chart
T = Q2T(obj.ExelData{ind,12:15});
if strcmp(obj.Segment,'Homer'),i=1;else,i=2;end
for j=2:2,addpoints(obj.ExelFigure.Lines(i,j),time,T(:,j)),end

% showing new values
drawnow limitrate

% updating last frame
obj.LastFrame = stop;
end