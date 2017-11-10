function [IMUData, k] = getDataFromIMU( s, packetSize, npb, channels, k )

% getDataFromIMU
%
% -------------------------------------------------------------------------
% INPUT
%
% -------------------------------------------------------------------------
% OUTPUT
%
% -------------------------------------------------------------------------
% EXAMPLE
% getDataFromIMU
%
% -------------------------------------------------------------------------
% SEE ALSO
% CALLED BY
%
% -------------------------------------------------------------------------
% RUN
%
% -------------------------------------------------------------------------
% AUTHOR
% Alberto Ferrari
% mailto: alberto.ferrari@unibo.it
%
% -------------------------------------------------------------------------
% REVIEW
% Jan 2013
try
rawChar = fread( s );

% rawData = fi( rawChar, 1, packetSize, 0, 'OverflowMode','wrap' );  %data are now represeted 16 bit signed

IMUData = NaN( npb, channels );

% check for correct packet Header ID
% if double( rawData( 1 )) ~= 32 && double( rawData( 2 )) ~= 129
%     
%         disp(['Byte lost ', num2str(i)] )
%         disp( iii ), disp( double( rawData( 2 )) )
%         while double( rawData( ii + packetSize )) ~= 32 && double( rawData( 1 + ii + packetSize )) ~= 129
%             ii = ii + 1;
%         end
%         % fread( s, ii, 'uint8' );
%         % npb = npb - ceil( ii / npb );
%         % rawChar =
%         % rawData = fi( rawChar(i:end), 1, channels, 0, 'OverflowMode','wrap' );  %data are now represeted 16 bit signed
% end

