function path = csd()
%CSD current script directory
    stack = dbstack;
    path = fileparts(which(stack(end).file));
end