% a: angolo per rotazione x ed y

pulisci
[files,paths] = files2cell(fullfile(pwd,'2018-01-18'));
n = numel(files);
f = zeros(n,1);
g = zeros(n,1);
a = zeros(n,1);

for k=1:n
    % loading exel array
    load(paths{k,1})
    
    % getting table height
    h = min(height(obj(1,1).ExelData),height(obj(2,1).ExelData));
    
    % getting acc data and normalizing them
    a_h = obj(1,1).ExelData{1:h,3:5}; a_h = a_h./vecnorm(a_h,2,2);
    a_t = obj(2,1).ExelData{1:h,3:5}; a_t = a_t./vecnorm(a_t,2,2);
    
    % getting gold standard
    g(k,1) = obj(1,1).UserData.GoldStandard;
    
    % creating x and y pure gravity arrays
    g_x = repmat([1,0,0],h,1);
    g_y = repmat([0,1,0],h,1);
    
    % getting angle between x',y' and x'',y''
    theta_h_x = 90-vecangle(a_h,g_x); theta_h_y = vecangle(a_h,g_y);
    theta_t_x = 90-vecangle(a_t,g_x); theta_t_y = vecangle(a_h,g_y);
    for i = 1:h
        a_h(i,:) = a_h(i,:)*rotmat('x',theta_h_x(i,1))*rotmat('y',theta_h_y(i,1));
        a_t(i,:) = a_t(i,:)*rotmat('x',theta_t_x(i,1))*rotmat('y',theta_t_y(i,1));
    end
    a(k,1) = round(mean(vecangle(a_h,a_t)));
    
    % fileID
    f(k,1) = str2double(files{k,1}(end-5:end-4));
end
table(f,g,a)



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
