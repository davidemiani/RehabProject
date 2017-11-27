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
    end
    
    properties (SetAccess = private)
        % settable using set
        Segment
        AutoStop = 15;
        PacketName = 'A';
        AccFullScale = 2;
        GyrFullScale = 250;
        SamplingFcn
        SamplingFrequency = 50;
        
        
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
        ExelFigure
    end
    
    properties (Hidden)
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
        ValuesRequired
        
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
            
            % validating ImuName
            if ischar(ExelName)
                obj.ExelName = ExelName;
            else
                error('ExelName must be char')
            end
            
            % validating inputs
            for i = 1:2:numel(varargin)
                % validation with set
                set(obj,varargin{i},varargin{i+1})
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
                    obj.PacketComm = [obj.PacketComm, ...
                        mod(sum(obj.PacketComm),256)];
                    
                    obj.PacketSize = 11;
                    obj.BufferSize = obj.PacketsBuffered * obj.PacketSize;
                    obj.ValuesRequired = obj.AutoStop * ...
                        obj.SamplingFrequency * obj.PacketSize;
                    
                    obj.DataNumber = 7;
                    obj.ByteGroups = {0;1;[2;3];[4;5];[6;7];[8;9];10};
                    obj.ByteTypes = {'uint8';'uint8';'uint16';'int16'; ...
                        'int16';'int16';'uint8'};
                    obj.DataNames = {'PacketHeader','PacketType', ...
                        'ProgrNum','AccX','AccY','AccZ','CheckSum'};
                    obj.Multiplier = [1;1;1;obj.Ka;obj.Ka;obj.Ka;1];
                otherwise
                    error([obj.PacketName, ...
                        ' packet type still not supported.'])
            end
            
            % creating DefaultFigure if necessary
            if strcmp(obj.ExelFigureMode,'Default')
                createInternalFigure(obj)
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
        instrcallback(obj,~,~)
        createInternalFigure(obj)
        updateInternalFigure(obj,~,~)
    end
end