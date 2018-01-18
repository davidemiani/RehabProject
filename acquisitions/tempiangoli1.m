pulisci

load(fullfile(pwd,'2018-01-18','MM17_08.mat'))

fs = obj(1,1).SamplingFrequency;
t0 = 1/fs;

obj(1,1).ExelData{:,3:5} = filterData(obj(1,1).ExelData{:,3:5},fs);
obj(2,1).ExelData{:,3:5} = filterData(obj(2,1).ExelData{:,3:5},fs);

%compute angles
angleH0 = projection(obj(1,1));
angleT = projection(obj(2,1));
h = min(numel(angleH0),numel(angleT));
angleH0 = angleH0(1:h,1);
angleT = angleT(1:h,1);
angleH = angleH0 + angleT;

der_angleH = discDerivative(angleH,t0);
time = (0:numel(angleH)-1)*t0;

figure
ax(1) = subplot(2,1,1); plot(time,angleH), title('Homer')
ax(2) = subplot(2,1,2); plot(time,der_angleH), title('Der')
linkaxes(ax,'x')

der_th = 10; %deg/s
time_th=4; %sec
a = (abs(der_angleH)<der_th)';
n = numel(a);
rises = [0,strfind(a,[0,1])]+1;
falls = [strfind(a,[1,0]),n-1]+1;
times = (falls-rises)*t0;
times_ok = times>time_th;
rises_ok = rises(times_ok)';
falls_ok = falls(times_ok)';
times = times(times_ok)';

nIntervals = numel(rises_ok);
angles = zeros(nIntervals,1);
for i = 1:nIntervals
    cInit = rises_ok(i,1);
    cStop = falls_ok(i,1);
    angles(i,1) = round(mean(angleH(cInit:cStop)),-1);
end

tab = table(times,angles)
angles = (0:10:180)';
times = zeros(size(angles));
for i = 1:height(tab)
    times(i,1) = sum(tab.times(tab.angles==angles(i,1)));
end

table(angles,times)

anglesISO = angles(1:8);
timesISO = [times(1:7); sum(times(8:end))];
table(anglesISO,timesISO)


% ISO chart
figure,
%axis([0 75 0 5.5])
patch([0 20 20 0],  [0 0 5 5], [0 1 0],'EdgeColor', 'none', 'FaceAlpha', .7 )
patch([60 70 70 60],[0 0 5 5], [1 0 0],'EdgeColor', 'none', 'FaceAlpha', .9 )
patch([20 20 60 60],[3 0 0 1], [0 1 0],'EdgeColor', 'none', 'FaceAlpha', .5 )
hold on,plot(anglesISO,timesISO/60,'*k')

% pie graphic
figure,
%pie( sag./(numel( diffSag )+5), [1 1 0 0 0] )
pie([sum(times(1:3)) sum(times(4:7)) sum(times(8:10)) sum(times(10:end))]./sum(times) );
legend('0-20', '20-60', '60-90', '>90' ,'Location', 'Best' ),  title( {'Sagittal';''} )


% a = [1; diff(ind_derConst)];
% a(end) = -1;
% inizio = find(a == 1);
% fine = find(a == -1);
% subplot(2,1,1),hold on,plot(time(inizio),angleH(inizio),'og')
% subplot(2,1,2),hold on,plot(time(inizio),der_angleH(inizio),'og')
% 
% subplot(2,1,1),hold on,plot(time(fine),angleH(fine),'ok')
% subplot(2,1,2),hold on,plot(time(fine),der_angleH(fine),'ok')
% 
% timeLong = 0;
% for i = 1:numel(inizio)
%     currentInterval = time(inizio(i))-time(fine(i));
%     if currentInterval>=4
%         timeLong = timeLong + 1;
%         [currentAngle(timeLong) = round(mean(angleH(inizio(i):fine(i))),-1);
%     end
    
        



function vec = filterData( vec, fs )
% fc = 100;
% passband edge frequency (cut off freq) in bandpass; normalized for pi
Wp = 1 / ( fs/2 ); % wp = 2 * pi * fp * Tc --> pi * fp /( fc/ 2 ) --> fp /( fc/ 2 )
% stopband edge frequency (cut off freq) in stopband; normalized for pi
Ws = .9092; %(fc/2.3) / ( fc/2 );% ws = 2 * pi * fs * Tc --> pi * fs /( fc/ 2 ) --> fs /( fc/ 2 )
% gain in Bandpass , loses no more than 1 dB in the passband equal to 10%
Gp = 1;
% gain in Stopband (has at least 10 dB of attenuation in the stopband, pass just more than 30%)
Gs = 100;

[ Nbutter, Wnbutter ] = buttord( Wp, Ws, Gp, Gs );

% A,B series of coefficients
[ Bbutter, Abutter ]= butter( Nbutter, Wnbutter );

% filtering the signal, with zero-phase shifting
vec(:,1) = filtfilt( Bbutter, Abutter, vec(:,1) );
vec(:,2) = filtfilt( Bbutter, Abutter, vec(:,2) );
vec(:,3) = filtfilt( Bbutter, Abutter, vec(:,3) );

end