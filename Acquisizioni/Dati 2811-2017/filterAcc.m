function gyr = filterAcc( rgyr, fc, vis )
%% # filter gyro signal - not used in rev01 not used
% fc = 100;
% passband edge frequency (cut off freq) in bandpass; normalized for pi
Wp = 1 / ( fc/2 ); % wp = 2 * pi * fp * Tc --> pi * fp /( fc/ 2 ) --> fp /( fc/ 2 )
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
gyr(1,:) = filtfilt( Bbutter, Abutter, rgyr(1,:) );
gyr(2,:) = filtfilt( Bbutter, Abutter, rgyr(2,:) );
gyr(3,:) = filtfilt( Bbutter, Abutter, rgyr(3,:) );

if strcmp(vis, 'on')
figure, plot( rgyr(1,:),'--' ), hold on, plot( gyr(1,:), 'r' )
figure('Name','filterAcc','Visible',vis),title('Filter of acc'), plot( rgyr(2,:),'--' ), hold on, plot( gyr(2,:), 'r' )
figure, plot( rgyr(3,:),'--' ), hold on, plot( gyr(3,:), 'r' )
end
end