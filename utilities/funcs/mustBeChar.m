function mustBeChar(A)
%MUSTBECHAR Validate that value is char or issue error
%   MUSTBECHARACTER(A) issues an error if A contains non char values.
%   MATLAB call ischar to determine if a value is char.
%
%   See also: ischar, mustBeCharacter
%
%   ------------------------------------
%   CREDITS:     Davide Miani (dec 2017)
%   LAST REVIEW: Davide Miani (dec 2017)
%   MAIL TO:     davide.miani2@gmail.com
%   ------------------------------------

if not(ischar(A))
    error('MATLAB:validators:mustBeChar', ...
        'Value must be char.');
end
end
