function cleanAngle = cleanAngleFromJump(angle, plotResults)
% clean angles from peaks caused by jumps (used in validation acquisitions 
% for knowing start and end of the exercize)
% INPUT:
%   - angle: array of the angle signal to clean
%   - plotResults: boolean; 1 if the plots of the angle and of the cleaned
%   angles are wanted; 0 otherwise.
% OUTPUT:
%   - cleanAngle: cleaned signal

[p, inds] = findpeaks(angle, 'MinPeakHeight', 150); % find peaks
nSamples = length(angle);
if length(inds) < 2
    indsDef = [inds nSamples];
else
    diffInds = diff(inds);
    [maxDiff, ind] = max(diffInds);
    if maxDiff > nSamples/2
        indsDef = [inds(ind) inds(ind+1)];
    else
        if inds(end) < nSamples/2
            indsDef = [inds(end) nSamples];
        else
            indsDef = [1 inds(1)];
        end
    end
end

cleanAngle = angle(indsDef(1):indsDef(2));

if plotResults
    figure
    subplot(211)
    plot(angle)
    hold on
    plot(inds, p, '*');
    hold off
    subplot(212)
    plot(cleanAngle)
    pause
    close
end
end

