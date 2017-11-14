pulisci

ImuNames = {'EXLs3';'EXLs3_0067'};
ImuHandles = cell(size(ImuNames));
for i = 1:numel(ImuNames)
    fprintf('IMU #%d (%s) - CREATING EXEL OBJECT\n',i,ImuNames{i,1})
    ImuHandles{i,1} = Exel(ImuNames{i,1},'FigureVisible','off');

    fprintf('IMU #%d (%s) - CONNECTING VIA BLUETOOTH\n',i,ImuNames{i,1})
    ImuHandles{i,1} = ExelConnect(ImuHandles{i,1});
    
    
end


