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

% setting thresholds
omega_th = 10; % deg/s
time_th = 4; % s


%% COMPUTING JOINT ANGLE
%%
% synchronizing objects 
synchronize(obj,inf,false); 

% computing angles with projection algorithm
theta_hum = filterImuData(projection(obj(1,1)),sf);
theta_thx = filterImuData(projection(obj(2,1)),sf);
h = numel(theta_hum);

% computing joint angle as a sum of the two above
theta = abs(theta_hum + theta_thx);


%% ISO CHART
%%
% computing angular velocity
omega = discDerivative(theta,t0);

% getting under thresholds indexes (static position)
ind = (abs(omega) < omega_th)'; % row array

% getting ind rises and falls
rises = strfind(ind,[0,1])+1;
falls = strfind(ind,[1,0])+1;
if isempty(rises),rises = 1;end
if isempty(falls),falls = h;end
if falls(1,1) < rises(1,1)
    rises = [1,rises];
end
if rises(1,end) > falls(1,end)
    falls = [falls,h];
end

% now we have a static period between a rise and a fall index,
% so we can compute static period durations as:
times = (falls-rises)*t0;

% getting only periods longer than 4 seconds
times_ok_ind = (times>time_th)'; % col array
rises_ok_ind = rises(1,times_ok_ind)';
falls_ok_ind = falls(1,times_ok_ind)';
times = times(times_ok_ind)'./60; % converion from s to min

% creating ISO table
RowNames = ...
    {'LessThan20';'Between20and30';'Between30and40'; ...
    'Between40and50';'Between50and60';'MoreThan60'};
VariableNames = {'TimeArray','Occurrences','TotalTime','Mean','DevStd'};
ISO = cell2table(cell(numel(RowNames),1), ...
    'VariableNames',VariableNames(1,1), ...
    'RowNames',RowNames);
ISO = [ISO,array2table(zeros(numel(RowNames),numel(VariableNames)-1), ...
    'VariableNames', VariableNames(1,2:end), ...
    'RowNames',RowNames)];

% cycling on periods
for i = 1:numel(times)
    % getting current rise and fall indexes
    cRise = rises_ok_ind(i,1);
    cFall = falls_ok_ind(i,1);
    
    % getting current angle as the mean in this period
    % getting also current period duration
    cAngle = mean(theta(cRise:cFall));
    cDurat = times(i,1);
    
    % determining right bin
    if cAngle < 20
        cRow = 'LessThan20';
    elseif cAngle < 30
        cRow = 'Between20and30';
    elseif cAngle < 40
        cRow = 'Between30and40';
    elseif cAngle < 50
        cRow = 'Between40and50';
    elseif cAngle < 60
        cRow = 'Between50and60';
    else
        cRow = 'MoreThan60';
    end
    
    % updating ISO tab
    ISO{cRow,'TimeArray'}{1,1} = cat(1,ISO{cRow,'TimeArray'}{1,1},cDurat);
    ISO{cRow,'Occurrences'} = ISO{cRow,'Occurrences'} + 1;
    ISO{cRow,'TotalTime'} = ISO{cRow,'TotalTime'} + cDurat;
    ISO{cRow,'Mean'} = mean(ISO{cRow,'TimeArray'}{1,1});
    ISO{cRow,'DevStd'} = std(ISO{cRow,'TimeArray'}{1,1});
end
clear cRise cFall cAngle cDurat cRow

% creating ISOx and ISOy
ISOx = [10;25;35;45;55;70];
ISOy = ISO.TotalTime;

% computing chart max height
h = round(max(ISOy),-1)+10;

% plotting iso chart
figure('Position',get(0,'ScreenSize')), hold on
axis([0 80 0 h])
patch([ 0 20 20  0],[0 0 h h],[0 1 0],'EdgeColor','none','FaceAlpha',0.7)
patch([60 80 80 60],[0 0 h h],[1 0 0],'EdgeColor','none','FaceAlpha',0.9)
patch([20 20 60 60],[3 0 0 1],[0 1 0],'EdgeColor','none','FaceAlpha',0.5)
plot(ISOx,ISOy,'ok','MarkerSize',15,'MarkerFaceColor','k')

% text on dots
DISx = -ones(numel(ISOx),1)*1.5;
for i = 1:numel(ISOx)
    cISOx = ISOx(i,1);
    cISOy = ISOy(i,1);
    cDISx = DISx(i,1);
    cSTRG = {['n = ',num2str(ISO{i,'Occurrences'},2)]; ...
        ['\mu = ',char(duration(0,ISO{i,'Mean'},0))]; ...
        ['\sigma = ',char(duration(0,ISO{i,'DevStd'},0))]};
    plot(repmat(cISOx,1,2),[0,cISOy],'k','LineWidth',2)
    text(cISOx+cDISx,cISOy+0.075*h,cSTRG,'FontSize',20)
end
clear cISOx cISOy cDISx

% other plotting stuff
xticks(setdiff(xticks,[0,10,70,80]))
xlabel('angle (deg)')
ylabel( 'time (min)')
title({'ISO chart'; ...
    ['(total time = ',char(duration(0,0,(numel(theta)-1)*t0)), ...
    ', static total time = ',char(duration(0,sum(ISOy),0)),')']})
set(gca,'FontSize',25)


%% PLOTS FOR CECI
%%
% getting time
t = (0:t0:(numel(theta)-1)*t0)';

% opening a new figure
figure('Position',get(0,'ScreenSize'))

% plotting theta
subplot(2,1,1), hold on
plot(t,theta,'k','LineWidth',1.2)
plot(t(rises_ok_ind),theta(rises_ok_ind), ...
    'g^','MarkerSize',10,'MarkerFaceColor','g')
plot(t(falls_ok_ind),theta(falls_ok_ind), ...
    'rv','MarkerSize',10,'MarkerFaceColor','r')
xlabel('time (sec)');
ylabel('joint angle (deg)');
set(gca,'FontSize',25)

% plotting omega
subplot(2,1,2), hold on
plot(t,omega,'k','LineWidth',1.2)
plot(t(rises_ok_ind),omega(rises_ok_ind), ...
    'g^','MarkerSize',10,'MarkerFaceColor','g')
plot(t(falls_ok_ind),omega(falls_ok_ind), ...
    'rv','MarkerSize',10,'MarkerFaceColor','r')
xlabel('time (sec)');
ylabel('angular velocity (deg/sec)');
ylim([-150 150])
legend('signal','rises','falls')
set(gca,'FontSize',25)

