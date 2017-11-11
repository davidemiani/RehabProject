%% mainGetDataFromEXLs3
%marta
% prima di lanciare questo script
% 1 fare il pairing dei sensori con Bluetooth di windows o chiavetta
% 2 sostituire il nome della imu
% 3 impostare il tempo di acquisizione in secondi
% 4 lanciare lo script
%cecilia
clc; close all;

tmr = timerfindall;
for i = 1 : length( tmr )
    try stop(tmr(i)); delete( tmr(i));
    catch ME, end
end

% % inserisci il numero
% u.imu.thx.COM = 'COM42';
% u.imu.hum.COM = 'COM43';

% inserisci il nome
u.imu.thx.name = 'EXLs3';
u.imu.hum.name = 'EXLs3_0067';

u.imu.thx.ID = 1;
u.imu.hum.ID = 2;

u.segments{1} = 'thx'; u.segments{2} = 'hum'; nIMU = 2;

% getAutoStop contiene il tempo di acquisizione in s
getAutoStop = 30;

u.numOfPacketsBuffered = 6;
% rawData packetSize = 22;
u.packetSize = 11; % for A % for AGMB 25
u.serialBufSize = u.numOfPacketsBuffered * u.packetSize;

u.SF = 50;
u.channels = 7;

u.data = [];
u.allFrameRetrieved = NaN(getAutoStop * u.SF, 1);
u.s185 = zeros( 1, 2 );
u.frameRetrieved = NaN( u.numOfPacketsBuffered, 1 );
u.imuData = NaN(getAutoStop * u.SF, u.channels );
u.iii = 1; u.k = 0;
u.sag = []; u.sagAcos= []; u.front = []; u.frontAcos = [];

f = figure; % ( 'Renderer', 'zbuffer', 'RendererMode', 'manual')

% subplot(4,1,1), p(1) = plot([0 0],'EraseMode', 'none'); axis([0 100*20 -50 200]); set( gca , 'XGrid', 'on', 'YGrid', 'on', 'ALimMode', 'manual', 'XLimMode', 'manual' , 'YLimMode', 'manual' ,'ZLimMode', 'manual', 'SortMethod', 'childorder' ); %, 'XTickLabel', '', 'XTickLabelMode', 'manual', 'YTickLabelMode', 'manual', 'XTickMode', 'manual', 'YTickMode', 'manual',
% subplot(4,1,2), p(2) = plot([0 0],'EraseMode', 'none'); axis([0 100*20 -50 200]); set( gca , 'XGrid', 'on', 'YGrid', 'on', 'ALimMode', 'manual', 'XLimMode', 'manual' , 'YLimMode', 'manual' ,'ZLimMode', 'manual', 'SortMethod', 'childorder' ); % , 'XTickLabel', '', 'XTickLabelMode', 'manual', 'YTickLabelMode', 'manual', 'XTickMode', 'manual', 'YTickMode', 'manual',
% subplot(4,1,3), p(3) = plot([0 0],'EraseMode', 'none'); axis([0 100*20 -50 200]); set( gca , 'XGrid', 'on', 'YGrid', 'on', 'ALimMode', 'manual', 'XLimMode', 'manual' , 'YLimMode', 'manual' ,'ZLimMode', 'manual', 'SortMethod', 'childorder' ); % , 'XTickLabel', '', 'XTickLabelMode', 'manual', 'YTickLabelMode', 'manual', 'XTickMode', 'manual', 'YTickMode', 'manual',
% subplot(4,1,4), p(4) = plot([0 0],'EraseMode', 'none'); axis([0 100*20 -50 200]); set( gca , 'XGrid', 'on', 'YGrid', 'on', 'ALimMode', 'manual', 'XLimMode', 'manual' , 'YLimMode', 'manual' ,'ZLimMode', 'manual', 'SortMethod', 'childorder' ); % , 'XTickLabel', '', 'XTickLabelMode', 'manual', 'YTickLabelMode', 'manual', 'XTickMode', 'manual', 'YTickMode', 'manual',
% legend('atan','acos','Location','Best');
subplot(4,1,1), u.p(1) = animatedline(gca); u.p(2) = animatedline(gca, 'Color', 'b'); axis([0 u.SF*20 -50 200]); title(gca,'Trunk Sagittal'); set( gca , 'XGrid', 'on', 'YGrid', 'on', 'ALimMode', 'manual', 'XLimMode', 'manual' , 'YLimMode', 'manual' ,'ZLimMode', 'manual', 'SortMethod', 'childorder' ); %, 'XTickLabel', '', 'XTickLabelMode', 'manual', 'YTickLabelMode', 'manual', 'XTickMode', 'manual', 'YTickMode', 'manual',

