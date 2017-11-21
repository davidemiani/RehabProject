clc
close all
clear all

%Movimento 0F:con manichino tronco inclinato a destra osservandolo dal davanti e braccio
%fermo, dunque angolo tra braccio e tronco di 0� 

%Movimento 50F:con manichino tronco inclinato a destra osservandolo dal
%davanti e angolo tra braccio e tronco di 50�;

%Movimento 34F:con manichino tronco inclinato a sinistra osservandolo dal 
%davanti e angolo tra braccio e tronco di 50�; 

%% Parte Omero

load('dataHum0F');
ProgrNum=dataHum(:,3);
PacketType=dataHum(:,2);
AccX=dataHum(:,4);
AccY=dataHum(:,5);
AccZ=dataHum(:,6);
DataHum=table(ProgrNum,PacketType,AccX,AccY,AccZ);
ExelObj_H = Exel('EXLs3_0160','Segment','Homer','FigureVisible','off');
ExelObj_H.ImuData = DataHum;

[AnglesH] = computeAngles_2(ExelObj_H)
x=AnglesH.Homer.Frontal.Acos;
y=AnglesH.Homer.Sagittal.Acos;
t1=AnglesH.Homer.Frontal.Atan;
T1=mean(t1)*ones(1,length(t1));
t2=AnglesH.Homer.Sagittal.Atan;
T2=mean(t2)*ones(1,length(t2));

figure
subplot(211),plot(x),hold on, plot(T1),title('Homer Acos/Atan Frontal'),legend('cos','tan'),hold off;
subplot(212),plot(y),hold on, plot(T2),title('Acos/Atan Sagittal'),hold off;

%% Parte Tronco


load('dataThx0F');
ProgrNum=dataThx(:,3);
PacketType=dataThx(:,2);
AccX=dataThx(:,4);
AccY=dataThx(:,5);
AccZ=dataThx(:,6);
DataThx=table(ProgrNum,PacketType,AccX,AccY,AccZ);
ExelObj_T = Exel('EXLs3_0160','Segment','Thorax','FigureVisible','off');
ExelObj_T.ImuData = DataThx;

[AnglesT] = computeAngles_2(ExelObj_T)
x=AnglesT.Thorax.Frontal.Acos;
y=AnglesT.Thorax.Sagittal.Acos;
t1=AnglesT.Thorax.Frontal.Atan;
T1=mean(t1)*ones(1,length(t1));
t2=AnglesT.Thorax.Sagittal.Atan;
T2=mean(t2)*ones(1,length(t2));
figure
subplot(211),plot(x),hold on, plot(T1),title('Thorax Acos/Atan Frontal'),legend('cos','tan'),hold off;
subplot(212),plot(y),hold on, plot(T2),title('Acos/Atan Sagittal'),hold off;

%% DIFFERENZA FRA ANGOLI

%Per fare la differenza fra gli angoli, basta fare (angolo homer - angolo torax)
