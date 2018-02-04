% mainStatisticsOnObects.m


%% INIT
%%
% cleaning all
pulisci

% getting file names and paths
[~,paths] = files2cell(fullfile(csd,'2017-12-05'),'.mat');

% setting rotation and subject
rot = ["N";"I";"E"];
sbj = ["CM94","DM94","FM94","FP94","GL94","MC94"];

% setting nRows1 and nCols1
nRows1 = numel(rot);
nCols1 = numel(sbj);

% setting value names and gold standatd angles
ang = [20;30;40;50;60;70;90;120];
val = ["GoldStandard","Sagittal","Projection"];

% setting nRows2 and nCols2
nRows2 = numel(ang);
nCols2 = numel(val);

% init statistics table
tab = cell2table( ...
    repmat( ...
    {array2table(zeros(nRows2,nCols2),'VariableNames',cellstr(val))}, ...
    nRows1,nCols1 ...
    ), ...
    'RowNames',cellstr(rot),'VariableNames',cellstr(sbj));


%% COMPUTING STATISTICS TABLE
%%
for i = 1:numel(paths)
    load(paths{i,1})
    
    cSbj = obj.Subject;
    cRow1 = find(obj.UserData.Rotation == rot);
    
    cAng = str2double(obj.UserData.GoldStandard);
    cRow2 = find(cAng == ang);
    
    tab.(cSbj){cRow1,1}.GoldStandard(cRow2,1) = cAng;
    tab.(cSbj){cRow1,1}.Sagittal(cRow2,1) = ...
        abs(cAng - mean(sagittal(obj)));
    tab.(cSbj){cRow1,1}.Projection(cRow2,1) = ...
        abs(cAng - mean(projection(obj)));
end


%% PLOTTING
%%
h = figure('Position',get(0,'screensize'));
k = 1;
for i = 1:nRows1
    for j = 1:nCols1
        cSbj = sbj{1,j};
        subplot(nRows1,nCols1,k), hold on
        plot(ang,tab.(cSbj){i,1}.Sagittal,'o-','Color',[0,0.7,0.7],'LineWidth',1.5)
        plot(ang,tab.(cSbj){i,1}.Projection,'o-','Color',[0,0.7,0],'LineWidth',1.5)
        xlabel('angle (\circ)')
        ylabel('\epsilon_{abs} (\circ)')
        xticks(ang)
        title(sprintf('%s %s',cSbj,rot{i,1}))
        grid minor
        legend('sagittal','projection','location','bestoutside','orientation','horizontal')
        set(gca,'FontSize',8)
        k = k+1;
    end
end

savefig2(h,fullfile(csd,'statistics.fig'),'ScreenSize',false)
savefig2(h,fullfile(csd,'statistics.jpg'),'ScreenSize',true)

