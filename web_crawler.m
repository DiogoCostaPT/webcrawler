
% Options

% 1
search_engine_retrive_list_of_papers_and_urls = 0;  % carefull -> it will send requests to Science-Direct server
by_country = 0; % will only take the first entry of main_keyword_searchengine_raw_multiple and add the country names

%{
main_keyword_searchengine_raw_multiple = {'"climate change"';
%                                           '"climate change AND adaptation';
%                                           '"climate change AND vulnerability';
%                                           '"climate change AND "global warming"';
%                                           '"climate change AND "food security"';
%                                           '"climate change AND uncertainty';
%                                           '"climate change AND impact';
%                                           '"climate change AND mitigation';
%                                           '"climate change AND resilience';
%                                           '"climate change AND temperture'
                                  
%}

folder_name_to_store_results = 'nutrients_AND_climate_change';
main_keyword_searchengine_raw_multiple = {'"nutrients" AND "climate change"'
                                          %'permafrost AND Canada';...
                                          %'permafrost AND (chemistry OR biogeochemistry OR geochemistry)';...
                                          %'permafrost AND Canada AND (chemistry OR biogeochemistry OR geochemistry)'
                                          };                                  
 

%folder_name_to_store_results = 'great_lakes_AND_climate_change';
%main_keyword_searchengine_raw_multiple = {'"great lakes" AND "climate change"'
                                          %'permafrost AND Canada';...
                                          %'permafrost AND (chemistry OR biogeochemistry OR geochemistry)';...
                                          %'permafrost AND Canada AND (chemistry OR biogeochemistry OR geochemistry)'
%                                          };     

%folder_name_to_store_results = 'permafrost_AND_climate_change';
%main_keyword_searchengine_raw_multiple = {'"permafrost" AND "climate change"'
                                          %'permafrost AND Canada';...
                                          %'permafrost AND (chemistry OR biogeochemistry OR geochemistry)';...
                                          %'permafrost AND Canada AND (chemistry OR biogeochemistry OR geochemistry)'
 %                                         };     

                                          
% 2                                    
request_server_papers_in_list_save_htmls = 0; % carefull -> it will send requests to Science-Direct server

% 3
extract_papers_info = 0; 
force_overwrite = 1;

% 4
generate_reports = 1;
only_title_and_highlights = 1;

% 5
plot_paper_info_by_folder = 0; %1) # papers and keywords
filter_papers_keywords = {}; % if don't want to 
%filter_papers_keywords = {'biogeochemistry', 'geochemistry', 'chemistry', 'greenhouse', 'ion', 'anion',...
%        'cation','methane','mercur1y','carbon','organic','CO<sub>2</sub>','CH<sub>4</sub>''hydrate','gas','radiocarbon','hydrocarbon'};

% 6
plot_maps = 0;




%% If analysis by country
if by_country
   
    main_keyword_searchengine_raw_multiple = add_listing_countries(main_keyword_searchengine_raw_multiple{1});
    
end

mkdir('papers');
dir4search = ['papers/',folder_name_to_store_results];
mkdir(dir4search);


num_search_pages = 60;
show = 100;


%
pausetime = 10; % CAREFULL, DON'T PUT THIS LOWER THAN 10

%% EXTRACT LIST OF PAPERS
if search_engine_retrive_list_of_papers_and_urls

h = waitbar(0,'Extracting list of papers (STEP 1)');
set(h,'Position', [500 300 280 70]);

url_list_s = '';

