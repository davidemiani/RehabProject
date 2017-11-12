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
        BluetoothHandle
        InternalFigureMode = true;
        InternalFigureAxes = [];
        InternalFigureLine = [];
        Timer          = timer('StartFcn',@TimerStartFcn, ...
            'TimerFcn',@TimerTimerFcn, ...
            'StopFcn', @TimerStopFcn);
    end
    
    
    %% METHODS
    %%
    % spiegazione sui metodi
    %
    %
    %
    %
    
    methods (Access = public)
        %% PUBLIC METHODS
        %%
        % spiegazione dei metodi publici
        %
        %
        %
        %
        
        
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
            
            mlock
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
            start(obj.Timer)
        end
        
        
        %% EXELSTOP
        %%
        function obj = ExelStop(obj)
            stop(obj.Timer)
        end
    end
    
    methods (Access = private)
        function TimerStartFcn(obj,~)
            % codice della funzione
            
            % chiamo la StartFcn definita dal main. La funzione DEVE essere
            % definita esternamente sia al main che alla classe
            obj.StartFcn(obj)
        end
        
        function TimerTimerFcn(obj,~)
            % codice della funzione
            
            % chiamo la SamplingFcn definita dal main. La funzione DEVE
            % essere definita esternamente sia al main che alla classe
            obj.SamplingFcn(obj)
        end
        
        function TimerStopFcn(obj,~)
            % codice della funzione
            
            % chiamo la StopFcn definita dal main. La funzione DEVE essere
            % definita esternamente sia al main che alla classe
            obj.StopFcn(obj)
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