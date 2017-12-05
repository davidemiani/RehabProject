clc, clearvars, close all

load 70_1S_Fra

a = dataHum(1,4:6)';
a_norm = a/norm(a);
ax = a_norm(1,1);
ay = a_norm(2,1);
az = a_norm(3,1);
[sx,sy,sz] = sphere;

figure, hold on, grid on
surf(sx,sy,sz,'FaceAlpha',0)
plot3(0,0,0,'ok','MarkerSize',10,'MarkerFaceColor','k')
plot3(0,-1,0,'or','MarkerSize',10,'MarkerFaceColor','k')
plot3(ax,ay,az,'ob','MarkerSize',10,'MarkerFaceColor','b')
plot3([0,0],[0,-1],[0,0],'r','LineWidth',2)
plot3([0,ax],[0,ay],[0,az],'b','LineWidth',2)
xlabel('x')
ylabel('y')
zlabel('z')

theta = 2*acosd(norm(a_norm-[0;-1;0])/2)


axis equal

return

p0 = [0,0,0];
p1 = dataHum(1,4:6);
p = [p0;p1];

figure
hold on
plot3(p(:,1),p(:,2),p(:,3))
plot3(0,0,0,'*')