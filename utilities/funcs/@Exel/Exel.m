classdef Exel < handle
    %Exel Object Properties and Methods.
    %
    % Exel properties.
    %   ExelName
    %   ExelData
    %   ExelFigure
    %
    %   Segment
    %   Subject
    %   AutoStop
    %   PacketName
    %   Calibration
    %   AccFullScale
    %   GyrFullScale
    %
    %   SamplingFcn
    %   SamplingFrequency
    %
    %   StartTime
    %   ConnectionStatus
    %   AcquisitionStatus
    %
    % Exel methods:
    % Exel object construction:
    %   @Exel/Exel       - Construct Exel object.
    %
    % Getting and setting parameters:
    %   get              - Get value of Exel object property.
    %   set              - Set value of Exel object property.
    %
    % General:
    % ...
    %
    % Execution:
    %   connect          - Open a communication with the Exel sensor.
    %   disconnect       - Close the communication with the Exel sensor.
    %   start            - Start data stream for the Exel sensor.
    %   stop             - Stop data stream for the Exel sensor.
    %
    % ------------------------------------
    % CREDITS:     Davide Miani (nov 2017)
    % LAST REVIEW: Davide Miani (dec 2017)
    % MAIL TO:     davide.miani2@gmail.com
    % ------------------------------------
    
    properties (SetAccess = public)
        UserData
        LastFrame = 0;
        ExelFigure
        ExelData = cell2table(cell(0,16),'VariableNames', ...
            {'ProgrNum','PacketType', ...
            'AccX','AccY','AccZ', ...
            'GyrX','GyrY','GyrZ', ...
            'MagX','MagY','MagZ', ...
            'Q0','Q1','Q2','Q3',  ...
            'VBat'});
    end
    
    properties (SetAccess = private)
        % settable using set (or defining the object)
        Segment
        Subject
        AutoStop
        PacketName
        Calibration
        AccFullScale
        GyrFullScale
        SamplingFcn
        SamplingFrequency
        
        % only gettable prop
        StartTime
        ConnectionStatus = 'closed';
        AcquisitionStatus = 'off';
        
        ExelName
        
    end
    
    properties (Hidden, SetAccess = private)%, GetAccess = private)
        % Parameters
        Ka = 2 / 32768;
        Kg = 250 / 32768;
        Km = 0.007629;
        Qn = 1 / 16384;
        ExelFigureMode = 'Default';
        ExelVars = {'ProgrNum','PacketType', ...
            'AccX','AccY','AccZ', ...
            'GyrX','GyrY','GyrZ', ...
            'MagX','MagY','MagZ', ...
            'Q0','Q1','Q2','Q3',  ...
            'VBat'};
        
        % Header when a new packet is received
        HeaderByte = hex2dec('20');
        
        % Packet related properties
        PacketType % i.e.: for PacketName = 'A', PacketType = 129 (0x81)
        PacketHead % i.e.: [HeaderByte, PacketType]
        PacketTypeCommand % command to send to have the desired PacketType
        
        PacketSize = 11; % (Bytes) this is true for PacketName = 'A'
        PacketsBuffered = 6; % packets have an interrupt
        BufferSize % bytes to have an interrupt(PacketsBuffered*PacketSize)
        
        DataNumber % vars in a Packets (considering double byte vars)
        ByteGroups % groupped bytes indexes
        ByteTypes % i.e. {'uint8';'uint8';'uint16'; ... for each group
        DataNames % i.e. {'PacketHeader','PacketType','ProgrNum','AccX' ...
        Multiplier % i.e. [1;1;1;Ka;Ka;Ka;1];
        
        % SamplingFrequency related properties
        % ... to be continued
        
        % AccFullScale related properties
        % ... to be continued
        
        % GyrFullScale related properties
        % ... to be continued
        
        % Number of packet retrived in an acquisition instance
        PacketsRetrived = 0;
        % If in an istanxe PacketsRetrive~=PacketsBuffered we will have
        % some displaced data
        DisplacedData = [];
        % Samples required to stop acquisition
        SamplesRequired = 0; % AutoStop * SamplingFrequency
        
        % Instrument vars
        Instrument
    end
    
    methods (Access = public)
        function obj = Exel(ExelName,varargin)
            %EXEL Construct EXEL object.
            %
            %    E = EXEL(EXELNAME) constructs an EXEL object for the
            %    sensor named EXELNAME with default attributes.
            %
            %    E = EXEL(EXELNAME,'PropertyName1',PropertyValue1, ...
            %        'PropertyName2',PropertyValue2,...)
            %    constructs an EXEL object in which the given
            %    PropertyName/PropertyValue pairs are set on the object.
            %
            %    See also CONNECT, DISCONNECT, START, STOP
            
            % validating machine
            if islinux
                error('Exel:Exel:unsupportedSystem', ...
                    'Linux OS is not yet supported')
            end
            
            % if nargin==0 preallocating, if not:
            if nargin~=0
                % validating ExelName
                mustBeCharacter(ExelName)
                ExelName = unique(string(ExelName),'stable');
                [m,n] = size(ExelName);
                obj(m,n) = Exel();
                for i = 1:m
                    for j = 1:n
                        obj(i,j).ExelName = ExelName{i,j};
                    end
                end
                
                % creating/getting Instrument
                instrtouch(obj)
                
                % setting default properties
                set(obj,'AutoStop',15)
                set(obj,'PacketName','A')
                set(obj,'SamplingFrequency',50)
                set(obj,'Calibration',eye(3))
                
                % validating inputs
                if mod(numel(varargin),2)==0
                    for i = 1:2:numel(varargin)
                        set(obj,varargin{i},varargin{i+1})
                    end
                else
                    error('Exel:notPairedInputArguments', ...
                        'Input arguments must be paired.')
                end
                
                % creating DefaultFigure if necessary
                if strcmp(obj(1,1).ExelFigureMode,'Default')
                    arrayfun(@createInternalFigure,obj)
                end
            end
        end
    end
    
    methods (Access = public)
        % get, set & reset
        PropertyValue = get(obj,PropertyName)
        set(obj,PropertyName,PropertyValue)
        reset(obj)
        
        % connection and others
        connect(obj)
        disconnect(obj)
        start(obj)
        stop(obj)
        
        % synchronization
        MissingPacketsReport = synchronize(obj,MaxforInterp,plotAcc)
    end
    
    methods (Access = private)
        % to send configuration commands
        confcommand(obj,CommandType)
        
        % callback to execute during acquisition
        instrcallback(obj,~,~)
        
        % checking existence/create instrument for communication
        instrtouch(obj)
        
        % internal figure functionalities
        createInternalFigure(obj)
        updateInternalFigure(obj,~,~)
        figCloseRequestFcn(obj,~,~)
    end
end