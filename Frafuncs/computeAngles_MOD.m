function [Angles] = computeAngles_MOD(Exelobj)

g=9.81;

% % filter signal
% Exelobj.ImuData{:,3:5} = filterAcc(Exelobj.ImuData{:,3:5}', 50, 'off')';

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
        
        %Hom Sagittal & Frontal Atan
        
        Angles.Homer.Sagittal.Atan =  atan2d(...
            Exelobj.ImuData.AccX , Exelobj.ImuData.AccY)';
        Angles.Homer.Frontal.Atan= atan2d(...
            Exelobj.ImuData.AccZ, Exelobj.ImuData.AccY)';

        %Hom Sagittal & Frontal Acos
       
        for i=1:L    
            
            if Exelobj.ImuData.AccY(i,1)>0
        
                Angles.Homer.Sagittal.Acos(i,1) = real(...
                    acosd( round(-Exelobj.ImuData.AccX(i,1)/g, 1)))'-90; %-AccX -90
        
                Angles.Homer.Frontal.Acos(i,1) = real(...
                    acosd( round(-Exelobj.ImuData.AccZ(i,1)/g, 1)))'-90; %-AccZ -90
            else 
                 Angles.Homer.Sagittal.Acos(i,1) = real(...
                    acosd( round(-Exelobj.ImuData.AccX(i,1)/g, 1)))'; %Togliamo il -90 poichè vogliamo angoli>90;
        
                Angles.Homer.Frontal.Acos(i,1) = real(...
                    acosd( round(-Exelobj.ImuData.AccZ(i,1)/g, 1)))'; 
            end
        end
        
end

end

