pulisci
load(fullfile(pwd,'2018-01-17','MM17_25.mat'))
GoldStandard = obj(1,1).UserData.GoldStandard

AH_S = obj(1,1).ExelData{:,3:5}(1,:);
AT_S = obj(2,1).ExelData{:,3:5}(1,:);

AH_S = AH_S./vecnorm(AH_S,2,2);
AT_S = AT_S./vecnorm(AT_S,2,2);

thetaH_Z = axes2angle(AH_S,[0,0,1])
thetaT_Z = axes2angle(AT_S,[0,0,1])

AH_GZ = AH_S*rotz(thetaH_Z)
AT_GZ = AT_S*rotz(thetaT_Z)

angle = axes2angle(AH_GZ,AT_GZ)



function angle = axes2angle(v,w)
angle = acosd(dot(v,w,2)./(vecnorm(v,2,2).*vecnorm(w,2,2)));
end

function RZ = rotz(a)
RZ = [cosd(a), -sind(a), 0; sind(a), cosd(a), 0; 0, 0, 1];
end
