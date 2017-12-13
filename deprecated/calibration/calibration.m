% calibration.m


%% INIT
%%
% clearing all
pulisci
% setting ExelName
ExelName = "EXLs3_0067";
% Segment
Segment = 'Thorax';
% AutoStop
AutoStop = 15;
% file
switch Segment
    case 'Thorax'
        file = 'calThorax.mat';
    case 'Homer'
        file = 'calHomer.mat';
end
% loading calibration
if exist(file,'file')
    load(file)
else
    CalibrationTab = cell2table(cell(0,2), ...
        'VariableNames',{'ExelName','A0'});
end
% if already exist, deleting row
ind = ismember(CalibrationTab.ExelName,ExelName);
if any(ind)
    CalibrationTab(ind,:) = [];
end
    

%% ACQUISITION
%%
obj = Exel(ExelName,'AutoStop',AutoStop);
start(obj)
waitfor(obj,'AcquisitionStatus','off')


%% CREATING A0
%%
A = [obj.ExelData.AccX, ...
    obj.ExelData.AccY, ...
    obj.ExelData.AccZ];
A0 = sum(A./vecnorm(A,2,2))./height(obj.ExelData);


%% ADDING TO TABLE
%%
CalibrationTab = sortrows([CalibrationTab; table(ExelName,A0)],'ExelName');
save(file,'CalibrationTab')

