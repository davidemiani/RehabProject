clc, timerdeleteall, close all, clearExcept obj


%% 1 IMU
%%
if ~exist('obj','var') || ~strcmp(obj.ImuName,'EXLs3_0067')
    obj = Exel('EXLs3_0067','FigureVisible','off');
end
if strcmp(obj.ConnectionStatus,'closed')
    obj = ExelConnect(obj);
end
if strcmp(obj.ConnectionStatus,'open') && strcmp(obj.AcquisitionStatus,'off')
    obj = ExelStart(obj);
end

return
%% 2 IMUS
%%
ImuNames = {'EXLs3';'EXLs3_0067'};
ImuHandles = cell(size(ImuNames));
for i = 1:numel(ImuNames)
    fprintf('IMU #%d (%s) - CREATING EXEL OBJECT\n',i,ImuNames{i,1})
    ImuHandles{i,1} = Exel(ImuNames{i,1},'FigureVisible','off');

    fprintf('IMU #%d (%s) - CONNECTING VIA BLUETOOTH\n',i,ImuNames{i,1})
    ImuHandles{i,1} = ExelConnect(ImuHandles{i,1});
    
    
end


