% CLINICALREPORTPIE
% computes PIE chart.


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


%% STATIC ANALYSIS
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

% preallocating
theta_ok = [];

% cycling on periods
for i = 1:numel(times)
    % getting current rise and fall indexes
    cRise = rises_ok_ind(i,1);
    cFall = falls_ok_ind(i,1);
    
    % getting current angle as the mean in this period
    % getting also current period duration
    theta_ok = [theta_ok;theta(cRise:cFall)]; %#okAGROW
end
clear cRise cFall


%% INITIALIZING STUFF FOR PIE CHART
%%
% creating a new figure for the PIE
figure('Position',get(0,'ScreenSize'))

% colors
c = [0,1,0; ...
    1,1,0; ...
    1,0.6471,0; ...
    1,0,0];

% legend
l = {'\theta<20'; ...
    '20\leq\theta<60'; ...
    '60\leq\theta<90'; ...
    '\theta\geq90'};


%% PIE CHART TOTAL
%%
% first subplot: total
subplot(1,2,1)

% computing pie data
PIEdata = [nnz(theta < 20), ...
    nnz(theta >= 20 & theta < 60), ...
    nnz(theta >= 60 & theta < 90), ...
    nnz(theta >= 90)] ./ numel(theta);
zero_elements = PIEdata == 0;

% plotting the pie chart
warning('off','MATLAB:pie:NonPositiveData')
p = pie(PIEdata);
warning('on','MATLAB:pie:NonPositiveData')
c_ok = c; l_ok = l;
c_ok(zero_elements,:) = []; l_ok(zero_elements,:) = [];
k = 1;
for i = 1:1:numel(p)
    if isa(p(1,i),'matlab.graphics.primitive.Patch')
        p(1,i).FaceColor = c_ok(k,:);
        k = k + 1;
    else
        p(1,i).FontSize = 25;
    end
end

% title
time_tot = duration(0,0,(numel(theta)-1)*t0);
tit = title({'PIE chart total';['(total time = ',char(time_tot),')']});
tit.Position(1,2) = tit.Position(1,2) + 0.2;

% legend
warning('off','MATLAB:legend:IgnoringExtraEntries')
leg = legend(l_ok,'Location','south','Orientation','horizontal');
leg.Position(1,2) = leg.Position(1,2) - 0.2;
warning('on','MATLAB:legend:IgnoringExtraEntries')

% setting all stuff a bit bigger thanks
set(gca,'FontSize',25)


%% PIE CHART ISO
%%
% second subplot: ISO
subplot(1,2,2)

% computing pie data
PIEdata = [nnz(theta_ok < 20), ...
    nnz(theta_ok >= 20 & theta_ok < 60), ...
    nnz(theta_ok >= 60 & theta_ok < 90), ...
    nnz(theta_ok >= 90)] ./ numel(theta_ok);
zero_elements = PIEdata == 0;

% plotting the pie chart
warning('off','MATLAB:pie:NonPositiveData')
p = pie(PIEdata);
warning('on','MATLAB:pie:NonPositiveData')
c_ok = c; l_ok = l;
c_ok(zero_elements,:) = []; l_ok(zero_elements,:) = [];
k = 1;
for i = 1:1:numel(p)
    if isa(p(1,i),'matlab.graphics.primitive.Patch')
        p(1,i).FaceColor = c_ok(k,:);
        k = k + 1;
    else
        p(1,i).FontSize = 25;
    end
end

% title
time_tot_stat = duration(0,0,(numel(theta_ok)-1)*t0);
tit = title({'PIE chart static angles';['(total time = ',char(time_tot_stat),')']});
tit.Position(1,2) = tit.Position(1,2) + 0.2;

% legend
warning('off','MATLAB:legend:IgnoringExtraEntries')
leg = legend(l_ok,'Location','south','Orientation','horizontal');
leg.Position(1,2) = leg.Position(1,2) - 0.2;
warning('on','MATLAB:legend:IgnoringExtraEntries')

% setting all stuff a bit bigger thanks
set(gca,'FontSize',25)

