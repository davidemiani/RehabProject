% CLINICALREPORT
% computes PIE and ISO chart.


%% INIT
%%
% clearing Command Window, Workspace and closing all opened figures.
pulisci

% loading a valid file from acquisition dir
load(fullfile(pwd,'2018-01-19','MM17_01.mat'))

% getting sampling frequency and computing period
sf = obj(1,1).SamplingFrequency;
t0 = 1/sf;

% setting thresholds
omega_th = 10; % deg/s
time_th = 4; % s


%% COMPUTING JOINT ANGLE
%%
% filtering accelerations
obj(1,1).ExelData{:,3:5} = filterImuData(obj(1,1).ExelData{:,3:5},sf);
obj(2,1).ExelData{:,3:5} = filterImuData(obj(2,1).ExelData{:,3:5},sf);

% computing absolute angles (with gravity) with projection algorithm
theta_hum = projection(obj(1,1));
theta_thx = projection(obj(2,1));

% getting smallest dimension and cutting angles
h = min(numel(theta_hum),numel(theta_thx));
theta_hum = theta_hum(1:h,1);
theta_thx = theta_thx(1:h,1);

% computing joint angle as a sum of the two above
theta = theta_hum + theta_thx;


%% ISO CHART
%%
% computing angular velocity
omega = discDerivative(theta,t0);

% getting under thresholds indexes (static position)
ind = (abs(omega) < omega_th)'; % row array

% getting ind rises and falls
rises = strfind(ind,[0,1])+1;
falls = strfind(ind,[1,0])+1;
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
times = (times(times_ok_ind)'./60); % converion from s to min

% creating ISO table
ISO = array2table(zeros(1,6),'VariableNames', ...
    {'LessThan20','Between20and30','Between30and40', ...
    'Between40and50','Between50and60','MoreThan60'});

% cycling on periods
for j = 1:numel(times)
    % getting current rise and fall indexes
    cRise = rises_ok_ind(j,1);
    cFall = falls_ok_ind(j,1);
    
    % getting current angle as the mean in this period
    % getting also current period duration
    cAngle = mean(theta(cRise:cFall));
    cDurat = times(j,1);
    
    % filling right bin
    if cAngle < 20
        ISO.LessThan20 = ISO.LessThan20 + cDurat;
    elseif cAngle < 30
        ISO.Between20and30 = ISO.Between20and30 + cDurat;
    elseif cAngle < 40
        ISO.Between30and40 = ISO.Between30and40 + cDurat;
    elseif cAngle < 50
        ISO.Between40and50 = ISO.Between40and50 + cDurat;
    elseif cAngle < 60
        ISO.Between50and60 = ISO.Between50and60 + cDurat;
    else
        ISO.MoreThan60 = ISO.MoreThan60 + cDurat;
    end
end
clear cRise cFall cAngle cFall

% creating ISOx and ISOy
ISOx = [10,25,35,45,55,70];
ISOy = ISO{1,:};

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
DISx = -[2,4,4,4,4,2];
STR = {'\theta<20';'20\leq\theta<30';'30\leq\theta<40'; ...
    '40\leq\theta<50';'50\leq\theta<60';'\theta\geq60'};
for j = 1:numel(ISOx)
    cISOx = ISOx(1,j);
    cISOy = ISOy(1,j);
    cDISx = DISx(1,j);
    plot(repmat(cISOx,1,2),[0,cISOy],'k','LineWidth',2)
    text(cISOx+cDISx,cISOy+0.035*h,STR{j,1},'FontSize',25)
end
clear cISOx cISOy cDISx

% other plotting stuff
xticks(setdiff(xticks,[0,10,70,80]))
xlabel('angle (deg)')
ylabel( 'time (min)')
title('ISO chart')
set(gca,'FontSize',25)


%% PIE CHART
%%
% computing pie data
PIEdata = [nnz(theta < 20), ...
    nnz(theta >= 20 & theta < 60), ...
    nnz(theta >= 60 & theta < 90), ...
    nnz(theta >= 90)] ./ numel(theta);
PIEdata(PIEdata==0) = 0.009999;

% plotting a pie
figure('Position',get(0,'ScreenSize'))
p = pie(PIEdata);
for j = 2:2:numel(p)
    p(1,j).FontSize = 25;
    p(1,j).Position = p(1,j).Position - p(1,j).Position*0.075;
end
title('PIE chart')
legend('\theta<20','20\leq\theta<60', ...
    '60\leq\theta<90','\geq90','Location','Best')
text(-0.9,-1.25, ...
    'Percentage of time spent in different angle ranges','FontSize',25)
set(gca,'FontSize',25)