subplot(4,1,2), u.p(3) = animatedline(gca); u.p(4) = animatedline(gca, 'Color', 'b'); axis([0 u.SF*20 -50 200]); title(gca,'Trunk Frontal'); set( gca , 'XGrid', 'on', 'YGrid', 'on', 'ALimMode', 'manual', 'XLimMode', 'manual' , 'YLimMode', 'manual' ,'ZLimMode', 'manual', 'SortMethod', 'childorder' ); % , 'XTickLabel', '', 'XTickLabelMode', 'manual', 'YTickLabelMode', 'manual', 'XTickMode', 'manual', 'YTickMode', 'manual',

subplot(4,1,3), u.p(5) = animatedline(gca); u.p(6) = animatedline(gca, 'Color', 'b'); axis([0 u.SF*20 -50 200]); title(gca,'Humerus Frontal'); set( gca , 'XGrid', 'on', 'YGrid', 'on', 'ALimMode', 'manual', 'XLimMode', 'manual' , 'YLimMode', 'manual' ,'ZLimMode', 'manual', 'SortMethod', 'childorder' ); % , 'XTickLabel', '', 'XTickLabelMode', 'manual', 'YTickLabelMode', 'manual', 'XTickMode', 'manual', 'YTickMode', 'manual',

subplot(4,1,4), u.p(7) = animatedline(gca); u.p(8) = animatedline(gca, 'Color', 'b'); axis([0 u.SF*20 -50 200]); title(gca,'Humerus Sagittal'); set( gca , 'XGrid', 'on', 'YGrid', 'on', 'ALimMode', 'manual', 'XLimMode', 'manual' , 'YLimMode', 'manual' ,'ZLimMode', 'manual', 'SortMethod', 'childorder' ); % , 'XTickLabel', '', 'XTickLabelMode', 'manual', 'YTickLabelMode', 'manual', 'XTickMode', 'manual', 'YTickMode', 'manual',

%% startConnection -- Opening imusCOM' com ports

if ~isfield( u, 'h' ) || ( ~strcmp( get( u.h.s(1), 'status' ), 'open' ) && ~strcmp( get( u.h.s(2), 'status' ), 'open' ))
    fprintf( '\n Opening Bluetooth communication \n' );
    
    ok = zeros( 1, nIMU ); u.h = [];
    for i = 1 : nIMU
        
        [ok(i), u.h] = handleBluetooth( u.imu.( u.segments{ i } ).name, u.serialBufSize, i, -1, u.h );
    end
    
    if ~isempty( find( ok==0, 1 ))
        uiwait( msgbox( {'Please check bluetooth and sensors connection, ports could not be opened'}, 'Error', 'error', 'modal'));
        return
    end
end

period = 1 / ( u.SF / u.numOfPacketsBuffered ) / 1.5; u.tasktoexecute = ceil(getAutoStop * u.SF/ u.numOfPacketsBuffered);
tmr1 = timer('Name','getData', 'Period',period, 'StartDelay',.001,'TasksToExecute',inf,'ExecutionMode','fixedRate','UserData', u ); % (getAutoStop * u.SF)/ u.numOfPacketsBuffered
tmr2 = timer('Name','getData', 'Period',period, 'StartDelay',.001,'TasksToExecute',inf,'ExecutionMode','fixedRate','UserData', u ); % (getAutoStop * u.SF)/ u.numOfPacketsBuffered

tmr1.StopFcn = {@stopRecording, 1};
tmr2.StopFcn = {@stopRecording, 2};

