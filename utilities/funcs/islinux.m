function bool = islinux
if isunix && not(ismac)
    bool = true;
else
    bool = false;
end