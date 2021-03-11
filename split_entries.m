%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2021, Diogo Costa, diogo.pinhodacosta@canada.ca
% This file is part of WebCrawler tool.

% This program, WebCrawler tool, is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) later version.

% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function keywords_all_clean = split_entries(keywords_all,delimiter)

list = keywords_all;
keywords_all_clean = {};

 h = waitbar(0,'Inspecting-Cleaning keyword entries...');
for i=1:numel(keywords_all)
    list_i = deblank(keywords_all{i}); % removes trailing whitespace and null characters
    try
        list_i = [list_i{:}];
    catch
    end
    
    if (strcmp(list_i,'-'))
        continue;
    end
    
    loc_new_keyword = strfind(list_i,delimiter);
    
    if loc_new_keyword > 0
        numkeywords = numel(loc_new_keyword) + 1;
        % first keyword
        list_ii = list_i(1:loc_new_keyword(1)-1);
        keywords_all_clean = [keywords_all_clean,list_ii];
        % middle keywords
        for l = 1:numel(loc_new_keyword)-1
            list_ii = list_i(loc_new_keyword(l)+numel(delimiter)+1:loc_new_keyword(l+1)-1);
            keywords_all_clean = [keywords_all_clean,list_ii];
        end
        % last keywords
        list_ii = list_i(loc_new_keyword(end)+numel(delimiter)+1:end);
        keywords_all_clean = [keywords_all_clean,list_ii];
    end
    waitbar(i/numel(keywords_all))
end
close(h)

end