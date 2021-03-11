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

% Plot Maps

function PlotMaps_STEP_5(dir4search,main_keyword_searchengine_raw_multiple)


    foldernames = dir(dir4search); 
    dirFlags = [foldernames.isdir];
    foldernames = foldernames(dirFlags);
    foldernames = {foldernames.name};
    foldernames(strcmp(foldernames,'.')) = [];
    foldernames(strcmp(foldernames,'..')) = [];
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
        %countname = strrep(countname,foldernames_firstgeneral,'');
        %countname = strrep(countname,'%20AND%20','');
        %countname = strrep(countname,'%20',' ');
                
        iloc = find(contains(latlon_cell(:,1),countname)==1);
        
        if ~isempty(countname) && ~isempty(iloc)
            
            try
                matmetadata_file = [dir4search,'/metadata_all_list.mat'];
                load(matmetadata_file);
                %metadata_all_list_table = readtable(matmetadatafile,'delimiter',';');
            catch
                disp(['WARNING: ',matmetadata_file,' file not found -> need to run first the extract_papers_info function'])
                return;
            end

            intervals4easchsearch = find(~cellfun(@isempty,table2cell(metadata_all_list_table(:,1))));
            
            iloc_country = find(contains([metadata_all_list_table{intervals4easchsearch,1}],db_name_i)==1);
            
            
            %countname_found = [countname_found,countname];
            
            if s ~= numel(foldernames)
                metadata_i = metadata_all_list_table(intervals4easchsearch(iloc_country)+1:intervals4easchsearch(iloc_country+1),:);
            else
                metadata_i = metadata_all_list_table(intervals4easchsearch(iloc_country)+1:end,:);
            end
            
            
            % Coordinats
            lat_i = latlon_cell{iloc,2};
            lon_i = latlon_cell{iloc,3};
            
            % Number of papers
            numpaper = numel(metadata_i(:,1));
            
            % Keywords (find main key words for all countries)
            keywords_all = {metadata_i{:,7}};
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
    
    %{
    %% Keywords (most popular) all together
    remove_searchwords = erase(main_keyword_searchengine_raw_multiple{1},'"');
    remove_searchwords = split(remove_searchwords,' AND ');
    
    for d = 1:numel(remove_searchwords)
        keywords_popular_proc1 = keywords_popular(...
                             find(~contains(keywords_popular(:,1),remove_searchwords{d})==1),:); % remove climate change
    end
      keywords_popular_proc2 = {};
    
    % remove names of countries from keywords
    countname_found = {};
    for w=1:numel(keywords_popular(:,1))     
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
    %}
    
    keywords_popular_proc2 = keywords_popular;
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