pulisci
actualdir = cd;
cd(fullfile(actualdir, '2018-01-18'))

load('MM17_09.mat')

cd(actualdir)

fs = obj(1,1).SampligFrequency;
t0 = 1/fs;

Acc = 

%compute angles
angleH0 = projection(obj(1,1));
angleT = projection(obj(2,1));
h = min(numel(angleH0),numel(angleT));
angleH0 = angleH0(1:h,1);
angleT = angleT(1:h,1);
angleH = angleH0 + angleT;

der_angleH = discDerivative(angleH,t0);

figure
subplot(2,1,1), plot(angleH), title('Homer')
subplot(2,1,2), plot(der_angleH), title('Der')



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
vec(1,:) = filtfilt( Bbutter, Abutter, vec(1,:) );
vec(2,:) = filtfilt( Bbutter, Abutter, vec(2,:) );
vec(3,:) = filtfilt( Bbutter, Abutter, vec(3,:) );

end