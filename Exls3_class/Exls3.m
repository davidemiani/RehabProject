classdef Exls3
    %EXEL Exls3 Object Properties and Methods.
    %
    % Exls3 properties.
    %   Name                    - description.
    %   Segment                 - description.
    %   PacketType              - description.
    %   SamplingFrequency       - description.
    %   ShowLine                - description.
    %   AnimatedLineHandle      - description.
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
    %   CreateNewLine           - description.
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
    %
    % Execution:
    
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
        Name               = '';
        Segment            = '';
        PacketType         = 'A';
        SamplingFrequency  = 50;
        
        ShowLine           = true;
        AnimatedLineHandle = [];
        
        StopFcn            = [];
        StartFcn           = [];
        SamplingFcn        = [];
    end
    
    % Le proprietà a settaggio privato sono:
    %   * visualizzabili: anche dall'esterno della classe
    %   * gettabili: anche dall'esterno della classe
    %   * settabili: solo dall'interno della classe
    properties (SetAccess = private)
        ImuData            = [];
        SamplesAcquired    = 0;
        ConnectionStatus   = 'closed';
        AcquisitionStatus  = 'off';
        PacketsLostNumber  = 0;
        PacketsLostIndexes = [];
    end
    
    % Le proprietà nascoste sono:
    %   * visualizzabili: solo dall'interno della classe
    %   * gettabili: solo dall'interno della classe
    %   * settabili: solo dall'interno della classe
    properties (Hidden)
        Bluetooth = [];
        CreateNewLine = true;
        Timer = timer('StartFcn',@TimerStartFcn, ...
            'TimerFcn',@TimerTimerFcn,'StopFcn',@TimerStopFcn);
    end
    
    
    %% PUBLIC METHODS
    %%
    methods (Access = public)
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
            
            %mlock
            obj.Name = name;
            
            % validating inputs
            for i = 1:2:numel(varargin)
                if isprop(obj,varargin{i})
                    if isaProperty(obj,varargin{i},'SetAccess','public')
                        PropertyName = varargin{i};
                        PropertyValue = varargin{i+1};
                        switch PropertyName
                            case {'Name','Segment'}
                                if ischar(PropertyValue)
                                    obj.(PropertyName) = PropertyValue;
                                else
                                    error([PropertyName,' must be char'])
                                end
                            case 'ShowLine'
                                if PropertyValue == true                   %check for logical
                                    obj.ShowLine = true;
                                else
                                    obj.ShowLine = false;
                                    obj.CreateNewLine = false;
                                end
                            case 'PacketType'
                                mustBeMember(PropertyValue,{'A'})          % mancano valori
                                obj.PacketType = PropertyValue;
                            case 'SamplingFrequency'
                                mustBeNumeric(PropertyValue)
                                mustBeMember(PropertyValue,[50,100,200])   % mancano valori
                                obj.SamplingFrequency = PropertyValue;
                            case 'AnimatedLineHandle'
                                if isa(PropertyValue, ...
                                        ['matlab.graphics.', ...
                                        'animation.AnimatedLine'])
                                    obj.AnimatedLineHandle = PropertyValue;
                                    obj.ShowLine = true;
                                    obj.CreateNewLine = false;
                                else
                                    error(['Line handle must be an ', ...
                                        'AnimatedLine'])
                                end
                            case {'StopFcn','StartFcn','SamplingFcn'}
                                if isa(PropertyValue,'function_handle')
                                    obj.(PropertyName) = PropertyValue;
                                else
                                    error([PropertyName,' must be a ', ...
                                        'valid function handle'])
                                end
                        end
                    else
                        error(['You cannot set a SetAccess ', ...
                            'private property (',varargin{i},')'])
                    end
                else
                    error([varargin{i},' is not a valid property'])
                end
            end
        end
        
        function obj = imuConnect(obj)
            % qui ci va la grossa routine di connesssione nonché la
            % definizione dei parametri mancanti al timer
        end
        
        function obj = imuStart(obj)
            start(obj.Timer)
        end
        
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