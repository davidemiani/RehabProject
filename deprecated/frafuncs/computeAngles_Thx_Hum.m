function [Angles] = computeAngles_Thx_Hum(Exelobj)

%In questa funzione è stato fatto uno studio sulla funzione arccos e sulla
%funzione atan nel calcolo degli angoli dell'omero;
%Innanzitutto è necessario cambiare l'algoritmo per angoli 90<alfa<=180 e per tenere 
%conto di questo, con un semplice  controllo del segno dell'Accy:
% - quando Accy>=0 siamo in angoli nel range [0 +90];
% - quando AccY<0 siamo in angoli nel range [+90 +180];
%
%Inoltre è stato utilizzato un altro accorgimento rigurandante sempre l'arccos:
% - Poichè l'arccos superato un certo angolo fornisce un errore molto
%   elevato [50-60(circa) 90] e allo stesso tempo nel range [90-120(circa)], allora  
%   in quel caso per il calcolo dell'angolo viene utilizzata l'atan;
% - Nel restante dei casi l'angolo viene trovato con l'acos;
%
%Per fare questo, abbiamo utilizzato una variabile come check, ovvero  
%il rapporto tra il valore dell'accelerazione che stiamo utilizzando per il calcolo
%dell'angolo con il metodo del Acos e la g(gravità);
%
% - Nel caso del piano frontale (-AccZ/g)>0.9659;
% - Nel caso del piano sagittale (-AccX/g)>0.9659;
%
%Un rapporto Acc/g di 0.9659 significa avere un angolo di 75° sul quale l'arcos  a già
%un errore intorno ai 5-10°, quindi da questo potremmo partire per lo shift;


switch Exelobj.Segment
    
    case 'Homer'
        ind1 = Exelobj.Imudata.AccY>=0;
        ind2 = ~ind1;
        
        Arg_S = (Exelobj.ImuData.AccX./9.807);
        Arg_F = (Exelobj.ImuData.AccZ./9.807);
        
        ind1_AF= abs(Arg_F)>0.9659;
        ind2_AF= ~ind1_AF;
        
        ind1_AS= abs(Arg_S)>0.9659;
        ind2_AS= ~ind1_AS;
        
        %Piano Frontale
        
        AtanF = atan2d(Exelobj.Imudata.AccZ,Exelobj.Imudata.AccY);
        AcosF(ind1,1) = real(acosd(round(-Exelobj.Imudata.AccZ(ind1,1)/9.807,1)))-90;      
        AcosF(ind2,1) = real(acosd(round(Exelobj.Imudata.AccZ(ind2,1)/9.807,1)))+90; 
  
        Angles.Homer.Frontal(ind1_AF,1) = AtanF(ind1_AF,1);
        Angles.Homer.Frontal(ind2_AF,1) = AcosF(ind2_AF,1);
        
        %Piano Saggitale
        
        AtanS = atan2d(Exelobj.Imudata.AccX,Exelobj.Imudata.AccY);
        AcosS(ind1,1) = real(acosd(round(-Exelobj.Imudata.AccX(ind1,1)/9.807,1)))-90;      
        AcosS(ind2,1) = real(acosd(round(Exelobj.Imudata.AccX(ind2,1)/9.807,1)))+90; 
        
        Angles.Homer.Sagittal(ind1_AS,1) = AtanS(ind1_AS,1);
        Angles.Homer.Sagittal(ind2_AS,1) = AcosS(ind2_AS,1); 
        
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
        
end

end