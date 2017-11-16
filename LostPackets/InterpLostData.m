function IMUdata = InterpLostData(IMUdata,lastSampleIndex,deltaSample)

x = IMUdata{[lastSampleIndex lastSampleIndex+deltaSample+1],1};
GrInterp=1;
%if AcquisitionMode = 'A'
%column = 3:5
for column = 3:15
    
    y = IMUdata{[lastSampleIndex lastSampleIndex+deltaSample+1],column};
    coeff = polyfit(x,y,GrInterp);
    xnew=x(1):x(2);
    
    IMUdata{...
        lastSampleIndex : lastSampleIndex + deltaSample + 1,column} = ...
        polyval(coeff,xnew)';
end
end