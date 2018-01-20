function ImuData = filterImuData( ImuData, sf )
%% BANDPASS
%%
% passband edge frequency (cut off freq) in bandpass, normalized for pi.
% wp = 2 * pi * fp * Tc --> pi * fp /( fc/ 2 ) --> fp /( fc/ 2 )
Wp = 1 / ( sf/2 );


%% STOPBAND
%%
% stopband edge frequency (cut off freq) in stopband; normalized for pi.
% (fc/2.3) / ( fc/2 );
% ws = 2 * pi * fs * Tc --> pi * fs /( fc/ 2 ) --> fs /( fc/ 2 )
Ws = 0.9092;


%% GAIN
%%
% gain in Bandpass , loses no more than 1 dB in the passband equal to 10%
Gp = 1;
% gain in Stopband (has at least 10 dB of attenuation in the stopband,
% pass just more than 30%)
Gs = 100;


%% FILTER CREATION
%%
[ Nbutter, Wnbutter ] = buttord( Wp, Ws, Gp, Gs );

% A,B series of coefficients
[ Bbutter, Abutter ]= butter( Nbutter, Wnbutter );


%% FILTERING
%%
% filtering the signal, with zero-phase shifting
ImuData(:,1) = filtfilt( Bbutter, Abutter, ImuData(:,1) );
ImuData(:,2) = filtfilt( Bbutter, Abutter, ImuData(:,2) );
ImuData(:,3) = filtfilt( Bbutter, Abutter, ImuData(:,3) );


end