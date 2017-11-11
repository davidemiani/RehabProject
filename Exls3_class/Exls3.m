classdef Exls3
    %EXEL Exls3 Object Properties and Methods.
    %
    % Exls3 properties.
    %   Name                    - description.
    %   Segment                 - description.
    %   PacketType              - description.
    %   SamplingFrequency       - description.
    %   ShowFigure              - description.
    %   FigureHandle            - description.
    %   StopFcn                 - description.
    %   StartFcn                - description.
    %   SamplingFcn             - description.
    %   ImuData                 - description.
    %   AcquiringStatus         - description.
    %   SamplesAcquired         - description.
    %   ConnectionStatus        - description.
    %   PacketsLostNumber       - description.
    %   PacketsLostIndexes      - description.
    %   Timer                   - description.
    %   Bluetooth               - description.
    %
    % Exls3 methods:
    % Exls3 object construction:
    %   @Exls3/Exls3            - Construct Exls3 object.
    %
    % Getting and setting parameters:
    %   get              - Get value of Exls3 object property.
    %   set              - Set value of Exls3 object property.
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
    % Le proprietà a settaggio pubbliche sono:
    %   * visualizzabili: anche dall'esterno della classe
    %   * gettabili: anche dall'esterno della classe
    %   * settabili: anche dall'esterno della classe
    properties (SetAccess = public)
        Name              = '';
        Segment           = '';
        PacketType        = 'A';
        SamplingFrequency = 50;
        
        FigureHandle      = [];
        FigureVisible     = 'on';
        
        StopFcn           = [];
        StartFcn          = [];
        SamplingFcn       = [];
    end
    
    % Le proprietà a settaggio privato sono:
    %   * visualizzabili: anche dall'esterno della classe
    %   * gettabili: anche dall'esterno della classe
    %   * settabili: solo dall'interno della classe
    properties (SetAccess = private)
        ImuData              = [];
        SamplesAcquired      = 0;
        ConnectionStatus     = 'closed';
        AcquisitionStatus    = 'off';
        PacketsLostNumber    = 0;
        PacketsLostIndexes   = [];
        InternalFigureHandle = [];
    end
    
    % Le proprietà nascoste sono:
    %   * visualizzabili: solo dall'interno della classe
    %   * gettabili: solo dall'interno della classe
    %   * settabili: solo dall'interno della classe
    properties (Hidden)
        Bluetooth      = [];
        InternalFigure = true;
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
        
        
        %% EXLS3
        %%
        function obj = Exls3(name,varargin)
            %EXLS3 Construct EXLs3 object.
            %
            %    S = EXLS3(NAME) constructs an EXLs3 object for the sensor
            %    named NAME with default attributes.
            %
            %    S = EXLS3('PropertyName1',PropertyValue1, ...
            %        'PropertyName2',PropertyValue2,...)
            %    constructs an EXLs3 object in which the given Property
            %    name/value pairs are set on the object.
            %
            %    See also BLUETOOTH, TIMER.
            
            %mlock % i pulisci non sono in grado di pulire la classe
            obj.Name = name;
            
            % validating inputs
            for i = 1:2:numel(varargin)
                % checking for prop existency
                if isprop(obj,varargin{i})
                    % checking for public prop
                    if isaProperty(obj,varargin{i},'SetAccess','public')
                        % getting PropertyName and PropertyValue
                        PropertyName = varargin{i};
                        PropertyValue = varargin{i+1};
                        
                        % switching between cases
                        switch PropertyName
                            case {'Name','Segment'}
                                % validating Name & Segment
                                if ischar(PropertyValue)
                                    obj.(PropertyName) = PropertyValue;
                                else
                                    error([PropertyName,' must be char'])
                                end
                                
                            case 'FigureVisible'
                                % validating FigureVisible
                                if ischar(PropertyValue)
                                    if any(strcmp(PropertyValue, ...
                                            {'on','off'}))
                                        obj.FigureVisible = PropertyValue;
                                    else
                                        error(['FigureVisible Proper', ...
                                            'tyValue must be ''on'' ', ...
                                            'or ''off'''])
                                    end
                                else
                                    error(['FigureVisible PropertyVal', ...
                                        'ue must be a char'])
                                end
                                
                            case 'PacketType'
                                % validating PacketType
                                mustBeMember(PropertyValue,{'A'})          % mancano valori
                                obj.PacketType = PropertyValue;
                                
                            case 'SamplingFrequency'
                                % validating SamplingFrequency
                                mustBeNumeric(PropertyValue)
                                mustBeMember(PropertyValue,[50,100,200])   % mancano valori
                                obj.SamplingFrequency = PropertyValue;
                                
                            case 'FigureHandle'
                                % validating FigureHandle
                                if isa(PropertyValue,'matlab.ui.Figure')
                                    obj.FigureHandle = PropertyValue;
                                    obj.InternalFigure = false;
                                else
                                    error(['Line handle must be an ', ...
                                        'AnimatedLine'])
                                end
                                
                            case {'StopFcn','StartFcn','SamplingFcn'}
                                % validating Stop, Start & Sampling Fcn
                                if isa(PropertyValue,'function_handle')
                                    obj.(PropertyName) = PropertyValue;
                                else
                                    error([PropertyName,' must be a ', ...
                                        'valid function handle'])
                                end
                        end
                    else
                        % The user tried to modify a SetAccess Private prop
                        error(['You cannot set a SetAccess ', ...
                            'private property (',varargin{i},')'])
                    end
                else
                    % The user inputed a not valid property
                    error([varargin{i},' is not a valid property'])
                end
            end
            
            % If InternalFigure is true, let's create it
            if obj.InternalFigure == true
                obj.InternalFigureHandle = ...
                    figure('Visible',obj.FigureVisible);
                c = {'r','b','k'};
                t = {'Acc';'Gyr';'Mag'};
                for i = 1:3
                    ax(i) = subplot(3,1,i);
                    for j = 1:3
                        an(i,j) = animatedline(ax(i),'Color',c{1,j});
                        % other options here
                    end
                    title(t{i,1})
                end
                linkaxes(ax,'x')
            end
        end
        
        
        %% IMUCONNECT
        %%
        function obj = imuConnect(obj)
            % qui ci va la grossa routine di connesssione nonché la
            % definizione dei parametri mancanti al timer
        end
        
        
        %% IMUSTART
        %%
        function obj = imuStart(obj)
            start(obj.Timer)
        end
        
        
        %% IMUSTOP
        %%
        function obj = imuStop(obj)
            stop(obj.Timer)
        end
    end
    
    methods (Access = private)
        function TimerStartFcn(obj,event)
            % codice della funzione
            
            % chiamo la StartFcn definita dal main. La funzione DEVE essere
            % definita esternamente sia al main che alla classe
            obj.StartFcn(obj)
        end
        
        function TimerTimerFcn(obj,event)
            % codice della funzione
            
            % chiamo la SamplingFcn definita dal main. La funzione DEVE
            % essere definita esternamente sia al main che alla classe
            obj.SamplingFcn(obj)
        end
        
        function TimerStopFcn(obj,event)
            % codice della funzione
            
            % chiamo la StopFcn definita dal main. La funzione DEVE essere
            % definita esternamente sia al main che alla classe
            obj.StopFcn(obj)
        end
    end
    
end