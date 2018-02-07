% CLINICALREPORTISO
% computes ISO chart.


%% INIT
%%
% clearing Command Window, Workspace and closing all opened figures.
pulisci

% loading a valid file from acquisition dir
load(fullfile(pwd,'2018-02-01','FP94_02.mat'))

% getting sampling frequency and computing period
sf = obj(1,1).SamplingFrequency;
t0 = 1/sf;



%% COMPUTING JOINT ANGLE

            
    % presence
    ok_hum = any(strcmp(get(obj,'Segment'), 'Homer')); % Homer
    ok_thx = any(strcmp(get(obj,'Segment'),'Thorax')); % Thorax
    ok_jnt = ok_hum & ok_thx; % Joint

    % indexes
    if ~ok_hum
        thx_index = 1;
    elseif ok_thx
        thx_index = 2;
    end

    % synchronization routine
    synchronize(obj,inf); % by marta
    h = height(obj(1,1).ExelData);

    % preallocating angles and time
    theta = cell(3,1);
    times = cell(3,1);

    % computing angles
    if ok_hum
        theta{1,1} = filterImuData(projection(obj(1,1)),sf);
        times{1,1} = duration(0,0,(0:h-1)*t0);
    else
        theta{1,1} = [];
        times{1,1} = [];
    end
    if ok_thx
        theta{2,1} = filterImuData(projection(obj(thx_index,1)),sf);
        times{2,1} = duration(0,0,(0:h-1)*t0);
    else
        theta{2,1} = [];
        times{2,1} = [];
    end
    if ok_jnt
        theta{3,1} = abs(theta{1,1} + theta{2,1});
        times{3,1} = times{1,1};
    else
        theta{3,1} = [];
        times{3,1} = [];
    end

    % other plotting stuff
    Title = {'Homer';'Thorax';'Joint'};
    Color = [1,0,0;0,0,1;0,0,0];
    YLim = [0,180;-90,90;0,180];
    YTick = [0,30,60,90,120,150,180; ...
        -90,-60,-30,0,30,60,90; ...
        0,30,60,90,120,150,180];

    % creating figure
    figure('Position',get(0,'ScreenSize'))

    % preallocating axes
    ax(3,1) = axes();

    % cycling on Exel objects
for i = 1:3
    % plotting
    ax(i,1) = subplot(3,1,i);
    plot(times{i,1},theta{i,1},'Color',Color(i,:),'LineWidth',1.2)

    % setting some other properties
    xlabel('time')
    ylabel('angle (deg)')
    ylim(YLim(i,:))
    title(Title{i,:})
    set(ax(i,1),'YTick',YTick(i,:))
    set(ax(i,1),'XMinorGrid','on')
    set(ax(i,1),'YMinorGrid','on')
    set(ax(i,1),'XMinorTick','on')
    set(ax(i,1),'YMinorTick','on')
    set(ax(i,1),'FontSize',20)
end

% linking axes
linkaxes(ax,'x')
