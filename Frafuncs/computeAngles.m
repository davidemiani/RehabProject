function [Angles] = computeAngles(Exelobj)

g=9.81;

% filter signal
Exelobj.ImuData{:,3:5} = filterAcc(Exelobj.ImuData{:,3:5}', 50, 'off')';

switch Exelobj.Segment
    
    case 'Thorax'
        
        %Txt Sagittal
        
        Angles.Thorax.Sagittal.Atan = atan2d(...
            -Exelobj.ImuData.AccZ , Exelobj.ImuData.AccY)'; %asse z è negativo per avere rotazione in avanti  antioraria positiva;
        Angles.Thorax.Sagittal.Acos =real(...
            acosd( round((Exelobj.ImuData.AccZ/g), 1)))'-90;%AccZ e -90 tolti;
        
        %Txt Frontal
        
        Angles.Thorax.Frontal.Atan = atan2d(...
            Exelobj.ImuData.AccX , Exelobj.ImuData.AccY)';
        Angles.Thorax.Frontal.Acos =real(...
            acosd( round(-Exelobj.ImuData.AccX/g, 1)))'-90;%-AccX -90;
        
    case 'Homer'
        
        %Hom Sagittal
        
        Angles.Homer.Sagittal.Atan =  atan2d(...
            Exelobj.ImuData.AccX , Exelobj.ImuData.AccY)';
        Angles.Homer.Sagittal.Acos =real(...
            acosd( round(-Exelobj.ImuData.AccX/g, 1)))'-90; %-AccX -90
        
        %Hom frontal
        
        Angles.Homer.Frontal.Atan= atan2d(...
            Exelobj.ImuData.AccZ, Exelobj.ImuData.AccY)';
        Angles.Homer.Frontal.Acos=real(...
            acosd( round(-Exelobj.ImuData.AccZ/g, 1)))'-90; %-AccZ -90
        
end

end

