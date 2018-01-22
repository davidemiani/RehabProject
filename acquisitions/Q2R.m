function R = Q2R(Q)

% Note: q(1) should be the scalar component!!

[n,m] = size(Q);
if m~=4
    error('Q2R:invalidColNum', ...
        'Q must be an nx4 array.')
end
R = zeros(3,3,n);
Q0 = Q(:,1);
Q1 = Q(:,2);
Q2 = Q(:,3);
Q3 = Q(:,4);

R(1,1,:) = Q0.^2 + Q1.^2 - Q2.^2 - Q3.^2;
R(1,2,:) = 2 .* (Q1 .* Q2 - Q0 .* Q3);
R(1,3,:) = 2 .* (Q1 .* Q3 + Q0 .* Q2);
R(2,1,:) = 2 .* (Q2 .* Q1 + Q0 .* Q3);
R(2,2,:) = Q0.^2 - Q1.^2 + Q2.^2 - Q3.^2;
R(2,3,:) = 2 .* (Q2 .* Q3 - Q0 .* Q1);
R(3,1,:) = 2 .* (Q3 .* Q1 - Q0 .* Q2);
R(3,2,:) = 2 .* (Q3 .* Q2 + Q0 .* Q1);
R(3,3,:) = Q0.^2 - Q1.^2 - Q2.^2 + Q3.^2;
end

% R = [(Q0^2+Q1^2-Q2^2-Q3^2) 2*(Q1*Q2-Q0*Q3) 2*(Q1*Q3+Q0*Q2);
%     2*(Q2*Q1+Q0*Q3) (Q0^2-Q1^2+Q2^2-Q3^2) 2*(Q2*Q3-Q0*Q1);
%     2*(Q3*Q1-Q0*Q2) 2*(Q3*Q2+Q0*Q1) (Q0^2-Q1^2-Q2^2+Q3^2)];

% convertion from quaternion to rotation matrix according to Horn, B.
% Closed-Form Solution of Absolute Orientation Using Unit Quaternions,JOSA
% A, Vol. 4, No. 4, 1987.