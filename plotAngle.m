function plotAngle( ang1, ang2, ang3, ang4, t, lineHandle, SF, i )


% zAngle = atan2d( data(:, 7), data(:, 6));

% set( lineHandle( 1 ), 'XData', t , 'YData', ang1 )
% set( lineHandle( 2 ), 'XData', t , 'YData', ang2 )
% set( lineHandle( 3 ), 'XData', t , 'YData', ang3 )

if i == 1
    addpoints( lineHandle( 1 ), t, ang1 ); addpoints( lineHandle( 2 ), t, ang2 );
    addpoints( lineHandle( 3 ), t, ang3 ); addpoints( lineHandle( 4 ), t, ang4 );
end

if i == 2
    addpoints( lineHandle( 5 ), t, ang1 ); addpoints( lineHandle( 6 ), t, ang2 );
    addpoints( lineHandle( 7 ), t, ang3 ); addpoints( lineHandle( 8 ), t, ang4 );
end

if mod( t( end ), 50 ) == 0
    l = get( gca, 'XLim' );
    if t( end ) > l( 2 )
        
        subplot(4,1,1); axis([l(2) l(2)+SF*20 -50 200]); subplot(4,1,2); axis([l(2) l(2)+SF*20 -50 200]);    
        subplot(4,1,3); axis([l(2) l(2)+SF*20 -50 200]); subplot(4,1,4); axis([l(2) l(2)+SF*20 -50 200]);
    end
end
drawnow limitrate;