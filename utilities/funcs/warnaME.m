function warnaME(ME)
    cprintf('comment','Warning: an error occurred in try-catch statement.')
    fprintf('\n')
    cprintf('comment','%s\n',ME.message)
    for k=1:numel(ME.stack)
        cprintf('comment','> In ')
        cprintf('-comment',ME.stack(k,1).name)
        cprintf('comment',' (line %s)\n',num2str(ME.stack(k,1).line))
    end
    fprintf('\n')
end