function matcell = textfile2matcell(textfile)
matcell = {};
fid = fopen(textfile,'r');
if fid ~= -1
    while feof(fid) == 0
        matcell = cat(1,matcell,fgetl(fid));
    end
    fclose(fid);
end
end