tmr1.TimerFcn = {@handleData, 1};
tmr2.TimerFcn = {@handleData, 2};

s_bytes = NaN(1,2);
ok = zeros( nIMU, 1 ); ii = 0;

try
    
    %% get First Frame
    while ii < 3
        if ~ok(1)
            [ok(1), u.h] = handleBluetooth( u.imu.( u.segments{1} ).name, u.serialBufSize, 1, 1, u.h );
        end
        if ~ok(2)
            [ok(2), u.h] = handleBluetooth( u.imu.( u.segments{2} ).name, u.serialBufSize, 2, 1, u.h );
        end
        ii = ii + 1;
    end
    u.startTime = datevec( now );
    u.onLineTime = datevec( now );
    flushinput( u.h.s( 1 ));flushinput( u.h.s( 2 ));
    flushinput( u.h.s( 2 ));flushinput( u.h.s( 1 ));
    set( tmr1, 'UserData', u ); set( tmr2, 'UserData', u );
    
    % profile on
    start( tmr1 );
    start( tmr2 )
    
catch ME
    disp(ME)
    stop(tmr1); stop(tmr2);
    for i = 1 : nIMU
        [ok( i ), u.h] = handleBluetooth( u.imu.(u.segments{i}).name, u.serialBufSize, i, 0, u.h );
    end
    return;
end

waitfor( f, 'Name' );

% postProcessing
dataThx = get( tmr1, 'UserData' ); dataThx = dataThx.imuData; dataThx( isnan( dataThx(:,1)), :) = [];
dataHum = get( tmr2, 'UserData' ); dataHum = dataHum.imuData; dataHum( isnan( dataHum(:,1)), :) = [];

% filling NaN
dataThx( isnan( dataThx( :,4 )), 4 ) =  dataThx( find( isnan( dataThx( :,4 ))) - 1, 4 );
dataThx( isnan( dataThx( :,5 )), 5 ) =  dataThx( find( isnan( dataThx( :,5 ))) - 1, 5 );
dataThx( isnan( dataThx( :,6 )), 6 ) =  dataThx( find( isnan( dataThx( :,6 ))) - 1, 6 );

dataHum( isnan( dataHum( :,4 )), 4 ) =  dataHum( find( isnan( dataHum( :,4 ))) - 1, 4 );
dataHum( isnan( dataHum( :,5 )), 5 ) =  dataHum( find( isnan( dataHum( :,5 ))) - 1, 5 );
dataHum( isnan( dataHum( :,6 )), 6 ) =  dataHum( find( isnan( dataHum( :,6 ))) - 1, 6 );

