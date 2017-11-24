clc
close all
clear all

%Movimenti prova in Statica, braccio a 90° sul piano frontale;


addpath('../davefuncs')
addpath('../Exel_class')
addpath('../oldcode')
addpath('../Frafuncs')

%% 1 test
t1=load('t1.mat')
t1=t1.dataHum;
ProgrNum=t1(:,3);
PacketType=t1(:,2);
AccX=t1(:,4);
AccY=t1(:,5);
AccZ=t1(:,6);
DataHum1=table(ProgrNum,PacketType,AccX,AccY,AccZ);
ExelObj1 = Exel('EXLs3_0160','Segment','Homer','FigureVisible','off');
ExelObj1.ImuData = DataHum1;

[Angles1] = computeAngles_2(ExelObj1)
x1=Angles1.Homer.Frontal.Acos;
y1=Angles1.Homer.Sagittal.Acos;

%% 2 test
t2=load('t2.mat')
t2=t2.dataHum;
ProgrNum=t2(:,3);
PacketType=t2(:,2);
AccX=t2(:,4);
AccY=t2(:,5);
AccZ=t2(:,6);
DataHum2=table(ProgrNum,PacketType,AccX,AccY,AccZ);
ExelObj2 = Exel('EXLs3_0160','Segment','Homer','FigureVisible','off');
ExelObj2.ImuData = DataHum2;

[Angles2] = computeAngles_2(ExelObj2)
x2=Angles2.Homer.Frontal.Acos;
y2=Angles2.Homer.Sagittal.Acos;

%% 3 test

t3=load('t3.mat')
t3=t3.dataHum;
ProgrNum=t3(:,3);
PacketType=t3(:,2);
AccX=t3(:,4);
AccY=t3(:,5);
AccZ=t3(:,6);
DataHum3=table(ProgrNum,PacketType,AccX,AccY,AccZ);
ExelObj3 = Exel('EXLs3_0160','Segment','Homer','FigureVisible','off');
ExelObj3.ImuData = DataHum3;

[Angles3] = computeAngles_2(ExelObj3)
x3=Angles3.Homer.Frontal.Acos;
y3=Angles3.Homer.Sagittal.Acos;

%% 4 test

t4=load('t4.mat')
t4=t4.dataHum;
ProgrNum=t4(:,3);
PacketType=t4(:,2);
AccX=t4(:,4);
AccY=t4(:,5);
AccZ=t4(:,6);
DataHum4=table(ProgrNum,PacketType,AccX,AccY,AccZ);
ExelObj4 = Exel('EXLs3_0160','Segment','Homer','FigureVisible','off');
ExelObj4.ImuData = DataHum4;

[Angles4] = computeAngles_2(ExelObj4)
x4=Angles4.Homer.Frontal.Acos;
y4=Angles4.Homer.Sagittal.Acos;

%% 5 test

t5=load('t5.mat')
t5=t5.dataHum;
ProgrNum=t5(:,3);
PacketType=t5(:,2);
AccX=t5(:,4);
AccY=t5(:,5);
AccZ=t5(:,6);
DataHum5=table(ProgrNum,PacketType,AccX,AccY,AccZ);
ExelObj5 = Exel('EXLs3_0160','Segment','Homer','FigureVisible','off');
ExelObj5.ImuData = DataHum5;

[Angles5] = computeAngles_2(ExelObj5)
x5=Angles5.Homer.Frontal.Acos;
y5=Angles5.Homer.Sagittal.Acos;

%Calcolo Errore

E1x=90-x1;
E1y=90-y1;

E2x=90-x2;
E2y=90-y2;

E3x=90-x3;
E3y=90-y3;

E4x=90-x4;
E4y=90-y4;

E5x=90-x5; 
E5y=0-y5; %solo questo è corretto, controllare acquisizioni;

Ex=mean((E1x+E2x+E3x+E4x+E5x)/5); %idealmente dovrei leggere 0 sul piano sagittale
Ey=mean((E1y+E2y+E3y+E4y+E5y)/5); %idealmente dovrei leggere 90 sul piano frontale