clc
close all
clear all

data = exelLog2table('S0_0007.txt');
ExelObj = Exel('EXLs3_0160','Segment','Homer','FigureVisible','off');
ExelObj.ImuData = data;

[Angles] = computeAngles(ExelObj)
x=Angles.Homer.Frontal.Acos;
y=Angles.Homer.Sagittal.Acos;
t1=Angles.Homer.Frontal.Atan;
t2=Angles.Homer.Sagittal.Atan;
figure
subplot(211),plot(x),hold on, plot(t1),title('Acos/Atan Frontal'),legend('cos','tan'),hold off;
subplot(212),plot(y),hold on, plot(t2),title('Acos/Atan Sagittal'),hold off;
