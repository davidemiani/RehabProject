pulisci
load(fullfile(pwd,'2018-01-18','MM17_05.mat'))
acc_h = obj(1,1).ExelData{1,3:5}; acc_h = acc_h./vecnorm(acc_h,2,2);
acc_t = obj(2,1).ExelData{1,3:5}; acc_t = acc_t./vecnorm(acc_t,2,2);

figure('Position',get(0,'ScreenSize'))
plotGlobalSDRandGravity()
vecplot(acc_h,'r')
vecplot(acc_t,'b')

vecangle(acc_h,[0,1,0])
vecangle(acc_t,[0,1,0])
vecangle(acc_t,acc_h)


function varargout = vecplot(vec,c)
if nargin==1
    c = [1,1,1];
end
vec = vecswitch(vec(:));
if vec(2)==0
    arrow = '>';
elseif vec(2)>0
    arrow = '^';
elseif vec(2)<0
    arrow = 'v';
end
h = plot3([0,vec(1,1)],[0,vec(2,1)],[0,vec(3,1)],'Color',c,'LineWidth',2);
hold on, plot3(vec(1,1),vec(2,1),vec(3,1),arrow, ...
    'MarkerFaceColor',c,'MarkerSize',15)
if nargout>0
    varargout{1} = h;
end
end

function plotGlobalSDRandGravity()
hold on
plot3(0,0,0,'ok','MarkerFaceColor','k','MarkerSize',15)
vecplot([1,0,0],'k')
vecplot([0,1,0],'k')
vecplot([0,0,1],'k')
vecplot([0,-1,0],'g')
xlabel('z')
ylabel('x')
zlabel('y')
set(gca,'XMinorTick','on');
set(gca,'YMinorTick','on');
set(gca,'ZMinorTick','on');
set(gca,'FontSize',20)
view([50,30]), box on
end

function R = rotmat(axis,a)
switch axis
    case 'x'
        R = [1, 0, 0; 0, cosd(a), -sind(a); 0, sind(a), cosd(a)];
    case 'y'
        R = [cosd(a), 0, sind(a); 0, 1, 0; -sind(a), 0, cosd(a)];
    case 'z'
        R = [cosd(a), -sind(a), 0; sind(a), cosd(a), 0; 0, 0, 1];
end
end

function vec = vecswitch(vec)
vec([1,2,3]) = vec([3,1,2]);
end

function angle = vecangle(v,w)
angle = acosd(dot(v,w,2)./(vecnorm(v,2,2).*vecnorm(w,2,2)));
end