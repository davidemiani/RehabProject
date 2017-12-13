function mustBePc()
%MUSTBEPC Validate that MATLAB is running on a PC (Windows) or issue error
%   MUSTBEPC() issues an error if MATLAB is not runnong on a PC (Windows).
%   MATLAB call ispc.
%
%   See also: ispc, mustBeMac
%
%   ------------------------------------
%   CREDITS:     Davide Miani (dec 2017)
%   LAST REVIEW: Davide Miani (dec 2017)
%   MAIL TO:     davide.miani2@gmail.com
%   ------------------------------------

if not(ispc)
    error('MATLAB:validators:mustBePc', ...
        'MATLAB must be running on a PC (Windows).');
end
end
