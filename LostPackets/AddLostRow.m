function IMUdata = AddLostRow(IMULost,IMUdata,MaxforInterp)

for int = 1:size(IMULost.WhereLost,1)
    
    lastSampleIndex = IMULost.WhereLost.CutPointIndex(int)
    deltaSample = IMULost.WhereLost.SamplesNum(int)
    
    
    %ampliamento tabella dati con zeri
    IMUdata{ lastSampleIndex+1 : end+deltaSample, :} =...
        [ zeros(deltaSample,16);
        IMUdata{lastSampleIndex+1 : end, :}];
    
    
    %reimposto la colonna ProgrNum inserendo numeri progressivi
    IMUdata.ProgrNum(...
        lastSampleIndex+1 : lastSampleIndex + 1 + deltaSample) = ...
        (lastSampleIndex : lastSampleIndex+deltaSample)';
    
    
    %reimposto la colonna PacketType e Vbat inserendo l'ultimo
    %valore prima della perdita
    IMUdata{...
        lastSampleIndex+1 : lastSampleIndex + deltaSample,[2 end]} = ...
        IMUdata{lastSampleIndex,[2 end]}.*ones(deltaSample,2);
    
    
    if IMULost.WhereLost.CutPointIndex > MaxforInterp
            
        IMUdata{...
            lastSampleIndex+1 : lastSampleIndex + deltaSample,3:15} = ...
            nan.*ones(deltaSample,13);
        
    else
        
        IMUdata = InterpLostData(IMUdata,lastSampleIndex,deltaSample);
        
    end
end
end

