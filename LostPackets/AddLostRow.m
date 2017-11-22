function ImuData = AddLostRow(ImuLost,ImuData,MaxforInterp)

for int = 1:size(ImuLost.WhereLost,1)
    
    lastSampleIndex = ImuLost.WhereLost.CutPointIndex(int);
    deltaSample = ImuLost.WhereLost.SamplesNum(int);
    
    
    %ampliamento tabella dati con zeri
    ImuData{ lastSampleIndex+1 : end+deltaSample, :} =...
        [ zeros(deltaSample,16);
        ImuData{lastSampleIndex+1 : end, :}];
    
    
    %reimposto la colonna ProgrNum inserendo numeri progressivi
    ImuData.ProgrNum(...
        lastSampleIndex+1 : lastSampleIndex + 1 + deltaSample) = ...
        (lastSampleIndex : lastSampleIndex+deltaSample)';
    
    
    %reimposto la colonna PacketType e Vbat inserendo l'ultimo
    %valore prima della perdita
    ImuData{...
        lastSampleIndex+1 : lastSampleIndex + deltaSample,[2 end]} = ...
        ImuData{lastSampleIndex,[2 end]}.*ones(deltaSample,2);
    
    
    if ImuLost.WhereLost.CutPointIndex > MaxforInterp
            
        ImuData{...
            lastSampleIndex+1 : lastSampleIndex + deltaSample,3:15} = ...
            nan.*ones(deltaSample,13);
        
    else
        
        ImuData = InterpLostData(ImuData,lastSampleIndex,deltaSample);
        
    end
end
end