for k = 1:numel(main_keyword_searchengine_raw_multiple)

    main_keyword_searchengine = main_keyword_searchengine_raw_multiple{k};
    main_keyword_searchengine = strrep(main_keyword_searchengine,' ','%20');

        url_list = {};
        offset = 0;         

        for p = 1:num_search_pages 

            waitbar(p/num_search_pages,h,...
                            {'Extracting list of papers (STEP 1)',...
                            ['Keyword combination = ',num2str(k),' out of ',num2str(numel(main_keyword_searchengine_raw_multiple))],...
                            ['ScienceDirect page: ', num2str(p),' out of ',num2str(num_search_pages)]});

            if ~isempty(url_list_s) || p==1

                try

                    url_query = ['https://www.sciencedirect.com/search/advanced?tak=',main_keyword_searchengine,'&show=',num2str(show),'&offset=',num2str(offset)];
                    html_raw = webread(url_query);
                    pause(pausetime);

                    start_key = 'href="/science/';
                    url_list_s = strfind(html_raw,start_key) + numel(start_key)-1;


                    for i = 1:numel(url_list_s)
                        temp = strfind(html_raw(url_list_s(i)+numel(url_list_s(i)):end),'" ');
                        url_list_e = url_list_s(i)+numel(url_list_s(i)) + temp(1) - 2;
                        add_port = html_raw(url_list_s(i):url_list_e);

                        if contains(add_port,'https')
                            continue
                        end

                        url_link_i = ['https://www.sciencedirect.com/science',add_port];
                        url_list = [url_list;url_link_i];

                    end
                    offset = show * p;
                catch
                    disp('> No more pages to search')
                    break;
                end
            end

        end

        if ~isempty(url_list)
            new_dir = [dir4search,'/',main_keyword_searchengine];   
            mkdir(new_dir);
            filesave_name = [new_dir,'/href_list'];
            save(filesave_name,'url_list');
        end

end
    close(h)
end


%% EXTRACT HTML
if request_server_papers_in_list_save_htmls 

    
foldernames = dir(dir4search);  
foldernames = {foldernames.name};
foldernames(strcmp(foldernames,'.')) = [];
foldernames(strcmp(foldernames,'..')) = [];
    
h = waitbar(0,'Extracting papers from lists - HTML (STEP 2)');
set(h,'Position', [500 300 280 70]);

fd = fopen('webcrawler.log','w');
for k = 1:numel(foldernames)

    
    new_dir = [dir4search,'/',foldernames{k}];   

    matfilename = [new_dir,'/href_list.mat'];

    try
        load(matfilename);
        options = weboptions('ContentType','text','RequestMethod','get');
       
        url_link_clean = {};
        %mkdir(folderpapers);
        files_list_raw = dir(new_dir);
        files_list = {files_list_raw.name};
        
        for  i = 1:1:numel(url_list)

            url_link = url_list{i};
            code_loc = strfind(url_link,'/');
            filename = url_link(code_loc(end)+1:end);
            exists_paper = ~isempty(find(contains(files_list,[filename,'.mat'])==1));
            isjournalref = contains(url_link,'/journal/');
            isnotpaper = contains(url_link,'.pdf');
            isrefworks = contains(url_link,'/referenceworks/');
            isbookseries = contains(url_link,'/bookseries/');
            isbook = contains(url_link,'/book/');

            if exists_paper
               url_link_clean = [url_link_clean,url_link];
               msg = ['> Had already been Saved: ',url_link];
               formatid = ['%s',num2str(numel(msg)),'\n'];
               disp(msg); 
               fprintf(fd,formatid,msg);
            elseif isjournalref || isnotpaper || isrefworks || isbookseries || isbook
               msg = ['> WARNING: Not a paper page (excluded): ',url_link];
               formatid = ['%s',num2str(numel(msg)),'\n'];
               disp(msg); 
               fprintf(fd,formatid,msg);
            else
                try
                    pause(pausetime);
                    html_data = webread(url_link,options);              
                    title_name = extractBetween(html_data,'<meta name="citation_title" content="','" />');
                    if ~isempty(title_name)
                        url_link_clean = [url_link_clean,url_link];
                        save([new_dir,'/',filename],'html_data');
                        msg = ['> Saved: ',url_link];
                        formatid = ['%s',num2str(numel(msg)),'\n'];
                       disp(msg); 
                       fprintf(fd,formatid,msg);
                    else
                        msg = ['> WARNING: Not a paper page (excluded): ',url_link];
                        formatid = ['%s',num2str(numel(msg)),'\n'];
                       disp(msg); 
                       fprintf(fd,formatid,msg);
                    end
                catch
                    msg = ['> WARNING: Server returned error: ',url_link];
                    formatid = ['%s',num2str(numel(msg)),'\n'];
                    disp(msg); 
                    fprintf(fd,formatid,msg);
                end
            end
            waitbar(i/numel(url_list),h,...
                            {'Extracting papers from lists - HTML (STEP 2)',...
                            ['Keyword combination = ',num2str(k),' out of ',num2str(numel(foldernames))],...
                            ['Paper: ', num2str(i),' out of ',num2str(numel(url_list))]});

        end
        
        
    catch
         msg = ['> WARNING: file not found: ',matfilename];
        formatid = ['%s',num2str(numel(msg)),'\n'];
        disp(msg); 
        fprintf(fd,formatid,msg);
    end

