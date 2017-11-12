classdef Exel
    %Exel Object Properties and Methods.
    %
    % Exel properties.
    %   ImuName                 - description.
    %   Segment                 - description.
    %   AutoStop                - description.
    %   PacketType              - description.
    %   SamplingFrequency       - description.
    %
    %   ShowFigure              - description.
    %   FigureHandle            - description.
    %
    %   StopFcn                 - description.
    %   StartFcn                - description.
    %   SamplingFcn             - description.
    %
    %   ImuData                 - description.
    %   SamplesAcquired         - description.
    %   ConnectionStatus        - description.
    %   AcquisitionStatus       - description.
    %   PacketsLostNumber       - description.
    %   PacketsLostIndexes      - description.
    %
    %   Timer                   - description.
    %   Bluetooth               - description.
    %   InternalFigureMode      - description.
    %   InternalFigureAxes      - description.
    %   InternalFigureLine      - description.
    %
    % Exel methods:
    % Exel object construction:
    %   Exel            - Constructs Exel object.
    %
    % Getting and setting parameters:
    %   get              - Get value of Exel object property.
    %   set              - Set value of Exel object property.
    %
    % General:
    % ... da completare
    % Execution:
    % ... da completare
    
    % ------------------------------------
    % CREDITS:     Davide Miani (nov 2017)
    % LAST REVIEW: Davide Miani (nov 2017)
    % MAIL TO:     davide.miani2@gmail.com
    % ------------------------------------
    
    
    %% PROPERTIES
    %%
    % Le proprietà a settaggio privato sono:
    %   * visualizzabili: anche dall'esterno della classe
    %   * gettabili: anche dall'esterno della classe
    %   * settabili: solo dall'interno della classe
    properties (SetAccess = private)
        % modificabili creando l'oggetto
        ImuName           = '';
        Segment           = '';
        Channel           = 1;
        AutoStop          = 30;
        PacketType        = 'A';
        PacketsBuffered    = 6;
        SamplingFrequency = 50;
        
        FigureHandle      = [];
        FigureVisible     = 'on';
        
        StopFcn           = [];
        StartFcn          = [];
        SamplingFcn       = [];
        
        % immodificabili
        ImuData              = [];
        BufferSize           = [];
        PacketSize           = [];
        SamplesAcquired      = 0;
        ConnectionStatus     = 'closed';
        AcquisitionStatus    = 'off';
        PacketsLostNumber    = 0;
        PacketsLostIndexes   = [];
    end
    
    % Le proprietà nascoste sono:
    %   * visualizzabili: solo dall'interno della classe
    %   * gettabili: solo dall'interno della classe
    %   * settabili: solo dall'interno della classe
    properties (Hidden)
        % InternalFigure
        InternalFigureMode = true;
        InternalFigureAxes = [];
        InternalFigureLine = [];
        
        % Timer and Bluetooth
        Timer
        BluetoothHandle
    end
    
    
    %% METHODS
    %%
    methods (Access = public)
        %% EXEL
        %%
        function obj = Exel(ImuName,varargin)
            %EXEL Constructs EXEL object.
            %
            %    S = EXEL(IMUNAME) constructs an EXEL object for the
            %    sensor named IMUNAME with default attributes.
            %
            %    S = EXEL(IMUNAME,'PropertyName1',PropertyValue1, ...
            %        'PropertyName2',PropertyValue2,...)
            %    constructs an EXEL object in which the given
            %    PropertyName/PropertyValue pairs are set on the object.
            %
            %    See also BLUETOOTH, TIMER.
            
            % mlock
            % setting ImuName. Could be good to have a control with the
            % instrhwinfo?
            obj.ImuName = ImuName;
            
            % validating inputs
            for i = 1:2:numel(varargin)
                % checking for prop existency
                if isprop(obj,varargin{i})
                    % getting PropertyName and PropertyValue
                    PropertyName = varargin{i};
                    PropertyValue = varargin{i+1};
                    
                    % switching between cases
                    switch PropertyName
                        case {'Segment','segment'}
                            % validating Segment
                            if ischar(PropertyValue)
                                obj.Segment = PropertyValue;
                            else
                                error('Segment must be char')
                            end
                            
                        case {'AutoStop','Autostop','autostop'}
                            % validating AutoStop
                            mustBeNumeric(PropertyValue)
                            mustBePositive(PropertyValue)
                            obj.AutoStop = PropertyValue;
                            
                        case {'PacketType','Packettype','packettype'}
                            % validating PacketType
                            mustBeMember(PropertyValue,{'A'})              % mancano valori
                            obj.PacketType = PropertyValue;
                            
                        case {'SamplingFrequency','Samplingfrequency', ...
                                'samplingfrequency','sf','fs'}
                            % validating SamplingFrequency
                            mustBeNumeric(PropertyValue)
                            mustBeMember(PropertyValue,[50,100,200])       % mancano valori
                            obj.SamplingFrequency = PropertyValue;
                            
                        case {'FigureHandle','Figurehandle','figurehandle'}
                            % validating FigureHandle
                            if isa(PropertyValue,'matlab.ui.Figure')
                                obj.FigureHandle = PropertyValue;
                                obj.InternalFigureMode = false;
                            else
                                error(['Line handle must be an ', ...
                                    'AnimatedLine'])
                            end
                            
                        case {'FigureVisible','Figurevisible', ...
                                'figurevisible'}
                            % validating FigureVisible
                            if ischar(PropertyValue)
                                if any(strcmp(PropertyValue, ...
                                        {'on','off'}))
                                    obj.FigureVisible = PropertyValue;
                                else
                                    error(['FigureVisible Property', ...
                                        'Value must be ''on'' ', ...
                                        'or ''off'''])
                                end
                            else
                                error(['FigureVisible PropertyValue', ...
                                    'must be a char'])
                            end
                            
                        case {'StopFcn','StartFcn','SamplingFcn'}
                            % validating Stop, Start & Sampling Fcn
                            if isa(PropertyValue,'function_handle')
                                obj.(PropertyName) = PropertyValue;
                            else
                                error([PropertyName,' must be a ', ...
                                    'valid function handle'])
                            end
                        otherwise
                            error(['You cannot set the private proper', ...
                                'ty ',PropertyName])
                    end
                else
                    % The user inputed a not valid property
                    error([varargin{i},' is not a valid property'])
                end
            end
            
            % setting PacketType
            switch obj.PacketType
                case 'A'
                    obj.PacketSize = 11;
                    obj.BufferSize = obj.PacketSize * obj.PacketsBuffered;
            end
            
            % if InternalFigure is necessary
            if obj.InternalFigureMode
                obj = DefaultInternalFigure(obj);
            end
        end
        
        
        %% EXELCONNECT
        %%
        function obj = ExelConnect(obj)
            % printing
            fprintf('--- CONNECTING IMU %s ---\n',obj.ImuName)
            
            % checking if the port has to be opened for the first time
            if isempty(obj.BluetoothHandle)
                obj.BluetoothHandle = Bluetooth(obj.ImuName,obj.Channel);
                obj.BluetoothHandle.InputBufferSize = obj.BufferSize;
            end
            
            % once the Bluetooth object is created, we have to open the
            % comunication, thanks to a simple use of fopen
            nAttempts = 0;
            while strcmp(obj.BluetoothHandle.status,'closed') && nAttempts < 3
                try
                    fopen(obj.BluetoothHandle); %opens the serial port
                    obj.ConnectionStatus = 'open';
                catch ME
                    nAttempts = nAttempts + 1;
                    fprintf('ATTEMPT #%d FAILED: %s\n', ...
                        nAttempts,ME.message)
                    pause(0.5)
                end
            end
        end
        
        
        %% EXELSTART
        %%
        function obj = ExelStart(obj)
            % printing
            fprintf('--- STARTING IMU %s ---\n',obj.ImuName)
            
            % calling StartFcn user defined
            if not(isempty(obj.StartFcn))
                obj.StartFcn(obj)
            end
            
            % starting data streaming
            nAttempts = 0;
            comStarted = false;
            while comStarted && nAttempts < 3
                try
                    % starting data streaming: we have to write 0x3D (61)
                    fwrite(obj.BluetoothHandle,char(hex2dec('3D')))
                    pause(0.8)
                    if not(obj.BluetoothHandle.BytesAvailable)
                        error('Comunication not started yet')
                    end
                    comStarted = true;
                catch ME
                    nAttempts = nAttempts + 1;
                    fprintf('ATTEMPT #%d FAILED: %s\n', ...
                        nAttempts,ME.message)
                    pause(0.5)
                end
            end
            
            % if data streaming started, starting timer for this sensor
            if comStarted
                % creating Timer obj
                obj.Timer = timer();
                obj.Timer.Period = ...
                    (obj.PacketsBuffered) / (1.5 * obj.SamplingFrequency);
                obj.Timer.StartDelay = 0.001;
                obj.Timer.TaskToExecute = ceil( ...
                    (obj.AutoStop * obj.SamplingFrequency) / ...
                    (obj.PacketsBuffered));
                obj.Timer.ExecutionMode = 'fixedRate';
                obj.Timer.StartFcn = {@InternalStartFcn,obj};
                obj.Timer.TimerFcn = {@InternalTimerFcn,obj};
                obj.Timer.StopFcn  = {@InternalStopFcn, obj};
                
                % starting the timer
                start(obj.Timer)
            end
        end
        
        
        %% EXELSTOP
        %%
        function obj = ExelStop(obj)
            % printing
            fprintf('--- STOPPING IMU %s ---\n',obj.ImuName)
            
            % stopping timer, if necessary
            if strcmp(obj.Timer.Running,'on')
                stop(obj.Timer)
            end
            
            % stopping data streaming
            nAttempts = 0;
            while nAttempts < 3
                try
                    % removing remaining from the com object's input buffer
                    % and setting the BytesAvailable property to 0
                    % (done by flushinput)
                    flushinput(obj.BluetoothHandle)
                    
                    % to tell the IMU to stop sending, we have to write 0x3A
                    fwrite(obj.BluetoothHandle,char(hex2dec('3A')))
                    pause(0.2)
                catch ME
                    nAttempts = nAttempts + 1;
                    fprintf('ATTEMPT #%d FAILED: %s\n', ...
                        nAttempts,ME.message)
                    pause(0.5)
                end
            end
            
            % calling StopFcn user setted
            if not(isempty(obj.StopFcn))
                obj.StopFcn(obj)
            end
        end
    end
    
    
    methods (Access = private)
        %% INTERNALSTARTFCN
        %%
        function InternalStartFcn(timerObj,~,obj)
            %% DA SISTEMARE
            %%
            try
                %get first frame
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
        end
        
        
        %% INTERNALTIMERFCN
        %%
        function InternalTimerFcn(timerObj,~,obj)
            %% DA SISTEMARE
            %%
            try
                tmr = varargin{1};
                i = varargin{3};
                u = get( tmr, 'UserData' );
                
                if  etime( datevec( now ), u.startTime ) * 100 < 100, flushinput( u.h.s( i ) ); return; end
                
                if u.k > 0
                    
                    fread( u.h.s( i ), u.k );
                    u.k = 0; disp(['synch corrected, sensor: ', num2str(i)])
                end
                
                nBytes = u.h.s( i ).BytesAvailable;
                
                if nBytes >= u.serialBufSize - 1
                    
                    u.onLineTime = datevec( now );
                    [u.data( 1 : u.numOfPacketsBuffered, 1 : u.channels ), u.k] = getDataFromIMU( u.h.s( i ), u.packetSize, u.numOfPacketsBuffered, u.channels, u.k ); % txtFiles{i}
                    [ u.allFrameRetrieved((u.iii-1) * u.numOfPacketsBuffered + ( 1 : u.numOfPacketsBuffered )), u.s185 ] = getUnwrappedFrame( u.data( :, 3 ), u.s185 );
                    u.frameRetrieved  = ( u.iii - 1 ) * u.numOfPacketsBuffered + ( 1 : u.numOfPacketsBuffered ); % sd(i).frame - startPlottingFrame(i) + 1;
                    u.imuData( u.frameRetrieved', : ) = u.data;
                    
                    if i == 1 % thx
                        u.sag = [u.sag atan2d( - u.imuData( u.frameRetrieved, 6 ),  u.imuData( u.frameRetrieved, 5 ))']; % lineHandle
                        u.sagAcos = [u.sagAcos real( acosd( round( u.imuData( u.frameRetrieved, 6 ) .* 2 / 2^15, 1)))'-90]; % lineHandle
                        
                        u.front = [u.front atan2d( - u.imuData( u.frameRetrieved, 4 ),  u.imuData( u.frameRetrieved, 5 ))']; % lineHandle
                        u.frontAcos = [u.frontAcos real(acosd( round( u.imuData( u.frameRetrieved, 4 ).* 2 / 2^15, 1)))'-90]; % lineHandle
                        
                    else % hum
                        
                        u.front = [u.front atan2d( u.imuData( u.frameRetrieved, 6 ),  u.imuData( u.frameRetrieved, 5 ))']; % lineHandle
                        u.frontAcos = [u.frontAcos real(acosd( round( - u.imuData( u.frameRetrieved, 6 ).* 2 / 2^15, 1)))'-90]; % lineHandle
                        
                        u.sag = [u.sag atan2d( u.imuData( u.frameRetrieved, 4 ),  u.imuData( u.frameRetrieved, 5 ))']; % lineHandle
                        u.sagAcos = [u.sagAcos real(acosd( round( - u.imuData( u.frameRetrieved, 4 ) .* 2 / 2^15, 1)))'-90]; % lineHandle
                    end
                    
                    plotAngle( u.sag( end - (u.numOfPacketsBuffered-1) : end), u.sagAcos( end - (u.numOfPacketsBuffered-1) : end),...
                        u.front( end - (u.numOfPacketsBuffered-1) : end), u.frontAcos( end - (u.numOfPacketsBuffered-1) : end),...
                        u.frameRetrieved', u.p, u.SF, i )
                    
                    u.iii = u.iii + 1;
                    
                    if u.iii >= u.tasktoexecute - 1
                        
                        stop(tmr)
                    end
                elseif etime( datevec( now ), u.onLineTime ) * 100 > 800
                    msgbox(['The IMU ', num2str(i),' might be disconnected, please check the sensors status and connection'],'Error connection', 'warn');
                    stop(tmr);
                    error('IMU disconnected, please check the sensors status and connection');
                end
                
                set( tmr, 'UserData', u );
            catch ME
                stop(tmr);
                disp(ME)
            end
            % chiamo la SamplingFcn definita dal main. La funzione DEVE
            % essere definita esternamente sia al main che alla classe
            if not(isempty(obj.SamplingFcn))
                obj.SamplingFcn(obj)
            end
        end
        
        
        %% INTERNALSTOPFCN
        %%
        function InternalStopFcn(~,~,obj)
            % stopping data stream. This method is necessary since we have
            % an autostopped timer. When it stops, automatically it has to
            % call the ExelStop method.
            ExelStop(obj)
        end
        
        function obj = DefaultInternalFigure(obj)
            obj.FigureHandle = figure('Visible',obj.FigureVisible);
            c = {'r','b','k'};
            t = {'Acc';'Gyr';'Mag'};
            for i = 1:3
                Axes(i,1) = subplot(3,1,i); %#okAGROW
                for j = 1:3
                    Line(i,j) = animatedline(Axes(i,1),'Color',c{1,j}); %#okAGROW
                    % other options here
                end
                title(t{i,1})
            end
            linkaxes(Axes,'x')
            obj.InternalFigureAxes = Axes;
            obj.InternalFigureLine = Line;
        end
    end
    
    
end

