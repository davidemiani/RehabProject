clc, timerdeleteall, close all, clearExcept obj ExelArray


%% 1 IMU
%%
% if ~exist('obj','var') || ~strcmp(obj.ImuName,'EXLs3_0067')
%     obj = Exel('EXLs3_0067','FigureVisible','off');
% end
% if strcmp(obj.ConnectionStatus,'closed')
%     obj = ExelConnect(obj);
% end
% if strcmp(obj.ConnectionStatus,'open') && strcmp(obj.AcquisitionStatus,'off')
%     obj = ExelStart(obj);
% end
%
% return


%% 2 IMUS
%%
% defining names
ExelNames = {'EXLs3'; 'EXLs3_0067'};
n = numel(ExelNames);

% creating figure
testFig = testFigure(ExelNames);

if ~exist('ExelArray','var')
    ExelArray = cellfun(@Exel,ExelNames, ...
        repmat({'FigureHandle'},n,1), repmat({testFig},n,1), ...
        repmat({'FigureVisible'},n,1), repmat({'off'},n,1), ...
        repmat({'SamplingFcn'},n,1), repmat({@testFunc},n,1));
end

try
    ExelArray = arrayfun(@ExelConnect,ExelArray);
    
    ExelArray(1,1).FigureHandle.Figure.Visible = 'on';
    ExelArray(2,1).FigureHandle.Figure.Visible = 'on';
    
    ExelArray = arrayfun(@ExelStart,ExelArray);
catch ME
    warnaME(ME)
    ExelArray = arrayfun(@ExelStop,ExelArray);
end