% filter signal
dataThx( :,4:6 ) = filterAcc( dataThx( :,4:6 )', 50, 'off')';
dataHum( :,4:6 ) = filterAcc( dataHum( :,4:6 )', 50, 'off')';

% align signals
thxMissSamp = find( diff( dataThx( :,3)) > 1 ); thxMissSampL = dataThx( thxMissSamp + 1, 3 ) - dataThx( thxMissSamp, 3 ) - 1;
for i = 1 : length( thxMissSamp ), dataThx = [dataThx( 1:thxMissSamp( i ), : ); NaN( thxMissSampL(i), size( dataThx, 2 )); dataThx( thxMissSamp( i )+1:end, : )]; end

humMissSamp = find( diff( dataHum( :,3)) > 1 ); humMissSampL = dataThx( humMissSamp + 1, 3 ) - dataThx( humMissSamp, 3 ) - 1;
for i = 1 : length( humMissSamp ), dataHum = [dataHum( 1:humMissSamp( i ), : ); NaN( humMissSampL(i), size( dataHum, 2 )); dataHum( humMissSamp( i )+1:end, : )]; end

len = min( size( dataThx, 1 ), size( dataHum, 1 )); dataThx = dataThx( 1:len,: ); dataHum = dataHum( 1:len,: );

thxSag =  atan2d( - dataThx( :, 6 ), dataThx( :, 5 ))';
thxSagAcos = real( acosd( round( dataThx( :, 6 ) .* 2 / 2^15, 1)))'-90;

thxFront = atan2d( dataThx( :, 4 ), dataThx( :, 5 ))';
thxFrontAcos = real( acosd( round( - dataThx( :, 4 ).* 2 / 2^15, 1)))'-90;

humFront = atan2d( dataHum( :, 6 ), dataHum( :, 5 ))';
humFrontAcos = real( acosd( round( - dataHum( :, 6 ).* 2 / 2^15, 1)))'-90;%

humSag =  atan2d( dataHum( :, 4 ), dataHum( :, 5 ))';
humSagAcos = real(acosd( round( - dataHum( :, 4 ) .* 2 / 2^15, 1)))'-90;

figure;
subplot(3,1,1), plot( dataThx(:,5:7).* 2 / 2^15); hold on; plot( dataHum(:,5:7).* 2 / 2^15); title('Thx and Hum Accelerations [g]'); legend('T ML','T V','T AP','H AP','H V','H ML'); grid on

subplot(3,1,2), plot( thxSag ), hold on, plot( thxSagAcos );  plot( thxFront ),plot( thxFrontAcos ); title('Trunk'); legend('Sag atan','Sag acos','Front atan','Front acos'); grid on % legend('atan [°]','acos [°]'); 

subplot(3,1,3), plot( humFront ), hold on, plot( humFrontAcos ), plot( humSag ) ,plot( humSagAcos ); title('Humerus'); legend('Frontal atan','Frontal acos','Sagit atan','Sagit acos'); grid on

figure,
subplot(2,1,1), plot( humFront - thxFront, 'k' ),hold on, plot(humFrontAcos - thxFrontAcos, 'b'), legend('atan [°]','acos [°]'), title( 'Frontal Difference' ); grid on
subplot(2,1,2), plot( humSag - thxSag, 'k' ), hold on, plot(humSagAcos - thxSagAcos, 'b'), legend('atan [°]','acos [°]'), title( 'Sagittal Difference' ); grid on

diffSag = humSagAcos - thxSagAcos;
diffFront = humFrontAcos - thxFrontAcos;

sag = [ sum( diffSag > 90 )+1, sum( diffSag > 60 ) - sum( diffSag > 90 )+1, sum( diffSag > 20 ) - sum( diffSag > 60 )+1, sum( diffSag > -5 ) - sum( diffSag > 20 )+1, sum( diffSag < -5 )+1 ];
front = [ sum( diffFront > 90 )+1, sum( diffFront > 60 ) - sum( diffFront > 90 )+1, sum( diffFront > 20 ) - sum( diffFront > 60 )+1, sum( diffFront > -5 ) - sum( diffFront > 20 )+1, sum( diffFront < -5 )+1 ];
mymap = [1 0 0; 1 .4 .4; .6 1 .3; .1 1 .1; 1 1 1];

figure, colormap(mymap)
subplot(1,2,1),
pie( sag./(numel( diffSag )+5), [1 1 0 0 0] )
legend( '>90' ,'60-90', '20-60', '0-20', '<0', 'Location', 'Best' ),  title( {'Sagittal';''} )

subplot(1,2,2),
pie( front./(numel( diffFront )+5), [1 1 0 0 0] ), title( {'Frontal';''} )

% ISO chart
figure,
axis([0 75 0 5.5])
patch([0 20 20 0],  [0 0 5 5], [0 1 0],'EdgeColor', 'none', 'FaceAlpha', .7 )
patch([60 70 70 60],[0 0 5 5], [1 0 0],'EdgeColor', 'none', 'FaceAlpha', .9 )
patch([20 20 60 60],[3 0 0 1], [0 1 0],'EdgeColor', 'none', 'FaceAlpha', .5 )

% points
% 1 - holding posture > 4s
ii = 0;
for i = 0 : 5 : 180
    ii = ii + 1;
    idx = diffSag > i - 10 & diffSag < i + 10;
    rise = strfind([0 idx 0],[0 1]);
    fall = strfind([0 idx 0],[1 0]) - 1;
    point(ii) = sum( (fall - rise + 1) > 4 * u.SF );
end
