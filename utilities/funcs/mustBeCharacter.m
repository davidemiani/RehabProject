function mustBeCharacter(A)
%MUSTBECHARACTER Validate that value is character or issue error
%   MUSTBECHARACTER(A) issues an error if A contains noncharacter values.
%   MATLAB call ischar, isstring, and iscellstr to determine if a value is
%   character.
%
%   See also: ischar, iscellstr, isstring, mustBeChar
%
%   ------------------------------------
%   CREDITS:     Davide Miani (dec 2017)
%   LAST REVIEW: Davide Miani (dec 2017)
%   MAIL TO:     davide.miani2@gmail.com
%   ------------------------------------

if not(ischar(A) || isstring(A) || iscellstr(A))
    error('MATLAB:validators:mustBeCharacter', ...
        'Value must be character (char, string or cell of char).');
end
end

