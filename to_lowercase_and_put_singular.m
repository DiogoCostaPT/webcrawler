
% Convert to singular words
function keyword_i = to_lowercase_and_put_singular(keyword_i)

    keyword_i = lower(keyword_i);
    if strcmp( keyword_i(end-1:end), 'es') && ~contains(keyword_i,'hydrates') && ~contains(keyword_i,'lakes') && ~contains(keyword_i,'services')
        keyword_i = keyword_i(1:end-2);
    elseif strcmp( keyword_i(end), 's') && ~contains(keyword_i,'mars') && ~contains(keyword_i,'analysis') && ~contains(keyword_i,'services') && ~contains(keyword_i,'activities')
        keyword_i = keyword_i(1:end-1);
    end

end