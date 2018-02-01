function angle = sagittal2(obj,ind)
%SAGITTAL Implement sagittal algorithm modified by Ferrari Alberto (31/01/2018).
% 
%    ANGLE = SAGITTAL(OBJ) computes angle between the sensor and gravity 
%    using all value in the ExelData table of the Exel object OBJ.
%
%    ANGLE = PROJECTION(OBJ,IND) compute angle between the sensor and
%    gravity only for ExelData rows indicated by IND.
%
%    See also Exel, projection

% checking inputs and outputs number
narginchk(1,2)
nargoutchk(1,1)

% if no index specified, getting all of them
if nargin==1
    ind = (1:height(obj.ExelData))';
end

AccX = obj.ExelData.AccX(ind,1);
AccY = obj.ExelData.AccY(ind,1);
AccZ = obj.ExelData.AccZ(ind,1);

% ALGORITMO DEFINITIVO

ind_piano_F=(abs(AccZ)>abs(AccX));%1 movimento sul piano Frontale, 0 movimento dul piano sagittale
ind_piano_S=~ind_piano_F;

ind_less90 = AccY>=0; %range [0 90]
ind_more90 = ~ind_less90; %range ]90 180]

Arg_F = (AccZ);
ind_Atan= abs(Arg_F)>0.9659; %sogli di switch a 75� per cui tra [75 115] viene utilizzata atan nel piano di interesse
ind_Acos= ~ind_Atan;

% Definizione nuovi indici per i vari casi

ind_PianoF_less90_Atan = ind_less90 & ind_piano_F & ind_Atan;
ind_PianoF_less90_Acos = ind_less90 & ind_piano_F & ind_Acos;

ind_PianoF_more90_Atan = ind_more90 & ind_piano_F & ind_Atan;
ind_PianoF_more90_Acos = ind_more90 & ind_piano_F & ind_Acos;

ind_PianoS_less90_Atan = ind_less90 & ind_piano_S & ind_Atan;
ind_PianoS_less90_Acos = ind_less90 & ind_piano_S & ind_Acos;

ind_PianoS_more90_Atan = ind_more90 & ind_piano_S & ind_Atan;
ind_PianoS_more90_Acos = ind_more90 & ind_piano_S & ind_Acos;

%Inizializzazione vettori struttura

Angle.Frontal=zeros(size(AccX));
Angle.Sagittal=zeros(size(AccX));

%Piano Frontale di Lavoro

%     AtanF = atan2d(AccZ,AccY);
%     Acos_less90 = real(acosd(round(-AccZ/9.807,3)))-90;
%     Acos_more90 = real(acosd(round(AccZ/9.807,3)))+90;

%Calcolo angolo sul piano Frontale con movimento sul piano Frontale

Angle.Frontal(ind_PianoF_less90_Acos,1)  = real(...
    acosd(round(-AccZ(ind_PianoF_less90_Acos),3)))-90; %angolo [0 75]
Angle.Frontal(ind_PianoF_less90_Atan,1)  = atan2d(...
    AccZ(ind_PianoF_less90_Atan),AccY(ind_PianoF_less90_Atan));% angolo [75 90]

Angle.Frontal(ind_PianoF_more90_Atan,1) = atan2d(...
    AccZ(ind_PianoF_more90_Atan),AccY(ind_PianoF_more90_Atan)); %angolo [90 115]
Angle.Frontal(ind_PianoF_more90_Acos,1)  = real(...
    acosd(round(+AccZ(ind_PianoF_more90_Acos),3)))+90; %angolo [115 180]

%Calcolo angolo sul piano frontale con movimento sul piano Sagittale
%Qui non mi importa il segno di AccY per cambiare algoritmo metodo Acos e inoltre non mi importa lo shift tra Atan e Acos;

Angle.Frontal(ind_piano_S,1) = real(...
    acosd(round(-AccZ(ind_piano_S),3)))-90;


%Calcolo angolo sul piano Sagittale con movimento sul piano Sagittale

Angle.Sagittal(ind_PianoS_less90_Acos,1)  = real(...
    acosd(round(-AccX(ind_PianoS_less90_Acos),3)))-90; %angolo [0 75]
Angle.Sagittal(ind_PianoS_less90_Atan,1)  = atan2d(...
    AccX(ind_PianoS_less90_Atan),AccY(ind_PianoS_less90_Atan)); %angolo [75 90]

Angle.Sagittal(ind_PianoS_more90_Atan,1) = atan2d(...
    AccX(ind_PianoS_more90_Atan),AccY(ind_PianoS_more90_Atan)); %angolo [90 115]
Angle.Sagittal(ind_PianoS_more90_Acos,1)  = real(...
    acosd(round(AccX(ind_PianoS_more90_Acos),3)))+90; %angolo [115 180]

%Calcolo angolo sul piano Sagittale con movimento sul piano Frontale,
%dunque piano che non interessa il movimento

Angle.Sagittal(ind_piano_F) = real(...
    acosd(round(-AccX(ind_piano_F),3)))-90;

if range( filterImuData( Angle.Sagittal, 50 )) > range( filterImuData( Angle.Frontal, 50 ))
    angle = Angle.Sagittal;
else
    angle = Angle.Frontal;
end

end