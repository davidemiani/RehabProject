pulisci

datadir = fullfile(pwd,'2017-12-05_obj');
touch(datadir)
[files,paths] = files2cell(fullfile(pwd,'2017-12-05'));

for i = 1:numel(paths)
    fprintf('Verting file #%d\n',i)
    load(paths{i,1})
    temp = strsplit(files{i,1},'_');
    Subject = temp{1,3}(1:4);
    TestName = temp{1,2}(2);
    GoldStandard = temp{1,1};
    
    switch Subject
        case {'MC94','DM94'}
            ExelName = 'EXLs3_0067';
        otherwise
            ExelName = 'EXLs3_0070';
    end
    
    obj = Exel(ExelName,'Subject',Subject,'Segment','Homer','AutoStop',10);
    obj.UserData.TestName = TestName;
    obj.UserData.GoldStandard = GoldStandard;
    
    obj.ExelData = array2table(zeros(size(dataHum,1),16), ...
        'VariableNames', ...
        {'ProgrNum','PacketType', ...
        'AccX','AccY','AccZ', ...
        'GyrX','GyrY','GyrZ', ...
        'MagX','MagY','MagZ', ...
        'Q0','Q1','Q2','Q3',  ...
        'Vbat'});
    obj.ExelData.ProgrNum = dataHum(:,3);
    obj.ExelData.PacketType = dataHum(:,2);
    obj.ExelData.AccX = dataHum(:,4);
    obj.ExelData.AccY = dataHum(:,5);
    obj.ExelData.AccZ = dataHum(:,6);
    
    save(fullfile(datadir,files{i,1}),'obj')
end