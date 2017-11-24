clc, timerdeleteall, close all, clearExcept obj ExelArray
test = 1;


%% 1 IMU
%%
if test == 1
    ExelName = 'EXLs3_0070';
    if ~exist('obj','var') || ~strcmp(obj.ImuName,ExelName)
        obj = Exel(ExelName,'AutoStop',300);
    end
    if strcmp(obj.ConnectionStatus,'closed')
        obj = ExelConnect(obj);
    end
    if strcmp(obj.ConnectionStatus,'open') && strcmp(obj.AcquisitionStatus,'off')
        obj = ExelStart(obj);
    end
end



%% 2 IMUS
%%
if test == 2
    % defining names
    ExelNames = {'EXLs3_0070'; 'EXLs3_0067'};
    n = numel(ExelNames);
    
    % creating figure
    TestFigure = testFigure(ExelNames);
    
    if ~exist('ExelArray','var')
        ExelArray = cellfun(@Exel,ExelNames, ...
            repmat({'UserData'},n,1), repmat({TestFigure},n,1), ...
            repmat({'SamplingFcn'},n,1), repmat({@testFunc},n,1));
    end
    
    try
        ExelArray = arrayfun(@ExelConnect,ExelArray);
        
        ExelArray(1,1).UserData.Figure.Visible = 'on';
        ExelArray(2,1).UserData.Figure.Visible = 'on';
        
        ExelArray = arrayfun(@ExelStart,ExelArray);
    catch ME
        warnaME(ME)
        ExelArray = arrayfun(@ExelStop,ExelArray);
    end
end