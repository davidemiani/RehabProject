function tab = exelLog2table(logpath,AccFs,GyrFs)
%EXELLOG2TABLE verts exel log to MATLAB data table.
%   TAB = EXELLOG2TABLE(LOGPATH,ACCFS,GYRFS)
%   -------------------------------------------
%   INPUTS:
%   * LOGPATH: a valid exel log path;
%   * ACCFS: accelerometer full scale;
%   * GYRFS: gyroscope full scale.
%   OUTPUT:
%   * TAB: verted MATLAB table.
%   -------------------------------------------
%   CREDITS:
%   Davide Miani (nov 2017)
%   -------------------------------------------
%   LAST REVIEW:
%   Davide Miani (nov 2017)
%   -------------------------------------------
%   MAIL TO:
%   * davide.miani2@gmail.com
%   -------------------------------------------
%   -------------------------------------------

% if less number of inputs, setting default values
if nargin < 3
    GyrFs = 250;
end
if nargin < 2
    AccFs = 2;
end

% setting Ka, Kg, Km and qn
Ka = AccFs * 9.807 / 32768;
Kg = GyrFs / 32768;
Km = 0.007629;
qn = 1 / 16384;

% verting log to table
tab = readtable(logpath);

% verting Acc
tab.AccX = tab.AccX * Ka;
tab.AccY = tab.AccY * Ka;
tab.AccZ = tab.AccZ * Ka;

% verting Gyr
tab.GyrX = tab.GyrX * Kg;
tab.GyrY = tab.GyrY * Kg;
tab.GyrZ = tab.GyrZ * Kg;

% verting Mag
tab.MagX = tab.MagX * Km;
tab.MagY = tab.MagY * Km;
tab.MagZ = tab.MagZ * Km;

% verting quaternions
tab.Q0 = tab.Q0 * qn;
tab.Q1 = tab.Q1 * qn;
tab.Q2 = tab.Q2 * qn;
tab.Q3 = tab.Q3 * qn;
end