pktHeaderTypeIndexes = strfind( rawChar', [32 129]);

diffPktHeaderTypeindexes = diff( pktHeaderTypeIndexes ); 

ind = [pktHeaderTypeIndexes( diffPktHeaderTypeindexes == packetSize ) pktHeaderTypeIndexes( end )];

% disalignment = sum( diffPktHeaderTypeindexes( diffPktHeaderTypeindexes ~= packetSize )) - length( diffPktHeaderTypeindexes( diffPktHeaderTypeindexes ~= packetSize ));
% k = mod( disalignment, packetSize) + pktHeaderTypeIndexes(1) - 1; 
k = ind(1) - 1;
% packet structure:
%          hexadec  dec
% Byte_0 = 0x20 --> 32 HEADER
% Byte_1 = 0x81 --> 129  A
% Byte_2-3 = counter
% Byte_4-9 = acc
% Byte_10-15 = gyr
% Byte_16-24 = counter
% Byte_25 = checksum 

% if ii + ind(end) > packetSize*npb && flag, ind = ind( 1 : end - 1 ); flag = false; end
for i = 1 : length( ind )

    ii = 0;
    % packetID
    if ii + ind(i) <= packetSize*npb
    IMUData(i,1) = rawChar( ii + ind(i)); ii = ii + 1; end
    
    % packet type
    if ii + ind(i) <= packetSize*npb
    IMUData(i,2) = rawChar( ii + ind(i) ); ii = ii + 1;end % should be 129
    
    % counter
    % in case packet type is rawData IMUData(1:length(ii : packetSize : npb*packetSize),4) = rawData( ii : packetSize : end ); ii = ii + 1;
    if ii + ind(i) < packetSize*npb
    IMUData(i,3) = typecast(uint8([rawChar( ii + ind(i) ), rawChar( ii + 1 + ind(i) )]),'int16'); ii = ii + 2;end
    
    % acceleration
    if ii + ind(i) < packetSize*npb
    IMUData(i,4) = typecast(uint8([rawChar( ii + ind(i) ), rawChar( ii + 1 + ind(i) )]),'int16'); ii = ii + 2;end
    if ii + ind(i) < packetSize*npb
    IMUData(i,5) = typecast(uint8([rawChar( ii + ind(i) ), rawChar( ii + 1 + ind(i) )]),'int16'); ii = ii + 2;end
    if ii + ind(i) < packetSize*npb
    IMUData(i,6) = typecast(uint8([rawChar( ii + ind(i) ), rawChar( ii + 1 + ind(i) )]),'int16'); ii = ii + 2;end
    
    % checksum
    if ii + ind(i) <= packetSize*npb
    IMUData(i,7) = rawChar( ii + ind(i) );end
end

IMUData = double( IMUData );

catch ME
   disp(ME);stop(tmr);
end
end

% % packetID
% IMUData(1:length(ii : packetSize : npb*packetSize),1) = rawData( ii : packetSize : end ); ii = ii + 1;
% 
% % packet type
% IMUData(1:length(ii : packetSize : npb*packetSize),2) = rawData( ii : packetSize : end ); ii = ii + 1; % should be 129
% 
% % counter
% % in case packet type is rawData IMUData(1:length(ii : packetSize : npb*packetSize),4) = rawData( ii : packetSize : end ); ii = ii + 1;
% IMUData(1:length(ii+1 : packetSize : npb*packetSize),3) = bitor( rawData( ii : packetSize : end-1 ),bitshift( rawData( ii+1 : packetSize : end ), 8 )); ii = ii + 2;
% 
% % acceleration
% IMUData(1:length(ii+1 : packetSize : npb*packetSize),4) = bitor( rawData( ii : packetSize : end-1 ),bitshift( rawData( ii+1 : packetSize : end ), 8 )); ii = ii + 2;
% IMUData(1:length(ii+1 : packetSize : npb*packetSize),5) = bitor( rawData( ii : packetSize : end-1 ),bitshift( rawData( ii+1 : packetSize : end ), 8 )); ii = ii + 2;
% IMUData(1:length(ii+1 : packetSize : npb*packetSize),6) = bitor( rawData( ii : packetSize : end-1),bitshift( rawData( ii+1 : packetSize : end ), 8 )); ii = ii + 2;
% 
% % gyro
% % IMUData(1:length(ii+1 : packetSize : npb*packetSize),8) = bitor( rawData( ii : packetSize : end-1 ),bitshift( rawData( ii+1 : packetSize : end ), 8 )); ii = ii + 2;
% % IMUData(1:length(ii+1 : packetSize : npb*packetSize),9) = bitor( rawData( ii : packetSize : end-1 ),bitshift( rawData( ii+1 : packetSize : end ), 8 )); ii = ii + 2;
% % IMUData(1:length(ii+1 : packetSize : npb*packetSize),10) = bitor( rawData( ii : packetSize : end-1 ),bitshift( rawData( ii+1 : packetSize : end ), 8 )); ii = ii + 2;
% 
% % mag
% % IMUData(1:length(ii+1 : packetSize : npb*packetSize),11) = bitor( rawData( ii : packetSize : end-1 ), bitshift( rawData( ii+1 : packetSize : end ), 8 )); ii = ii + 2;
% % IMUData(1:length(ii+1 : packetSize : npb*packetSize),12) = bitor( rawData( ii : packetSize : end-1 ), bitshift( rawData( ii+1 : packetSize : end ), 8 )); ii = ii + 2;
% % IMUData(1:length(ii+1 : packetSize : npb*packetSize),13) = bitor( rawData( ii : packetSize : end-1 ), bitshift( rawData( ii+1 : packetSize : end ), 8 ));ii = ii + 2;
% 
% % checksum
% IMUData(1:length(ii : packetSize : npb*packetSize),7) = rawData( ii : packetSize : end );
% fprintf( txtFile, '%6i;%6i;%6i;%6i;%7i;%7i;%7i;%7i;%7i;%7i;%7i;%7i;%7i;%6i;%6i;%6i; \n', IMUData( 1:length(ii : packetSize : npb*packetSize), 1:16 )');
