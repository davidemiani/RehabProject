classdef Exel < handle
    %Exel Object Properties and Methods.
    %
    % Exel properties.
    %   ExelName
    %   ExelData
    %   ExelFigure
    %
    %   Segment
    %   AutoStop
    %   PacketName
    %   AccFullScale
    %   GyrFullScale
    %
    %   SamplingFcn
    %   SamplingFrequency
    %
    %   StartTime
    %   LastSampleTime
    %   PacketsRetrived
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
    % LAST REVIEW: Davide Miani (nov 2017)
    % MAIL TO:     davide.miani2@gmail.com
    % ------------------------------------
    
    properties (SetAccess = public)
        UserData
        ExelFigure
    end
    
    properties (SetAccess = private)
        % settable using set (or defining the object)
        
        Segment
        AutoStop
        PacketName
        AccFullScale
        GyrFullScale
        SamplingFcn
        SamplingFrequency
        
        % only gettable prop
        
        StartTime
        LastSampleTime
        PacketsRetrived = 0;
        ConnectionStatus = 'closed';
        AcquisitionStatus = 'off';
        
        ExelName
        ExelData = cell2table(cell(0,16),'VariableNames', ...
            {'ProgrNum','PacketType', ...
            'AccX','AccY','AccZ', ...
            'GyrX','GyrY','GyrZ', ...
            'MagX','MagY','MagZ', ...
            'Q0','Q1','Q2','Q3',  ...
            'Vbat'});
    end
    
    properties (Hidden, SetAccess = private)%, GetAccess = private)
        % Parameters
        Ka = 2 * 9.807 / 32768;
        Kg = 250 / 32768;
        Km = 0.007629;
        qn = 1 / 16384;
        ExelFigureMode = 'Default';
        ExelVars = {'ProgrNum','PacketType', ...
            'AccX','AccY','AccZ', ...
            'GyrX','GyrY','GyrZ', ...
            'MagX','MagY','MagZ', ...
            'Q0','Q1','Q2','Q3',  ...
            'Vbat'};
        
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
        % ... ancora da fare
        
        % AccFullScale related properties
        % ... ancora da fare
        
        % GyrFullScale related properties
        % ... ancora da fare
        
        % Values Required to stop acquisition
        ValuesRequired = 0; % AutoStop * SamplingFrequency
        
        % bluetooth vars
        BluetoothObj
        DisplacedData = [];
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
            
            % if nargin==0 preallocating, if not:
            if nargin~=0
                % validating ExelName
                if ischar(ExelName) ...
                        || isstring(ExelName) || iscellstr(ExelName)
                    ExelName = lower(string(ExelName));
                    [m,n] = size(ExelName);
                    obj(m,n) = Exel();
                    for i = 1:m
                        for j = 1:n
                            obj(i,j).ExelName = ExelName{i,j};
                        end
                    end
                else
                    error('Exel:invalidExelNameDataType', ...
                        ['ExelName must be char, string ', ...
                        'or a cell array of char'])
                end
                
                % creating/getting BluetoothObj
                bluetouch(obj)
                
                % setting default properties
                set(obj,'AutoStop',15)
                set(obj,'PacketName','A')
                set(obj,'AccFullScale',2)
                set(obj,'GyrFullScale',250)
                set(obj,'SamplingFrequency',50)
                
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
        % get & set
        PropertyValue = get(obj,PropertyName)
        set(obj,PropertyName,PropertyValue)
        
        % connection and others
        connect(obj)
        disconnect(obj)
        start(obj)
        stop(obj)
    end
    
    methods (Access = private)
        bluetouch(obj)
        command(obj,CommandType)
        exelcallback(obj,~,~)
        createInternalFigure(obj)
        updateInternalFigure(obj,~,~)
        figCloseRequestFcn(obj,~,~)
    end
end