end
    fclose(fd);
    close(h)
end

    %% Extract paper info
if extract_papers_info

foldernames = dir(dir4search); 
dirFlags = [foldernames.isdir];
foldernames = foldernames(dirFlags);
foldernames = {foldernames.name};
foldernames(strcmp(foldernames,'.')) = [];
foldernames(strcmp(foldernames,'..')) = [];
    
h = waitbar(0,'Extracting info from papers-html (STEP 3)');
set(h,'Position', [500 300 280 70]);

metadata_all_list = {};

    for k = 1:numel(foldernames)

    %main_keyword_searchengine = main_keyword_searchengine_raw_multiple{k};
    %main_keyword_searchengine = strrep(main_keyword_searchengine,' ','%20');
    %folderpapers = ['papers/',main_keyword_searchengine];


    if by_country
        addwordi = "_by_cou0ntry";
    else
        addwordi = '';
    end
    try
       matfile = [dir4search,'/',foldernames{k},'/metadata_this_folder',addwordi,'.mat'];
       load(matfile);
       %extract_papers_info = 0; % no need to extract again
       if force_overwrite == 0
           disp(['WARNING: ',matfile,' file already exists -> force_overwrite not activated; skipped !'])
           enter_1 = 0;
       elseif force_overwrite == 1
           disp(['WARNING: ',matfile,' file already exists -> force_overwrite activated; overwritten !'])
           enter_1 = 1;
       end
    catch
       enter_1 = 1;
    end
 

        if enter_1
            metadata = {};
            
            %h = waitbar(0,'Extracting metadata for all papers...');
            db_i =  strrep(foldernames{k},' ','%20');
            dir_db = ['papers/',folder_name_to_store_results,'/',db_i];
            list_papers_raw = dir(dir_db);
           
            list_papers = {list_papers_raw.name};
            list_papers(strcmp(list_papers,'.')) = [];
            list_papers(strcmp(list_papers,'..')) = [];
            list_papers(strcmp(list_papers,'href_list.mat')) = [];
            list_papers(strcmp(list_papers,'metadata_this_folder.mat')) = [];

            for i = 1:1:numel(list_papers)
                
                if i == 1
                %metadata_all_cell = {};
                metadata_all_list = [metadata_all_list;{foldernames{k},'-','-','-','-','-','-','-','-','-'}];
                end

                list_papers_i = list_papers{i};

                metadata_i = article_data_extract(dir_db,list_papers_i);
                if ~isempty(metadata_i)
                    metadata = [metadata;metadata_i]; 
                end  
                waitbar(i/numel(list_papers),h,...
                            {'Extracting info from papers-html (STEP 3)',...
                            ['Keyword combination = ',num2str(k),' out of ',num2str(numel(foldernames))],...
                            ['Paper: ', num2str(i),' out of ',num2str(numel(list_papers))]});
            end
            if ~isempty(metadata)
                if contains(db_i,'%20AND%20')
                    db_i = extractAfter(db_i,'%20AND%20');               
                end
                add_new_dataset = [cell(numel(metadata(:,1)),1),metadata];
                metadata_all_list = [metadata_all_list;add_new_dataset];
                add_new_dataset_to_print = add_new_dataset(:,2:end);
                save([dir4search,'/',foldernames{k},'/metadata_this_folder',addwordi,'.mat'],'add_new_dataset_to_print'); 
            end

        
    if by_country
        addwordi = '_by_country';
    else
        addwordi = '';
    end
    %save([dir4search,'/metadata_all_list',addwordi,'.mat'],'metadata_all_list'); 
    metadata_all_list_table = cell2table(metadata_all_list);
    metadata_all_list_table.Properties.VariableNames = {'Search_Keys',...
                                                        'Paper_title',...
                                                        'Year',...
                                                        'Journal_name',...
                                                        'Type_of_Publication',...
                                                        'Authors',...
                                                        'Keywords',...
                                                        'Abstract',...
                                                        'Highlights',...
                                                        'URL'
                                                        };
    
    writetable(metadata_all_list_table,[dir4search,'/metadata_all_list',addwordi,'.csv'],'Delimiter',';'); 
    
        end
    end
    close(h)

    end

    %% Process results
    if plot_paper_info_by_folder

