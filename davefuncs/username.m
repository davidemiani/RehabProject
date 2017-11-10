function user_name = username()
    if ispc
        user_name = getenv('USERNAME');
    else
        user_name = getenv('USER');
    end
end