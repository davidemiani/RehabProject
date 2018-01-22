function T = Q2T(Q)

[n,m] = size(Q);
if m~=4
    error('Q2R:invalidColNum', ...
        'Q must be an nx4 array.')
end
T = zeros(n,3);
Q0 = Q(:,1);
Q1 = Q(:,2);
Q2 = Q(:,3);
Q3 = Q(:,4);

T(:,1) = atan2d(2 .* (Q0 .* Q1 + Q2 .* Q3), 1 - 2 .* (Q1.^2 + Q2.^2));
T(:,2) = asind(2 .* (Q0 .* Q2 - Q3 .* Q1));
T(:,3) = atan2d(2 .* (Q0 .* Q3 + Q1 .* Q2), 1 - 2 .* (Q2.^2 + Q3.^2));
end