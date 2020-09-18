
function keywords_all_clean = remove_longchar_entries(keywords_all)

list = keywords_all;
keywords_all_clean = {};

 h = waitbar(0,'Inspecting-Cleaning keyword entries...');
for i=1:numel(keywords_all)
    list_i = deblank(keywords_all{i}); % removes trailing whitespace and null characters
    contain_newline = contains(list_i,'\n');
    if numel(list_i)<50 && ~contain_newline
        keywords_all_clean = [keywords_all_clean,list_i];
    end
    waitbar(i/numel(keywords_all))
end
close(h)

end