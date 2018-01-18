classdef ExelCompressed
    properties (SetAccess = private)
        % sensor related
        ExelName
        
        % test related
        Segment
        Subject
        AutoStop
        StartTime
        Calibration
        
        % configuration related
        PacketName
        AccFullScale
        GyrFullScale
        SamplingFrequency
    end
    
    properties (SetAccess = public)
        ExelData
        UserData
    end
    
    methods (Access = public)
        
        function obj = ExelCompressed(ExelObj)
            narginchk(1, 1)
            nargoutchk(0,1)
            
            if ~isa(ExelObj,'Exel')
                error('ExelCompressed:invalidInputArgument', ...
                    'Input must be of class Exel.')
            end
            
            if numel(ExelObj)>1
                obj = arrayfun(@ExelCompressed,ExelObj);
                return
            end
            
            obj.ExelName = ExelObj.ExelName;
            obj.ExelData = ExelObj.ExelData;
            obj.Segment = ExelObj.Segment;
            obj.Subject = ExelObj.Subject;
            obj.AutoStop = ExelObj.AutoStop;
            obj.StartTime = ExelObj.StartTime;
            obj.Calibration = ExelObj.Calibration;
            obj.PacketName = ExelObj.PacketName;
            obj.AccFullScale = ExelObj.AccFullScale;
            obj.GyrFullScale = ExelObj.GyrFullScale;
            obj.SamplingFrequency = ExelObj.SamplingFrequency;
            obj.UserData = ExelObj.UserData;
        end
        
    end
    
end