clc
close all
clear all

data = exelLog2table('S0_0012.txt');
ExelObj = Exel('EXLs3_0160','Segment','Homer','FigureVisible','off');
ExelObj.ImuData = data;