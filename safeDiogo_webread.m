
% Make sure to stop for while between requests

function htlm_raw = safeDiogo_webread(url_query,pausetime)
                 
    MINpause = 5; % for safety
    htlm_raw = webread(url_query);
    pause(max(pausetime,MINpause));

end