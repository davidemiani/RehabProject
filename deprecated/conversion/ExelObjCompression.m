pulisci

datapath = fullfile(pwd,'2017-12-05_compressed');
touch(datapath)
[files,paths] = files2cell(fullfile(pwd,'2017-12-05'));

for i = 1:numel(paths)
    % printing
    fprintf('Verting file #%d\n',i)
    
    % loading
    load(paths{i,1})
    
    % UserData
    UserData.Rotation = obj.UserData.TestName;
    UserData.GoldStandard = obj.UserData.GoldStandard;
    UserData.Comments = {};
    set(obj,'UserData',UserData)
    
    % Calibration
    Calibration = eye(3);
    set(obj,'Calibration',Calibration)
    
    % creating new filename
    Subject = get(obj,'Subject');
    ProgrNum = '01';
    filename = [Subject,'_',ProgrNum,'.mat'];
    while exist(fullfile(datapath,filename),'file')
        ProgrNum = num2str(str2double(ProgrNum)+1);
        if length(ProgrNum)<2
            ProgrNum = ['0',ProgrNum]; %#okAGROW
        end
        filename = [Subject,'_',ProgrNum,'.mat'];
    end
    
    % compressing Exel object in a ExelCompressed one
    obj = ExelCompressed(obj);
    
    % saving
    save(fullfile(datapath,filename),'obj')
end