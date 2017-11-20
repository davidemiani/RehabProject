function ImuData = InterpLostData(ImuData,lastSampleIndex,deltaSample)

x = ImuData{[lastSampleIndex lastSampleIndex+deltaSample+1],1};
GrInterp=1;
%if AcquisitionMode = 'A'
%column = 3:5
for column = 3:15
    
    y = ImuData{[lastSampleIndex lastSampleIndex+deltaSample+1],column};
    coeff = polyfit(x,y,GrInterp);
    xnew=x(1):x(2);
    
    ImuData{...
        lastSampleIndex : lastSampleIndex + deltaSample + 1,column} = ...
        polyval(coeff,xnew)';
end
end