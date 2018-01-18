pulisci

% loading exel array
load(fullfile(pwd,'2018-01-18','MM17_06.mat'))

% getting table height
h = min(height(obj(1,1).ExelData),height(obj(2,1).ExelData));

% setting index and time array
indx = (1:h)';
time = (indx-1)./obj(1,1).SamplingFrequency;

% getting homer accs, calibrating and normalizing them
a_h = obj(1,1).ExelData{indx,3:5};
a_h = a_h * obj(1,1).Calibration;
a_h = a_h ./ vecnorm(a_h,2,2);

% getting thorax accs, calibrating and normalizing them
a_t = obj(2,1).ExelData{indx,3:5};
a_t = a_t * obj(2,1).Calibration;
a_t = a_t ./ vecnorm(a_t,2,2);

% creating x, y and z pure gravity arrays
g_x = repmat([1,0,0],h,1);
g_y = repmat([0,1,0],h,1);
g_z = repmat([0,0,1],h,1);

% computing angles between homer and gravity
theta_h0 = vecangle(a_h,g_y);

% computing angles between a_t and a_h
%theta_h1 = vecangle(a_)

% computing thorax angles
theta_t = vecangle(a_t,g_y);

% getting angles between local x,z and global x,z
theta_h_x = vecangle(a_h,g_x);
theta_h_y =    vecangle(a_h,g_y);
theta_h_z = vecangle(a_h,g_z);

theta_t_x = vecangle(a_t,g_x);
theta_t_y =    vecangle(a_h,g_y);
theta_t_z = vecangle(a_h,g_z);

% computing rotate accs
for i = 1:h
    a_h(i,:) = a_h(i,:) ...
        * rotmat('x',theta_h_x(i,1)) ...
        ... * rotmat('y',theta_h_y(i,1)) ...
        * rotmat('z',theta_h_z(i,1)) ...
        ;
    a_t(i,:) = a_t(i,:) ...
        * rotmat('x',theta_t_x(i,1)) ...
        ... * rotmat('y',theta_t_y(i,1)) ...
        * rotmat('z',theta_t_z(i,1)) ...
        ;
end

% computing homer angles
theta_h = vecangle(a_h,a_t);

figure
subplot(3,1,1)
plot(time,theta_h0,'r','LineWidth',1.5)
xlabel('time (s)')
ylabel('degrees (\circ)')
title('Homer_0')
set(gca,'FontSize',25,'XMinorTick','on','YMinorTick','on')

subplot(3,1,2)
plot(time,theta_h,'r','LineWidth',1.5)
xlabel('time (s)')
ylabel('degrees (\circ)')
title('Homer')
set(gca,'FontSize',25,'XMinorTick','on','YMinorTick','on')

subplot(3,1,3)
plot(time,theta_t,'b','LineWidth',1.5)
xlabel('time (s)')
ylabel('degrees (\circ)')
title('Thorax')
set(gca,'FontSize',25,'XMinorTick','on','YMinorTick','on')

function angle = vecangle(v,w)
angle = acosd(dot(v,w,2)./(vecnorm(v,2,2).*vecnorm(w,2,2)));
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




