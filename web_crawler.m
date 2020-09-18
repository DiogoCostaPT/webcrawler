
% Options

% 1
search_engine_retrive_list_of_papers_and_urls = 1;  % carefull -> it will send requests to Science-Direct server
by_country = 1; % will only take the first entry of main_keyword_searchengine_raw_multiple and add the country names

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
                                          };
extractstring = 'x0x22climate0x2520change0x220x2520AND0x2520';                                      
%}

folder_name_to_store_results = 'permafrost_AND_climate_change';
main_keyword_searchengine_raw_multiple = {'permafrost AND "climate change"'
                                          %'permafrost AND Canada';...
                                          %'permafrost AND (chemistry OR biogeochemistry OR geochemistry)';...
                                          %'permafrost AND Canada AND (chemistry OR biogeochemistry OR geochemistry)'
                                          };                                  
extractstring = 'x0x22permafrost0x220x2520AND0x2520';

%main_keyword_searchengine_raw_multiple = {'%22groudwater%22';
                                          %'permafrost AND Canada';...
                                          %'permafrost AND (chemistry OR biogeochemistry OR geochemistry)';...
                                          %'permafrost AND Canada AND (chemistry OR biogeochemistry OR geochemistry)'
                                         % };                                  
%extractstring = 'x0x22groudwater0x220x2520AND0x2520';
                                          
% 2                                    
request_server_papers_in_list_save_htmls = 0; % carefull -> it will send requests to Science-Direct server

% 3
extract_papers_info = 0; 

% 4
plot_paper_info_by_folder = 0; %1) # papers and keywords
filter_papers_keywords = {}; % if don't want to 
%filter_papers_keywords = {'biogeochemistry', 'geochemistry', 'chemistry', 'greenhouse', 'ion', 'anion',...
%        'cation','methane','mercury','carbon','organic','CO<sub>2</sub>','CH<sub>4</sub>''hydrate','gas','radiocarbon','hydrocarbon'};

% 5
plot_maps = 0;





%% If analysis by country
if by_country
   
    main_keyword_searchengine_raw_multiple = add_listing_countries(main_keyword_searchengine_raw_multiple{1});
    
end

mkdir('papers');
dir4search = ['papers/',folder_name_to_store_results];
mkdir(dir4search);

