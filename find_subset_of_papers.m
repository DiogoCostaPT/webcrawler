
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