pulisci
load(fullfile(pwd,'2018-01-17','MM17_18.mat'))
Hacc = obj(1,1).ExelData{:,3:5}(1,:);
Tacc = obj(2,1).ExelData{:,3:5}(1,:);

figure
subplot(1,3,1), hold on
plot3([0,Hacc(1,1)],[0,Hacc(1,2)],[0,Hacc(1,3)])
plot3([0,Tacc(1,1)],[0,Tacc(1,2)],[0,Tacc(1,3)])
plot3([0,0],[0,-9.81],[0,0])
xlabel('x')
ylabel('y')
zlabel('z')
legend('Homer','Thorax','Gravity')
title('Segni come mi escono dal sensore')

subplot(1,3,2), hold on
plot3(-[0,Hacc(1,1)],-[0,Hacc(1,2)],-[0,Hacc(1,3)])
plot3(-[0,Tacc(1,1)],-[0,Tacc(1,2)],-[0,Tacc(1,3)])
plot3([0,0],[0,-9.81],[0,0])
xlabel('x')
ylabel('y')
zlabel('z')
legend('Homer','Thorax','Gravity')
title('Tutti i vettori cambiati di segno')

subplot(1,3,3), hold on
plot3([0,Hacc(1,1)],-[0,Hacc(1,2)],-[0,Hacc(1,3)])
plot3([0,Tacc(1,1)],-[0,Tacc(1,2)],-[0,Tacc(1,3)])
plot3([0,0],[0,-9.81],[0,0])
xlabel('x')
ylabel('y')
zlabel('z')
legend('Homer','Thorax','Gravity')
title('Simmetria rispetto a x')

[angle1,angle2] = newprojection(obj);
angle1 = mean(angle1)
angle2 = mean(angle2)