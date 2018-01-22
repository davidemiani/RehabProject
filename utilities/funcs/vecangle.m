function theta = vecangle(v,w)
theta = acosd(dot(v,w,2)./(vecnorm(v,2,2).*vecnorm(w,2,2)));
end