h = waitbar(0,'Extracting list of papers...');
set(h,'Position', [500 300 280 70]);

for k = 1:numel(main_keyword_searchengine_raw_multiple)

    %foldernames = dir(dir4search);  
    %foldernames = {foldernames.name};
    %foldernames(strcmp(foldernames,'.')) = [];
    %foldernames(strcmp(foldernames,'..')) = [];

        try
           csvfile = [dir4search,'/metadata_all_list.csv'];
           metadata_all_list_table = readtable(csvfile);
        catch
            flag1 = exist('metadata_all');
            if flag1 == 0
                disp(['WARNING: ',matfile,' file not found -> need to run first the extract_papers_info function'])
                enter_2 = 0;
            else
                enter_2 = 1;
            end
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
        year_data = str2double(metadata_all_list_table.Year);
        year_data_unique = unique(year_data);
        year_data_unique(year_data_unique == 9999) = [];
        year_data_unique(isnan(year_data_unique)) = [];
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
    end
    
% Generate report
if generate_reports
    
     try
           csvfile = [dir4search,'/metadata_all_list.csv'];
           metadata_all_list_table = readtable(csvfile);
           enter_2 = 1;
        catch
            flag1 = exist('metadata_all');
            if flag1 == 0
                disp(['WARNING: ',matfile,' file not found -> need to run first the extract_papers_info function'])
                enter_2 = 0;
            end
     end
        
     if enter_2
                                      
         % order the entries by year, but respecting the different search
         % words
         intervals4easchsearch = find(~cellfun(@isempty,table2cell(metadata_all_list_table(:,1))));
         allyears = str2double(metadata_all_list_table.Year);
         index_order = [];
         if numel(intervals4easchsearch) > 1 % whith country analysis
             for i=1:numel(intervals4easchsearch)-1
                 index_order = [index_order;intervals4easchsearch(i)];
                 range_i_years = allyears(intervals4easchsearch(i)+1:intervals4easchsearch(i+1)-1);
                 [range_i_years_order range_i_years_order_loc]= sort(range_i_years,'descend');
                 index_order = [index_order;intervals4easchsearch(i)+range_i_years_order_loc];
             end
         else  % no coutry analysis
              [range_i_years_order range_i_years_order_loc]= sort(allyears,'descend');
              index_order = range_i_years_order_loc;
         end
         
         % start report                                  
         h1 = waitbar(0,'Writting report...');
         set(h1,'Position', [500 300 280 70]);
         itemnum_global = 0;
         itemnum_local = 0;
         flag_general_country = 0;
         flag_open_countryonce = 0;
         
         if only_title_and_highlights
              add_text = '_simplified';
         else
             add_text = '';
         end
         
         for r=1:numel(metadata_all_list_table(:,1))
             try
                 i = index_order(r);
             catch
                 continue
             end     
                         
            paper_table_i = metadata_all_list_table(i,:);
            
            if ~isempty(char(paper_table_i.Search_Keys))
                
                
                 if flag_general_country == 0
                    fid=fopen([dir4search,'/GENERAL_report_',folder_name_to_store_results,add_text,'.docx'],'w');
                    flag_general_country = 1;
                 else
                     if flag_open_countryonce == 0
                        fclose(fid);
                        fid=fopen([dir4search,'/byCOUNTRY_report_',folder_name_to_store_results,add_text,'.docx'],'w');
                        flag_open_countryonce = 1;
                     end
                 end
                
                 fprintf(fid, '%s\n', '===================================================================================');
                 print_searchwords = strrep(char(paper_table_i.Search_Keys),'%20',' ');
                 fprintf(fid, '%s\n\t', ['---->	SEARCH WORDS -> ',print_searchwords]);
                 if only_title_and_highlights
                     fprintf(fid, '%s\n\t', 'Simplified report: only title and highlights');
                 end
                fprintf(fid, '%s\n', '===================================================================================');
                fprintf(fid, '%s\n','Starting list...');
                fprintf(fid, '%s\n','');
                itemnum_local = 0;
            else
                
                itemnum_global = itemnum_global + 1;
                itemnum_local = itemnum_local + 1;
                
                % Paper type, title and year
                fprintf(fid, '%s\n','%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
                fprintf(fid, '%s\n',['ITEM_',num2str(itemnum_global)]);
                fprintf(fid, '%s\n','-----------------------------------------------------------------------------------');
                writetext = [upper(paper_table_i.Type_of_Publication{:}),' (Year: ',paper_table_i.Year{:},')'];
                fprintf(fid, '%s\n\n', writetext);
                writetext = paper_table_i.Paper_title{:};
                fprintf(fid, '%s\n\n', writetext);
                fprintf(fid, '%s\n','-----------------------------------------------------------------------------------');
                fprintf(fid, '%s\n', 'Highlights: ');
                
                % add highlights
                for h = 1:numel(metadata_all_list_table(1,9:end-1))
                     writetext = char(metadata_all_list_table{i,8+h});
                     writetext = strtrim(writetext);
                     if ~isempty(writetext)
                        fprintf(fid, '%s\n', ['- ',writetext]);
                     end
                end
                fprintf(fid, '%s\n','');
                
                if ~only_title_and_highlights
                    % add abstract
                    fprintf(fid, '%s','');
                    fprintf(fid, '%s\n','-----------------------------------------------------------------------------------');
                    fprintf(fid, '%s\n', 'Abstract: ');
                    writetext = char(metadata_all_list_table{i,8});
                    writetext = strtrim(writetext);
                    fprintf(fid, '%s','');
                    fprintf(fid, '%s\n', writetext);
                     %fprintf(fid, '%s\n', '-----------------------');
                    fprintf(fid, '%s\n','');
                end
                
                % add url
                fprintf(fid, '%s\n','-----------------------------------------------------------------------------------');
                fprintf(fid, '%s\n', 'URL: ');
                writetext = char(metadata_all_list_table{i,end});
                fprintf(fid, '%s\n', [writetext,' ']);
                
                % Print search words
                fprintf(fid, '%s\n','-----------------------------------------------------------------------------------');
                fprintf(fid, '%s\n\t', ['SEARCH WORDS: ', print_searchwords]);
                fprintf(fid, '%s\n', ['  item: ', num2str(itemnum_local)]);
                fprintf(fid, '%s\n','-----------------------------------------------------------------------------------');
                fprintf(fid, '%s\f', '');
                
                                
            end
            waitbar(r/numel(metadata_all_list_table(:,1)));
         end
         try 
             fclose(fid);
         catch
         end
         close(h1);
         
     end
    
end


%%
if plot_maps
    
    
    foldernames = dir(dir4search);  
    foldernames = {foldernames.name};
    foldernames(strcmp(foldernames,'.')) = [];
    foldernames(strcmp(foldernames,'..')) = [];
    foldernames_firstgeneral = foldernames{1};
    
    %try
        %matfile = ['metadata_all_',main_keyword_searchengine_raw_multiple{1},'_by_country.mat'];
        %load(matfile);
    %    csvfile = [dir4search,'/metadata_all_list.csv'];
    %    metadata_all_list_table = readtable(csvfile);
    %catch
    %    disp(['Err: ',[dir4search,'/metadata_all_list.csv'],' file not found -> need to run first the extract_papers_info function'])
    %    return;
    %end

    latlon = readtable('countries_lat_lon.xlsx');
    %db_names = fieldnames(metadata_all_cell);
    
    latlon_cell = table2cell(latlon);
    geoinfo_a = {};
    
    num_popular_keywords_search_within_country_step1 = 30;
    num_popular_keywords_all_country_specific_results_step2 = 30;
    
    keywords_popular = {};
    countname_found = {};
    
    % Loop over the data extracted to look for information by country
    for s=1:numel(foldernames)
        
        db_name_i = foldernames{s};
        
        countname = db_name_i;
        countname = strrep(countname,foldernames_firstgeneral,'');
        countname = strrep(countname,'%20AND%20','');
        countname = strrep(countname,'%20',' ');
                
        iloc = find(contains(latlon_cell(:,1),countname)==1);
        
        if ~isempty(countname) && ~isempty(iloc)
            
            load([dir4search,'/',foldernames{s},'/metadata_this_folder.mat']); 
            
            countname_found = [countname_found,countname];
            
            metadata_i = add_new_dataset_to_print;
            
            % Coordinats
            lat_i = latlon_cell{iloc,2};
            lon_i = latlon_cell{iloc,3};
            
            % Number of papers
            numpaper = numel(metadata_i(:,1));
            
            % Keywords (find main key words for all countries)
            keywords_all = {metadata_i{:,6}};
            keywords_all_clean = split_entries(keywords_all,',');
            [C,ia,ic] = unique(keywords_all_clean);
            if isempty(C)
                continue;
            end
            a_counts = accumarray(ic,1);
            [a_counts_sort,a_counts_index] = sort(a_counts,'descend');
            C_sort = C(a_counts_index);
            a_counts_sort = a_counts(a_counts_index);
            c_sort_range = min(num_popular_keywords_search_within_country_step1,numel(C_sort(1,:)));
            keywrd_pop = [C_sort(1:c_sort_range)',...
                            num2cell(a_counts_sort(1:c_sort_range))];
            keywords_popular = [keywords_popular;keywrd_pop];
             
            tabl1 = table(C',a_counts);
            
            new_entry = {countname,lat_i,lon_i,numpaper};
            geoinfo_a = [geoinfo_a;new_entry];
        end
    end
    
    %% PLOT MAP with Number of papers
    figure
    geoinfo_tbl = cell2table(geoinfo_a);
    gb = geobubble(geoinfo_tbl.geoinfo_a2,geoinfo_tbl.geoinfo_a3,geoinfo_tbl.geoinfo_a4)
    title(['# Papers (Search words: ',dir4search(8:end),')']);%,'Interpreter','none')
    %title('Number of papers')
    
    % PLOT MAP with main keywords 
    %% Keywords (most popular) all together
    remove_searchwords = erase(main_keyword_searchengine_raw_multiple{1},'"');
    remove_searchwords = split(remove_searchwords,' AND ');
    
    for d = 1:numel(remove_searchwords)
        keywords_popular_proc1 = keywords_popular(...
                             find(~contains(keywords_popular(:,1),remove_searchwords{d})==1),:); % remove climate change
    end
      keywords_popular_proc2 = {};
    
    % remove names of countried from keywords
    countname_found = {};
    for w=1:numel(keywords_popular_proc1(:,1))     
        iloc = find(contains(lower(countname_found),keywords_popular_proc1(w,1))==1);  
        if isempty(iloc)
            new_entry_cnddt = keywords_popular_proc1(w,:);
            if w > 1
                iloc2 = find(strcmp(lower(keywords_popular_proc2(:,1)),...
                            new_entry_cnddt(1))==1);
            else
                iloc2 = [];
            end
            % if keywords repeats, don't add a new entry but sum the number
            % to the existing entry (critical to avoid repetitions)
            if isempty(iloc2)
                keywords_popular_proc2 = [keywords_popular_proc2;new_entry_cnddt];
            else
                keywords_popular_proc2{iloc2,2} = keywords_popular_proc2{iloc2,2} +...
                                                    new_entry_cnddt{2};
            end
        end
    end
    
    % sorting and taken most popular words - for all countries (setp 2) 
    [a_counts_sort,a_counts_index] = sort([keywords_popular_proc2{:,2}]','descend');
    C_sort = keywords_popular_proc2(a_counts_index,:);
    keywrd_pop = C_sort(1:num_popular_keywords_all_country_specific_results_step2,:);

    %keywrd_pop = removekeywords();
    % now create the table with the information of # of priorities
    % Loop over the data extracted to look for information by country (WITH
   
    figure
    numplots = numel(keywrd_pop(:,1));
    numsubplots = ceil(numplots^0.5);
    for p=1:numel(keywrd_pop(:,1))
        numplot_i = numplots - p +1;
         geoinfo_b = {};
         countname_found = {};
        for s=1:numel(foldernames)
            %subplot(ceil(keywrd_pop^0.5,keywrd_pop^0.5,s))
                 
            db_name_i = foldernames{s};
        
            countname = db_name_i;
            countname = strrep(countname,foldernames_firstgeneral,'');
            countname = strrep(countname,'%20AND%20','');
            countname = strrep(countname,'%20',' ');
        
            iloc = find(contains(latlon_cell(:,1),countname)==1);
            
            if ~isempty(countname) && ~isempty(iloc)
                
                load([dir4search,'/',foldernames{s},'/metadata_this_folder.mat']); 
                countname_found = [countname_found,countname];
                metadata_i = add_new_dataset_to_print;
                
                % Coordinates
                lat_i = latlon_cell{iloc,2};
                lon_i = latlon_cell{iloc,3};

                % Joining all keywords and removing search words
                keywords_all = [];
                for w = 1:numel(metadata_i(:,6))
                    new_keyword_group = metadata_i(w,6);
                    if ~isempty(new_keyword_group{:})
                        % Removing search words
                        for d = 1:numel(remove_searchwords)
                            new_keyword_group = new_keyword_group(...
                                     find(~contains(new_keyword_group,remove_searchwords{d})==1)); 
                        end
                        keywords_all = [keywords_all,new_keyword_group{:},', '];
                    end
                    keywords_all = strrep(keywords_all,' ,','');
                end
                keywords_all = keywords_all(1:end-2);
                
    
                if ~isempty(keywords_all)
                    keywrd_pop_i = keywrd_pop{p,1};
                    iloc2 = find(contains(split(keywords_all,', '),keywrd_pop_i)==1);
                    numpaper = numel(iloc2);
                    if numpaper> 0
                        new_entry = {countname,lat_i,lon_i,numpaper,keywrd_pop_i};
                        geoinfo_b = [geoinfo_b;new_entry];
                    end
                end
                
            end
        end

        geoinfo_tbl2 = cell2table(geoinfo_b);
        if ~isempty(geoinfo_tbl2)
            geoinfo_tbl2.geoinfo_b5 = categorical(geoinfo_tbl2.geoinfo_b5);
            %subplot(numsubplots,numsubplots,p)
            subplot(6,5,p)
            %gb2 = geobubble(geoinfo_tbl2.geoinfo_b2,geoinfo_tbl2.geoinfo_b3,geoinfo_tbl2.geoinfo_b4,geoinfo_tbl2.geoinfo_b5,'Title',keywrd_pop_i);
            %figure
            gb2 = geobubble(geoinfo_tbl2.geoinfo_b2,geoinfo_tbl2.geoinfo_b3,geoinfo_tbl2.geoinfo_b4,'Title',keywrd_pop_i); 
            %gb2.BubbleColorList = hsv(num_popular_keywords_all_country_specific_results_step2);
            gb2.LegendVisible = 'on';
           geolimits([-65.3755824380055 78.2066372893149],...
                    [-120.817557389549 141.603209036912]);
            %title('Number of papers')
        end
    end
    
end

