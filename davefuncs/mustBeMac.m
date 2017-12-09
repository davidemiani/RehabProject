function mustBeMac()
%MUSTBEMAC Validate that MATLAB is running on a Mac or issue error
%   MUSTBEMAC() issues an error if MATLAB is not runnong on a MAC.
%   MATLAB call ismac.
%
%   See also: ismac, mustBePc
%
%   ------------------------------------
%   CREDITS:     Davide Miani (dec 2017)
%   LAST REVIEW: Davide Miani (dec 2017)
%   MAIL TO:     davide.miani2@gmail.com
%   ------------------------------------

if not(ismac)
    error('MATLAB:validators:mustBeMac', ...
        'MATLAB must be running on a Mac.');
end
end
