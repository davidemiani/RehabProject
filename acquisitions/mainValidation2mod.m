% mainValidation
clear
close all
clc

%% INIT
cartelleAcquisizioni = {'2018-01-31', '2018-02-01'};
funzioneEval = @projection2mod;

% parameters
sf = 50;
t0 = 1/sf;
time_th = 4;
omega_th = 10;

% evaluate angles 
Afull = evalAnglesFromAcquisition(cartelleAcquisizioni, funzioneEval);

% rimuovo le acquisizioni veloci
A.joint = Afull.joint([1,2 5:8]);
A.homer = Afull.homer([1,2 5:8]);
A.thorax = Afull.thorax([1,2 5:8]);
A.meanJoint = Afull.meanJoint([1,2 5:8]);
A.sdJoint = Afull.sdJoint([1,2 5:8]);


%% CLEANING DATA FROM JUMP

% show angles
figure
for i = 1:numel(A.joint)
    subplot(2,4,i)
    plot(A.joint{i})
end

% initializig cell array with clean data
jointAnglesNoJump = cell(size(A.joint));

for i = 1:numel(jointAnglesNoJump)
    jointAnglesNoJump{i} = cleanAngleFromJump(A.joint{i}, 0);
end

%% FILTER ANGLES

% BANDPASS
% passband edge frequency (cut off freq) in bandpass, normalized for pi.
% wp = 2 * pi * fp * Tc --> pi * fp /( fc/ 2 ) --> fp /( fc/ 2 )
Wp = 1 / ( sf/2 );
% STOPBAND
% stopband edge frequency (cut off freq) in stopband; normalized for pi.
% (fc/2.3) / ( fc/2 );
% ws = 2 * pi * fs * Tc --> pi * fs /( fc/ 2 ) --> fs /( fc/ 2 )
Ws = 0.9092;
% GAIN
% gain in Bandpass , loses no more than 1 dB in the passband equal to 10%
Gp = 1;
% gain in Stopband (has at least 10 dB of attenuation in the stopband,
% pass just more than 30%)
Gs = 100;
% FILTER CREATION
[ Nbutter, Wnbutter ] = buttord( Wp, Ws, Gp, Gs );

% A,B series of coefficients
[ Bbutter, Abutter ]= butter( Nbutter, Wnbutter );
% FILTERING
% filtering the signal, with zero-phase shifting
for i = 1:numel(jointAnglesNoJump)
    jointAnglesNoJump{i} = filtfilt( Bbutter, Abutter, jointAnglesNoJump{i});
end

%% EVALUATING ANGLES STATIC PERIODS
acquisitions = {'CM94_01', 'CM94_02', 'FP94_01', 'FP94_02', 'GL94_01', 'GL94_02'};

for i = 1:numel(jointAnglesNoJump)
    % evaluate length of the vector
    h = length(jointAnglesNoJump{i});
    
    % computing angular velocity
    omega = discDerivative(jointAnglesNoJump{i}, t0); % 50 == fs
    
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
        falls = [falls, h];
    end
    
    % now we have a static period between a rise and a fall index,
    % so we can compute static period durations as:
    times = (falls-rises)*t0;
    
    % getting only periods longer than 4 seconds
    times_ok_ind = (times>time_th)'; % col array
    rises_ok_ind = rises(1,times_ok_ind)';
    falls_ok_ind = falls(1,times_ok_ind)';
    times = (times(times_ok_ind)');
    
    cAnglesVector = NaN(size(times));
    for j = 1:numel(times)
        % getting current rise and fall indexes
        cRise = rises_ok_ind(j,1);
        cFall = falls_ok_ind(j,1);
        
        % getting current angle as the mean in this period
        % getting also current period duration
        cAnglesVector(j) = mean(jointAnglesNoJump{i}(cRise:cFall));
    end
    
    AnglesStatics.(acquisitions{i}) = cAnglesVector;
end

%% CREATE VECTOR OF GOLD STANDARD ANGLES (KINOVEA)
AnglesGS.(acquisitions{1}) = [114; 99; 40; 114; 40; 99; 40; 114; 40; 99; 40; 114; 40; 114; 40; 40; 114; 40; 40; 114];
AnglesGS.(acquisitions{2}) = [32; 103; 130; 103; 32; 103; 130; 103; 32; 103; 130; 103; 32; 103; 130; 103; 32; 103; 130; 103; 32; 103; 130; 103; 32];
AnglesGS.(acquisitions{3}) = [41; 79; 41; 85; 41; 79; 41; 85; 41; 79; 41; 85; 41; 41; 85; 41; 79; 41; 85; 41];
AnglesGS.(acquisitions{4}) = [37; 72; 109; 72; 37; 72; 109; 72; 37; 72; 109; 109; 72; 109; 72; 37; 72; 109; 72; 37];
AnglesGS.(acquisitions{5}) = [46; 75; 46; 87; 46; 75; 46; 87; 46; 75; 46; 87; 46; 75; 46; 87; 46; 75; 46; 87; 46; 75];
AnglesGS.(acquisitions{6}) = [25; 72; 105; 72; 25; 72; 105; 72; 25; 72; 105; 72; 25; 72; 105; 72; 25; 72; 105; 72; 25; 72; 105];

%% BLAND ALTMAN
% Piano sagittale
titolo='Sagittale';
Vett1=[AnglesStatics.(acquisitions{1}); AnglesStatics.(acquisitions{3}); AnglesStatics.(acquisitions{5})];
Vett2=[AnglesGS.(acquisitions{1}); AnglesGS.(acquisitions{3}); AnglesGS.(acquisitions{5})];
BlandAltman(Vett1,Vett2,titolo)

% Piano Frontale
titolo='Frontale';
Vett1=[AnglesStatics.(acquisitions{2}); AnglesStatics.(acquisitions{4}); AnglesStatics.(acquisitions{6})];
Vett2=[AnglesGS.(acquisitions{2}); AnglesGS.(acquisitions{4}); AnglesGS.(acquisitions{6})];
BlandAltman(Vett1,Vett2,titolo)

% Complessivo
titolo='Complessivo';
Vett1=[AnglesStatics.(acquisitions{1}); AnglesStatics.(acquisitions{2}); AnglesStatics.(acquisitions{3}); AnglesStatics.(acquisitions{4}); AnglesStatics.(acquisitions{5}); AnglesStatics.(acquisitions{6})];
Vett2=[AnglesGS.(acquisitions{1}); AnglesGS.(acquisitions{2}); AnglesGS.(acquisitions{3}); AnglesGS.(acquisitions{4}); AnglesGS.(acquisitions{5}); AnglesGS.(acquisitions{6})];
BlandAltman(Vett1,Vett2,titolo)