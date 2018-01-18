% a: angolo calcolato fra le due accelerazioni
% x: angolo per rotazione x
% y: angolo per rotazione y
% z: angolo per rotazione z

pulisci
[files,paths] = files2cell(fullfile(pwd,'2018-01-17'));
n = numel(files);
f = zeros(n,1);
g = zeros(n,1);
a = zeros(n,1);
x = zeros(n,1);
y = zeros(n,1);
z = zeros(n,1);
m = zeros(n,1);

for k=1:n
    % loading exel array
    load(paths{k,1})
    
    % getting table height
    h = height(obj(1,1).ExelData);
    
    % getting acc data and normalizing them
    a_h = obj(1,1).ExelData{:,3:5}; a_h = a_h./vecnorm(a_h,2,2);
    a_t = obj(2,1).ExelData{:,3:5}; a_t = a_t./vecnorm(a_t,2,2);
    
    % getting gold standard
    g(k,1) = obj(1,1).UserData.GoldStandard;
    
    a(k,1) = round(mean(vecangle(a_t,a_h)));
    
    % getting angle with x as a common axis
    a_h_x = a_h; theta_h_x = vecangle(a_h,repmat([1,0,0],h,1));
    a_t_x = a_t; theta_t_x = vecangle(a_t,repmat([1,0,0],h,1));
    for i = 1:h
        a_h_x(i,:) = a_h_x(i,:)*rotmat('x',theta_h_x(i,1));
        a_t_x(i,:) = a_t_x(i,:)*rotmat('x',theta_t_x(i,1));
    end
    x(k,1) = round(mean(vecangle(a_h_x,a_t_x)));
    
    % getting angle with y as a common axis
    a_h_y = a_h; theta_h_y = vecangle(a_h,repmat([0,1,0],h,1));
    a_t_y = a_t; theta_t_y = vecangle(a_t,repmat([0,1,0],h,1));
    for i = 1:h
        a_h_y(i,:) = a_h_y(i,:)*rotmat('y',theta_h_y(i,1));
        a_t_y(i,:) = a_t_y(i,:)*rotmat('y',theta_t_y(i,1));
    end
    y(k,1) = round(mean(vecangle(a_h_y,a_t_y)));
    
    % getting angle with z as a common axis
    a_h_z = a_h; theta_h_z = vecangle(a_h,repmat([0,0,1],h,1));
    a_t_z = a_t; theta_t_z = vecangle(a_t,repmat([0,0,1],h,1));
    for i = 1:h
        a_h_z(i,:) = a_h_z(i,:)*rotmat('z',theta_h_z(i,1));
        a_t_z(i,:) = a_t_z(i,:)*rotmat('z',theta_t_z(i,1));
    end
    z(k,1) = round(mean(vecangle(a_h_z,a_t_z)));
    
    % fileID
    f(k,1) = str2double(files{k,1}(end-5:end-4));
end
table(f,g,a,x,y,z)



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
