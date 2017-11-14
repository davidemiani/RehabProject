function [Angles] = computeAngles(Exelobj)

switch Exelobj.Segment
    
    case 'Thorax'
        
        %Txt Sagittal
        
        Angles.Thorax.Sagittal.Atan = atan2d(...
            -Exelobj.ImuData.AccZ , Exelobj.ImuData.AccY)'; %asse z � negativo per avere rotazione in avanti  antioraria positiva;
        Angles.Thorax.Sagittal.Acos = real(...
            acosd( round((Exelobj.ImuData.AccZ).* 2 / 2^15, 1)))'-90;
        
        %Txt Frontal
        
        Angles.Thorax.Frontal.Atan = atan2d(...
            Exelobj.ImuData.AccX , Exelobj.ImuData.AccY)';
        Angles.Thorax.Frontal.Acos = real(...
            acosd( round( -Exelobj.ImuData.AccX .* 2 / 2^15, 1)))'-90;
        
    case 'Homer'
        
        %Hom Sagittal
        
        Angles.Homer.Sagittal.Atan =  atan2d(...
            Exelobj.ImuData.AccX , Exelobj.ImuData.AccY)';
        Angles.Homer.Sagittal.Acos = real(...
            acosd( round( -Exelobj.ImuData.AccX.* 2 / 2^15, 1)))'-90;
        
        %Hom frontal
        
        Angles.Homer.Frontal.Atan= atan2d(...
            Exelobj.ImuData.AccZ, Exelobj.ImuData.AccY)';
        Angles.Homer.Frontal.Acos= real(...
            acosd( round( - Exelobj.ImuData.AccZ.* 2 / 2^15, 1)))'-90;%
        
end

end