try
    for k = 1:numel(main_keyword_searchengine_raw_multiple)

        main_keyword_searchengine = main_keyword_searchengine_raw_multiple{k};

        %%
        main_keyword_searchengine = strrep(main_keyword_searchengine,' ','%20');

        folderpapers = ['papers/',main_keyword_searchengine];

        %% Extract list of papers with keyword
        if search_engine_retrive_list_of_papers_and_urls


            show = 100;
            num_search_pages = 60;
            url_list = {};
            offset = 0;
            h = waitbar(0,{'Extracting list and links to papers with keyword: ',main_keyword_searchengine});
            set(h,'Position', [500 300 500 50]);

            for p = 1:num_search_pages 

                pause(10);
                try
                    url_query = ['https://www.sciencedirect.com/search/advanced?tak=',main_keyword_searchengine,'&show=',num2str(show),'&offset=',num2str(offset)];
                    html_raw = webread(url_query);

                    start_key = 'href="/science/';
                    url_list_s = strfind(html_raw,start_key) + numel(start_key)-1;
                    
                    if isempty(url_list_s)
                        break;
                    end

                    for i = 1:numel(url_list_s)
                        temp = strfind(html_raw(url_list_s(i)+numel(url_list_s(i)):end),'" ');
                        url_list_e = url_list_s(i)+numel(url_list_s(i)) + temp(1) - 2;
                        add_port = html_raw(url_list_s(i):url_list_e);

                        if contains(add_port,'https')
                            continue
                        end

                        url_link_i = ['https://www.sciencedirect.com/science',add_port];
                        url_list = [url_list;url_link_i];
                        waitbar(p/num_search_pages,h,...
                            {['Keyword combination = ',num2str(k),' out of ',num2str(numel(main_keyword_searchengine_raw_multiple))],...
                            ['ScienceDirect page: ', num2str(p),' out of ',num2str(num_search_pages)]});
                    end
                    offset = show * p;
                catch
                    disp('> No more pages to search')
                    break;
                end
            end
            close(h)
            new_dir = [dir4search,'/',main_keyword_searchengine];   
            mkdir(new_dir);
            filesave_name = [new_dir,'/href_list'];
            save(filesave_name,'url_list');

        end

        % Extract html
        if request_server_papers_in_list_save_htmls 

            matfilename = [filesave_name,'.mat']; 
            load(matfilename);
            options = weboptions('ContentType','text','RequestMethod','get');
            h = waitbar(0,'Saving papers html...');
            url_link_clean = {};
            %mkdir(folderpapers);
            files_list_raw = dir(folderpapers);
            files_list = {files_list_raw.name};
            fd = fopen('webcrawler.log','w');
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
                   msg = ['> Saved: ',url_link];
                   formatid = ['%s',num2str(numel(msg)),'\n'];
                   disp(msg); 
                   fprintf(fd,formatid,msg);
                elseif isjournalref || isnotpaper || isrefworks || isbookseries || isbook
                   msg = ['> ERR: Not a paper page (excluded): ',url_link];
                   formatid = ['%s',num2str(numel(msg)),'\n'];
                   disp(msg); 
                   fprintf(fd,formatid,msg);
                else
                    try
                        pause(20);
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
                            msg = ['> ERR: Not a paper page (excluded): ',url_link];
                            formatid = ['%s',num2str(numel(msg)),'\n'];
                           disp(msg); 
                           fprintf(fd,formatid,msg);
                        end
                    catch
                        msg = ['> ERR: Server returned error: ',url_link];
                        formatid = ['%s',num2str(numel(msg)),'\n'];
                        disp(msg); 
                        fprintf(fd,formatid,msg);
                    end
                end
                waitbar(i/numel(url_list))

            end
            close(h)
            fclose(fd);

        end

        %% Extract paper info
        if extract_papers_info
            
            if k == 1
                if by_country
                    addwordi = "_by_country";
                else
                    addwordi = '';
                end
                try
                   matfile = ['metadata_all_',main_keyword_searchengine_raw_multiple{1},addwordi,'.mat'];
                   load(matfile);
                   extract_papers_info = 0; % no need to extract again
                   disp(['Err: ',matfile,' file already exists -> no need to run again the extract_papers_info function'])
                   enter_1 = 0;
                catch
                   enter_1 = 1;
                end
            end
            
            if enter_1
                metadata = {};
                if k == 1
                    metadata_all = {};
                end
                h = waitbar(0,'Extracting metadata for all papers...');
                db_i =  strrep(main_keyword_searchengine_raw_multiple{k},' ','%20');
                dir_db = ['papers/',db_i];
                list_papers_raw = dir(dir_db);

                list_papers = {list_papers_raw.name};

                for i = 1:1:numel(list_papers)

                    list_papers_i = list_papers{i};

                    metadata_i = article_data_extract(dir_db,list_papers_i);
                    if ~isempty(metadata_i)
                        metadata = [metadata;metadata_i]; 
                    end  
                    waitbar(i/numel(list_papers))
                end
                if ~isempty(metadata)
                    if contains(db_i,'%20AND%20')
                        db_i = extractAfter(db_i,'%20AND%20');               
                    end
                    metadata_all.(genvarname(db_i)) = metadata;
                end
                close(h)
            end
                        
        end

        %% Process results
        if plot_paper_info_by_folder

            try
               matfile = ['metadata_all_',main_keyword_searchengine_raw_multiple{1},'.mat'];
               load(matfile);
            catch
                flag1 = exist('metadata_all');
                if flag1 == 0
                    disp(['Err: ',matfile,' file not found -> need to run first the extract_papers_info function'])
                    enter_2 = 0;
                else
                    enter_2 = 1;
                end
            end
            
            db_names = fieldnames(metadata_all);
            db_name_i = db_names{k};
            metadata = metadata_all.(genvarname(db_name_i))

            metadata_all_processed = {};
            if isempty(filter_papers_keywords)
                metadata_all_processed = metadata;
            else
                metadata_all_processed = find_subset_of_papers(metadata,filter_papers_keywords);
            end

            % Year
            year_data = str2double([metadata_all_processed{:,2}]);
            year_data_unique = unique(year_data);
            year_data_unique(year_data_unique == 9999) = [];
            figure
            hist(year_data,numel(year_data_unique));
            h1 = findobj(gca,'Type','patch');
            set(h1,'FaceColor',[0.5 0.5 0.5],'EdgeColor','k')
            grid on
            title(['Publication year (',db_name_i,')'])
            ylabel('# of publications')

            % Journal  
            journals_all = [metadata_all_processed{:,3}];
            [C,ia,ic] = unique(journals_all);
            a_counts = accumarray(ic,1);
            tabl1 = table(C',a_counts);
            tabl1 = tabl1(cellfun(@isempty, strfind(tabl1.Var1, 'permafrost')), :);
            tabl1 = tabl1(cellfun(@isempty, strfind(tabl1.Var1, 'Permafrost')), :);
            figure
            wordcloud(tabl1,'Var1','a_counts')
            title(['Main Journals (',db_name_i,')'])

            % Type of paper
            [uni,~,idx] = unique([metadata_all_processed{:,4}]');
            figure
            hist(idx,unique(idx))
            h3 = findobj(gca,'Type','patch');
            set(h3,'FaceColor',[0.5 0.5 0.5],'EdgeColor','k')
            set(gca,'xtick',[1:numel(uni)],'xticklabel',uni)
            xtickangle(65)
            grid on
            title(['Type of paper (',db_name_i,')'])
            ylabel('# of publications')

            % Keywords
            keywords_all = [metadata_all_processed{:,6}];
            keywords_all_clean = remove_longchar_entries(keywords_all);
            [C,ia,ic] = unique(keywords_all_clean);
            a_counts = accumarray(ic,1);
            tabl1 = table(C',a_counts);
            tabl1 = tabl1(cellfun(@isempty, strfind(tabl1.Var1, 'permafrost')), :);
            tabl1 = tabl1(cellfun(@isempty, strfind(tabl1.Var1, 'Permafrost')), :);
            figure
            wordcloud(tabl1,'Var1','a_counts')
            title(['Main Keywords (',db_name_i,')'])

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

    end
catch
    
end

if extract_papers_info
    if by_country
        addwordi = '_by_country';
    else
        addwordi = '';
    end
   save(['metadata_all_',main_keyword_searchengine_raw_multiple{1},addwordi,'.mat'],'metadata_all'); 
end

%%
if plot_maps
    
    try
        matfile = ['metadata_all_',main_keyword_searchengine_raw_multiple{1},'_by_country.mat'];
        load(matfile);
    catch
        disp(['Err: ',matfile,' file not found -> need to run first the extract_papers_info function'])
        return;
    end

    latlon = readtable('countries_lat_lon.xlsx');
    db_names = fieldnames(metadata_all);
    
    latlon_cell = table2cell(latlon);
    geoinfo_a = {};
    
    num_popular_keywords_search_within_country_step1 = 30;
    num_popular_keywords_all_country_specific_results_step2 = 30;
    
    keywords_popular = {};
    countname_found = {};
    
    % Loop over the data extracted to look for information by country
    for s=1:numel(db_names)
        
        db_name_i = db_names{s};
        
        countname = db_name_i;
        countname = strrep(countname,'0x2520',' ');
        
        
        iloc = find(contains(latlon_cell(:,1),countname)==1);
        if ~isempty(countname) && ~isempty(iloc)
            
            countname_found = [countname_found,countname];
            
            metadata_i = metadata_all.(genvarname(db_name_i));
            
            % Coordinats
            lat_i = latlon_cell{iloc,2};
            lon_i = latlon_cell{iloc,3};
            
            % Number of papers
            numpaper = numel(metadata_i(:,1));
            
            % Keywords (find main key words for all countries)
            keywords_all = [metadata_i{:,6}];
            keywords_all_clean = remove_longchar_entries(keywords_all);
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
    gb = geobubble(geoinfo_tbl.geoinfo_a2,geoinfo_tbl.geoinfo_a3,geoinfo_tbl.geoinfo_a4,'Title','# Papers on Climate Change')
    %title('Number of papers')
    
    % PLOT MAP with main keywords 
    %% Keywords (most popular) all together
    remove_searchword = erase(main_keyword_searchengine_raw_multiple{1},'"');
    keywords_popular_proc1 = keywords_popular(...
                             find(~contains(keywords_popular(:,1),remove_searchword)==1),:); % remove climate change
    keywords_popular_proc2 = {};
    
    % remove names of countried from keywords
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
        for s=1:numel(db_names)
            %subplot(ceil(keywrd_pop^0.5,keywrd_pop^0.5,s))
            db_name_i = db_names{s};
            countname = db_name_i;
            countname = strrep(countname,'0x2520',' ');

            iloc = find(contains(latlon_cell(:,1),countname)==1);
            if ~isempty(countname) && ~isempty(iloc)

                countname_found = [countname_found,countname];

                metadata_i = metadata_all.(genvarname(db_name_i));

                % Coordinats
                lat_i = latlon_cell{iloc,2};
                lon_i = latlon_cell{iloc,3};

                keywords_all = [metadata_i{:,6}];

                keywrd_pop_i = keywrd_pop{p,1};
                iloc = find(contains(keywords_all,keywrd_pop_i)==1);
                numpaper = numel(iloc);
                if numpaper> 0
                    new_entry = {countname,lat_i,lon_i,numpaper,keywrd_pop_i};
                    geoinfo_b = [geoinfo_b;new_entry];
                end
                
            end
        end

        geoinfo_tbl2 = cell2table(geoinfo_b);
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

