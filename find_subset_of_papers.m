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

% Select papers based on keywords
function  metadata_all_processed = find_subset_of_papers(metadata_all,filter_papers_keywords)

    metadata_all_processed = {};

    h = waitbar(0,'Extracting subset of relevant papers...');
    for i = 1:numel(metadata_all(:,1))
       keywords_all = [metadata_all{i,6}];
       for j = 1:numel(filter_papers_keywords)
           exists = sum(contains(keywords_all,lower(filter_papers_keywords{j})));
           if exists
               metadata_all_processed = [metadata_all_processed;metadata_all(i,:)];
               continue;
           end
       end
       waitbar(i/numel(metadata_all(:,1)))
    end
    close(h)

end