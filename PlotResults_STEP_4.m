
function PlotResults_STEP_4(main_keyword_searchengine_raw_multiple,dir4search)

h = waitbar(0,'Extracting list of papers...');
set(h,'Position', [500 300 280 70]);

for k = 1:numel(main_keyword_searchengine_raw_multiple)

    foldernames_raw = dir(dir4search);  
    foldernames = {foldernames_raw.name};
    foldernames(strcmp(foldernames,'.')) = [];
    foldernames(strcmp(foldernames,'..')) = [];
    
    % Remove files from list
    isfolder_all = [];
    for i = 1:numel(foldernames)
        isfolder_i = isdir([dir4search,'/',foldernames{i}]);
        isfolder_all = [isfolder_all,isfolder_i];
    end
    foldernames = foldernames(find(isfolder_all == 1));
    
        try
           matfile = [dir4search,'/metadata_all_list.mat'];
           %metadata_all_list_table = readtable(csvfile,'delimiter','bar');
           load(matfile);
        catch
           disp(['WARNING: ',matfile,' file not found -> need to run first the extract_papers_info function'])
           return
        end

        if isempty(metadata_all_list_table)
           disp(['WARNING: ',csvfile,' file was found but is empty -> need to run the extract_papers_info function'])
           return
        end
        
        %db_names = fieldnames(metadata_all_list);
        %db_name_i = db_names{k};
        %metadata = metadata_all_cell.(genvarname(db_name_i))

        %metadata_all_processed = {};
        %if isempty(filter_papers_keywords)
        %    metadata_all_processed = metadata;
        %else
        %    metadata_all_processed = find_subset_of_papers(metadata,filter_papers_keywords);
        %end

        % Year
        year_data = metadata_all_list_table.Year;
        year_data(strcmp(year_data,'-')) = [];
        year_data(strcmp(year_data,'not found')) = [];
        year_data = [year_data{:}];    
        year_data(year_data == 9999) = [];
        year_data(year_data == -9999) = [];
        year_data(isnan(year_data)) = [];
        year_data_unique = unique(year_data);
        
        
        figure
        hist(year_data,numel(year_data_unique));
        h1 = findobj(gca,'Type','patch');
        set(h1,'FaceColor',[0.5 0.5 0.5],'EdgeColor','k')
        grid on
        title(['Publication year (Search words: ',dir4search(8:end),')'],'Interpreter', 'none');
        ylabel('# of publications')

        % Journal  
        journals_all = metadata_all_list_table.Journal_name;
        [journal_list,ia,ic] = unique(journals_all);
        a_counts = accumarray(ic,1);
        tabl1 = table(journal_list,a_counts);
        %tabl1 = tabl1(cellfun(@isempty, strfind(tabl1.Var1, 'permafrost')), :);
        %tabl1 = tabl1(cellfun(@isempty, strfind(tabl1.Var1, 'Permafrost')), :);
        figure
        wordcloud(tabl1,'journal_list','a_counts')
        title(['Main journals (Search words:',dir4search(8:end),')']);

        % Type of paper
        [uni,~,idx] = unique(metadata_all_list_table.Type_of_Publication);
        figure
        hist(idx,unique(idx))
        h3 = findobj(gca,'Type','patch');
        set(h3,'FaceColor',[0.5 0.5 0.5],'EdgeColor','k')
        set(gca,'xtick',[1:numel(uni)],'xticklabel',uni)
        xtickangle(65)
        grid on
        title(['Type of paper (Search words: ',dir4search(8:end),')'],'Interpreter', 'none');
        ylabel('# of publications')

        % Keywords
        keywords_all = metadata_all_list_table.Keywords;
        keywords_all_clean = split_entries(keywords_all,',');
        [C,ia,ic] = unique(keywords_all_clean);
        a_counts = accumarray(ic,1);
        tabl1 = table(C',a_counts);
        
        % remove search words, otherwise those will be the main keywords
        seach_words_cell = split_entries(main_keyword_searchengine_raw_multiple,' AND ');
        for g=1:numel(seach_words_cell)
            seach_words_cell_i = seach_words_cell{g};
            remove_apostr = strfind(seach_words_cell_i,'"');
            seach_words_cell_i(remove_apostr) = [];
            tabl1 = tabl1(cellfun(@isempty, strfind(tabl1.Var1, seach_words_cell_i)), :);
        end
        
        tabl1 = tabl1(cellfun(@isempty, strfind(tabl1.Var1, 'permafrost')), :);
        tabl1 = tabl1(cellfun(@isempty, strfind(tabl1.Var1, 'Permafrost')), :);
        % filtering bad results
        remove_row = [];
        for r = 1:numel(tabl1(:,1))
            try
               tabl1_i = tabl1(r,:);
               if (contains(tabl1_i.Var1,char(10)) || numel(tabl1_i.Var1) > 50)
                   remove_row = [remove_row,r];
               end
            catch
            end
        end
        tabl1(remove_row,:) = [];
        figure
        wordcloud(tabl1,'Var1','a_counts')
        title(['Keywords (Search words: ',dir4search(8:end),')']);

        % Authors
        %authors_all = [metadata_all_processed{:,5}];
        %[C,ia,ic] = unique(authors_all);
        %a_counts = accumarray(ic,1);
        %tabl1 = table(C',a_counts);
        %tabl1 = tabl1(cellfun(@isempty, strfind(tabl1.Var1, 'permafrost')), :);
        %tabl1 = tabl1(cellfun(@isempty, strfind(tabl1.Var1, 'Permafrost')), :);
        %figure
        %wordcloud(tabl1,'Var1','a_counts')
        %title(['Main Authors (',db_name_i,')'])
end
close(h)