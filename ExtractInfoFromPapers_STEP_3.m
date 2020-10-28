
function ExtractInfoFromPapers_STEP_3(dir4search,...
                                      by_country,...
                                      folder_name_to_store_results,...
                                      force_overwrite)


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


   % if by_country
   %     addwordi = '_by_cou0ntry';
   % else
   %     addwordi = '';
   % end
    try
       matfile = [dir4search,'/metadata_all_list.mat'];
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
            metadata_i = '';
            
            %h = waitbar(0,'Extracting metadata for all papers...');
            %db_i =  strrep(foldernames{k},' ','%20');
            dir_db = ['papers/',folder_name_to_store_results,'/',foldernames{k}];
            list_papers_raw = dir(dir_db);
           
            list_papers = {list_papers_raw.name};
            list_papers(strcmp(list_papers,'.')) = [];
            list_papers(strcmp(list_papers,'..')) = [];
            list_papers(contains(list_papers,'~')) = []; % temporary files in folder
            list_papers(strcmp(list_papers,'href_list.mat')) = [];
            list_papers(strcmp(list_papers,'metadata_this_folder.mat')) = [];
            list_papers(strcmp(list_papers,'metadata_all_list.mat')) = [];
            
            for i = 1:1:numel(list_papers)
                
                if i == 1
                    %metadata_all_cell = {};
                    metadata_all_list = [metadata_all_list;{foldernames{k},'-','-','-','-','-','-','-','-','-'}];
                end

                list_papers_i = list_papers{i};

                metadata_i = article_data_extract(dir_db,...
                                                  list_papers_i);
                
                if ~isempty(metadata_i)
                    metadata = [metadata;metadata_i]; 
                end  
                waitbar(i/numel(list_papers),h,...
                            {'Extracting info from papers-html (STEP 3)',...
                            ['Keyword combination = ',num2str(k),' out of ',num2str(numel(foldernames))],...
                            ['Paper: ', num2str(i),' out of ',num2str(numel(list_papers))]});
            end
            if ~isempty(metadata)
                add_new_dataset = [cell(numel(metadata(:,1)),1),metadata];
                metadata_all_list = [metadata_all_list;add_new_dataset];
                %add_new_dataset_to_print = add_new_dataset(:,2:end);
                %save([dir4search,'/',foldernames{k},'/metadata_this_folder',addwordi,'.mat'],'add_new_dataset_to_print'); 
            end
    
        end
    end
    close(h)
    
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
    
    %metadata_all_list_table = strrep(metadata_all_list_table,'|','');                                                
    save([dir4search,'/metadata_all_list.mat'],'metadata_all_list_table'); 
