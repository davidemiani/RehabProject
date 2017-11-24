classdef Exel < handle
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
    % Le proprietà a settaggio pubblico sono:
    %   * visualizzabili: anche dall'esterno della classe
    %   * gettabili: anche dall'esterno della classe
    %   * settabili: anche dall'esterno della classe
    properties (SetAccess = public)
        ImuVars = {'ProgrNum','PacketType', ...
            'AccX','AccY','AccZ', ...
            'GyrX','GyrY','GyrZ', ...
            'MagX','MagY','MagZ', ...
            'Q0','Q1','Q2','Q3',  ...
            'Vbat'};
        ImuData = cell2table(cell(0,16),'VariableNames', ...
            {'ProgrNum','PacketType', ...
            'AccX','AccY','AccZ', ...
            'GyrX','GyrY','GyrZ', ...
            'MagX','MagY','MagZ', ...
            'Q0','Q1','Q2','Q3',  ...
            'Vbat'});
        UserData = [];
        InternalFigure = [];
    end
    
    % Le proprietà a settaggio privato sono:
    %   * visualizzabili: anche dall'esterno della classe
    %   * gettabili: anche dall'esterno della classe
    %   * settabili: solo dall'interno della classe
    properties (SetAccess = private)
        % modificabili solo nel creare l'oggetto
        ImuName           = '';
        Segment           = '';
        
        AutoStop          = 30;
        PacketName        = 'A';
        AccFullScale      = 2;
        GyrFullScale      = 250;
        SamplingFrequency = 50;
        
        SamplingFcn       = [];
        
        % immodificabili
        Timer
        StartTime         = [];
        LastSampleTime    = [];
        PacketsRetrived   = 0;
        ConnectionStatus  = 'closed';
        AcquisitionStatus = 'off';
    end
    
    % Le proprietà nascoste sono:
    %   * visualizzabili: solo dall'interno della classe
    %   * gettabili: solo dall'interno della classe
    %   * settabili: solo dall'interno della classe
    properties (Hidden)
        % Parameters
        Ka = 2 * 9.807 / 32768;
        Kg = 250 / 32768;
        Km = 0.007629;
        qn = 1 / 16384;
        
        % PacketInfo
        HeaderByte
        PacketsBuffered
        PacketType
        PacketHead
        PacketComm
        PacketSize
        BufferSize
        DataNumber
        ByteGroups
        ByteTypes
        DataNames
        Multiplier
        
        Displacement = 0;
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
            %    E = EXEL(IMUNAME) constructs an EXEL object for the
            %    sensor named IMUNAME with default attributes.
            %
            %    E = EXEL(IMUNAME,'PropertyName1',PropertyValue1, ...
            %        'PropertyName2',PropertyValue2,...)
            %    constructs an EXEL object in which the given
            %    PropertyName/PropertyValue pairs are set on the object.
            %
            %    See also EXELCONNECT, EXELSTART, EXELSTOP
            
            % mlock
            obj.ImuName = ImuName;
            obj.InternalFigure.Presence = true;
            
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
                            
                        case {'PacketName','Packetname','packetname'}
                            % validating PacketName
                            mustBeMember(PropertyValue,{'A'})              % mancano valori
                            obj.PacketName = PropertyValue;
                            
                        case {'SamplingFrequency','Samplingfrequency','samplingfrequency','sf','fs'}
                            % validating SamplingFrequency
                            mustBeNumeric(PropertyValue)
                            mustBeMember(PropertyValue,[50,100,200])       % mancano valori
                            obj.SamplingFrequency = PropertyValue;
                            
                        case {'UserData','Userdata','userdata'}
                            % validating FigureHandle
                            obj.UserData = PropertyValue;
                            obj.InternalFigure.Presence = false;
                            
                        case {'SamplingFcn','samplingFcn','samplingfcn'}
                            % validating Stop, Start & Sampling Fcn
                            if isa(PropertyValue,'function_handle')
                                obj.SamplingFcn = PropertyValue;
                            else
                                error('SamplingFcn must be a valid function handle')
                            end
                        otherwise
                            error(['You cannot set the private property ',PropertyName])
                    end
                else
                    % The user inputed a not valid property
                    error([varargin{i},' is not a valid property'])
                end
            end
            
            % setting Packet Properties
            obj.HeaderByte = hex2dec('20');
            obj.PacketsBuffered = 6;
            switch obj.PacketName
                case 'A'
                    obj.PacketType = hex2dec('81');
                    obj.PacketHead = [obj.HeaderByte, obj.PacketType];
                    obj.PacketComm = [hex2dec('64'),hex2dec('01'), ...
                        hex2dec('38'),hex2dec('00'),obj.PacketType];
                    obj.PacketComm = [obj.PacketComm,mod(sum(obj.PacketComm),256)];
                    
                    obj.PacketSize = 11;
                    obj.BufferSize = obj.PacketsBuffered * obj.PacketSize;
                    
                    obj.DataNumber = 7;
                    obj.ByteGroups = {0;1;[2;3];[4;5];[6;7];[8;9];10};
                    obj.ByteTypes = {'uint8';'uint8';'uint16';'int16';'int16';'int16';'uint8'};
                    obj.DataNames = {'PacketHeader','PacketType','ProgrNum','AccX','AccY','AccZ','CheckSum'};
                    obj.Multiplier = [1;1;1;obj.Ka;obj.Ka;obj.Ka;1];
                otherwise
                    error([obj.PacketName,' packet type still not supported.'])
            end
        end
        
        
        %% EXELCONNECT
        %%
        function obj = ExelConnect(obj)
            % printing
            fprintf('--- CONNECTING IMU %s ---\n',obj.ImuName)
            
            % checking if the port has to be opened for the first time
            if isempty(obj.BluetoothHandle)
                obj.BluetoothHandle = Bluetooth(obj.ImuName,1);
                obj.BluetoothHandle.InputBufferSize = obj.BufferSize;
            end
            
            % once the Bluetooth object is created, we have to open the
            % comunication, thanks to a simple use of fopen
            nAttempts = 0;
            while strcmp(obj.BluetoothHandle.status,'closed') && nAttempts < 3
                try
                    fopen(obj.BluetoothHandle); %opens the serial port
                    pause(1), obj.ConnectionStatus = 'open';
                    fprintf('    Connected\n')
                catch ME
                    nAttempts = nAttempts + 1;
                    fprintf('    ATTEMPT #%d FAILED: %s\n',nAttempts,ME.message)
                    pause(0.5)
                end
            end
            
            % we have to say the sensor what packet type it has to send us
            parSetted = 0;
            nAttempts = 0;
            while ~parSetted && nAttempts < 3
                try
                    % sending packet type code
                    fwrite(obj.BluetoothHandle,uint8(obj.PacketComm))
                    pause(1)
                    if obj.BluetoothHandle.BytesAvailable
                        acknowledgement = fread(obj.BluetoothHandle,1);
                        if acknowledgement==1
                            parSetted = 1;
                            fprintf('    PacketType Sended\n')
                        else
                            error('PacketType not succesfully received')
                        end
                    else
                        error('Acknoledge byte not received')
                    end
                    fprintf('    SUCCESS!! :-)\n\n')
                catch ME
                    nAttempts = nAttempts + 1;
                    fprintf('    ATTEMPT #%d FAILED: %s\n',nAttempts,ME.message)
                    pause(0.5)
                end
            end
        end
        
        
        %% EXELSTART
        %%
        function obj = ExelStart(obj)
            % printing
            fprintf('--- STARTING IMU %s ---\n',obj.ImuName)
            
            % starting data streaming
            nAttempts = 0;
            while strcmp(obj.AcquisitionStatus,'off') && nAttempts < 3
                try
                    % starting data streaming: we have to write 0x3D (61)
                    fwrite(obj.BluetoothHandle,char(hex2dec('3D')))
                    pause(1)
                    if not(obj.BluetoothHandle.BytesAvailable)
                        error('Comunication not started yet')
                    end
                    obj.AcquisitionStatus = 'on';
                    fprintf('    Acquisition Started!! :-D\n\n')
                catch ME
                    nAttempts = nAttempts + 1;
                    fprintf('    ATTEMPT #%d FAILED: %s\n',nAttempts,ME.message)
                    pause(0.5)
                end
            end
            
            try
                % if data streaming started, starting timer for this sensor
                if strcmp(obj.AcquisitionStatus,'on')
                    % creating Timer obj
                    obj.Timer = timer();
                    obj.Timer.Period = (obj.PacketsBuffered) / (1.5 * obj.SamplingFrequency);
                    obj.Timer.StartDelay = 0.001;
                    obj.Timer.TasksToExecute = ceil((obj.AutoStop * obj.SamplingFrequency) / (obj.PacketsBuffered));
                    obj.Timer.ExecutionMode = 'fixedRate';
                    obj.Timer.StartFcn = {@obj.InternalStartFcn};
                    obj.Timer.TimerFcn = {@obj.InternalTimerFcn};
                    obj.Timer.StopFcn  = {@obj.InternalStopFcn};
                    
                    % starting the timer
                    start(obj.Timer)
                end
            catch
                obj = ExelStop(obj);
            end
        end
        
        
        %% EXELSTOP
        %%
        function obj = ExelStop(obj)
            % stopping timer, if necessary
            if ~isempty(obj.Timer) && strcmp(obj.Timer.Running,'on')
                stop(obj.Timer)
                delete(obj.Timer)
            end
            
            % stopping data streaming
            nAttempts = 0;
            while strcmp(obj.ConnectionStatus,'open') && nAttempts < 3
                try
                    % stop printing
                    fprintf('--- STOPPING IMU %s ---\n',obj.ImuName)
                    
                    % to tell the IMU to stop sending, we have to write 0x3A
                    fwrite(obj.BluetoothHandle,char(hex2dec('3A')))
                    pause(0.5), flushinput(obj.BluetoothHandle)
                    obj.AcquisitionStatus = 'off';
                    fprintf('    Stopped!! ;-)\n\n')
                    
                    % disconnection printing
                    fprintf('--- DISCONNECTING IMU %s ---\n',obj.ImuName)
                    
                    % closing communication
                    fclose(obj.BluetoothHandle); pause(0.2)
                    obj.ConnectionStatus = 'closed';
                    fprintf('    Disconnected!! :-O\n\n')
                catch ME
                    nAttempts = nAttempts + 1;
                    fprintf('    ATTEMPT #%d FAILED: %s\n',nAttempts,ME.message)
                    pause(0.5)
                end
            end
        end
        
        function obj = ExelClean(obj)
            obj.ImuData = cell2table(cell(0,16),'VariableNames',obj.ImuVars);
        end
    end
    
    
    methods (Access = private)
        %% INTERNALSTARTFCN
        %%
        function InternalStartFcn(obj,~,~)
            % setting figure visible
            if obj.InternalFigure.Presence
                obj = InternalDefaultFigure(obj);
            end
            
            % cleaning up input com
            flushinput(obj.BluetoothHandle)
            
            % setting StartTime
            obj.StartTime = datetime('now');
            obj.LastSampleTime = datetime('now'); % even if not a sample
        end
        
        
        %% INTERNALTIMERFCN
        %%
        function InternalTimerFcn(obj,~,~)
            try
                % correcting displacement
                if obj.Displacement > 0
                    fread(obj.BluetoothHandle,obj.Displacement);
                    obj.Displacement = 0;
                    fprintf('*** SYNC CORRECTED (IMU %s) ***\n',obj.ImuName)
                end
                
                % getting data if full buffer
                if obj.BluetoothHandle.BytesAvailable >= obj.BufferSize
                    % getting data
                    rawData = fread(obj.BluetoothHandle);
                    
                    % recording time
                    obj.LastSampleTime = datetime('now');
                    
                    % finding new pkt starts indexes
                    pktStartIndexes = strfind(rawData',obj.PacketHead)';
                    
                    % getting pkt lengths
                    PktLength = [diff(pktStartIndexes); obj.BufferSize-pktStartIndexes(end,1)+1];
                    
                    % filtering only full packets
                    pktStartIndexes = pktStartIndexes(PktLength == obj.PacketSize);
                    
                    % computing PacketsRetrived and Displacement for next steps
                    obj.PacketsRetrived = numel(pktStartIndexes);
                    obj.Displacement = pktStartIndexes(1) - 1;
                    
                    % getting current row in ImuData
                    cRow = height(obj.ImuData);
                    
                    % adding new rows on ImuData
                    obj.ImuData = [obj.ImuData; ...
                        array2table(zeros(obj.PacketsRetrived,numel(obj.ImuVars)), ...
                        'VariableNames',obj.ImuVars)];
                    
                    % filling new rows
                    for iPkt = 1:obj.PacketsRetrived
                        for iData = 1:numel(obj.DataNames)
                            cVar = obj.DataNames{1,iData};
                            if ismember(cVar,obj.ImuVars)
                                cPktIndexes = pktStartIndexes(iPkt) + obj.ByteGroups{iData,1};
                                cData = rawData(cPktIndexes,1);
                                cByteType = obj.ByteTypes{iData,1};
                                cMultiplier = obj.Multiplier(iData,1);
                                obj.ImuData.(cVar)(cRow+iPkt,1) = cMultiplier * ...
                                    double(typecast(uint8(cData),cByteType));
                            end
                        end
                    end
                elseif seconds(datetime('now')-obj.LastSampleTime) > 10
                    % generating an error, so the code continues in the
                    % catch statement, where the communication will be
                    % stopped
                    error('Last sample aquired more than 10s ago')
                end
                
                % chiamo la SamplingFcn definita dal main. La funzione DEVE
                % essere definita esternamente sia al main che alla classe
                if not(isempty(obj.SamplingFcn))
                    obj = obj.SamplingFcn(obj); %#okAGROW
                end
            catch ME
                fprintf('*** COMMUNICATION FAILED (IMU %s) ***\n\n',obj.ImuName)
                warnaME(ME)
                disp(ME.message)
                stop(obj.Timer);
            end
        end
        
        
        %% INTERNALSTOPFCN
        %%
        function InternalStopFcn(obj,~,~)
            % stopping data stream. This method is necessary since we have
            % an autostopped timer. When it stops, automatically it has to
            % call the ExelStop method.
            ExelStop(obj);
        end
        
        
        %% INTERNALDEFAULTFIGURE
        %%
        function obj = InternalDefaultFigure(obj)
            % creating figure
            Figure = figure;
            
            % defining AxesWidth (in sec)
            AxesWidth = 15;
            
            % defining var names
            VarNames = { ...
                'AccX','AccY','AccZ'; ...
                'GyrX','GyrY','GyrZ'; ...
                'MagX','MagY','MagZ'  ...
                };
            
            % defining colors and titles
            c = {'r','b','k'};
            t = {'Acc';'Gyr';'Mag'};
            u = {'Acc (m\cdot s^{-2})'; ...
                '\omega (rad\cdot s^{-1})'; ...
                'Mag Field (T)'};
            
            % defining sizes
            [nAxes,nLines] = size(VarNames);
            
            % creating Axes and Lines
            for i = 1:nAxes
                Axes(i,1) = subplot(nAxes,1,i); %#okAGROW
                Axes(i,1).XLim = [0,AxesWidth]; %#okAGROW
                Axes(i,1).FontSize = 15; %#okAGROW
                Axes(i,1).YMinorGrid = 'on'; %#okAGROW
                Axes(i,1).YMinorTick = 'on'; %#okAGROW
                for j = 1:nLines
                    Lines(i,j) = animatedline(Axes(i,1),'Color',c{1,j}); %#okAGROW
                end
                title(t{i,1})
                legend(VarNames(i,:))
                xlabel('time (s)')
                ylabel(u{i,1})
            end
            linkaxes(Axes,'x')
            
            % assigning Internal Figure fields
            obj.InternalFigure.Axes = Axes;
            obj.InternalFigure.Lines = Lines;
            obj.InternalFigure.Figure = Figure;
            obj.InternalFigure.VarNames = VarNames;
            obj.InternalFigure.AxesWidth = AxesWidth;
            obj.InternalFigure.LastFrame = 0;
            
            % setting SamplingFcn
            obj.SamplingFcn = @obj.InternalUpdateFigure;
        end
        
        
        %% INTERNALUPDATEFIGURE
        %%
        function obj = InternalUpdateFigure(obj,~,~)
            if height(obj.ImuData)-obj.InternalFigure.LastFrame >= obj.SamplingFrequency/5
                % getting dimensions
                [nAxes,nLines] = size(obj.InternalFigure.VarNames);
                
                % computing time
                time = (obj.InternalFigure.LastFrame+1:height(obj.ImuData))'/ ...
                    obj.SamplingFrequency;
                
                % setting new XLim if necessary
                if any(time > obj.InternalFigure.Axes(1,1).XLim(1,2))
                    obj.InternalFigure.Axes(1,1).XLim = ...
                            obj.InternalFigure.Axes(1,1).XLim + ...
                            obj.InternalFigure.AxesWidth;
                end
                
                for i = 1:nAxes
                    for j = 1:nLines
                        addpoints(obj.InternalFigure.Lines(i,j), ...
                            time, ...
                            obj.ImuData.(obj.InternalFigure.VarNames{i,j})( ...
                            obj.InternalFigure.LastFrame+1:end,1));
                    end
                end
                
                % showing now new values
                drawnow
                
                % updating last frame
                obj.InternalFigure.LastFrame = height(obj.ImuData);
            end
        end
    end
    
    
end

