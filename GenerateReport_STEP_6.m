
function GenerateReport_STEP_6(main_keyword_searchengine_raw_multiple,...
    dir4search,...
    only_title_and_highlights,...
    folder_name_to_store_results)
  
foldernames = dir(dir4search); 
dirFlags = [foldernames.isdir];
foldernames = foldernames(dirFlags);
foldernames = {foldernames.name};
foldernames(strcmp(foldernames,'.')) = [];
foldernames(strcmp(foldernames,'..')) = [];

for p = 1:numel(foldernames)

     try
           csvfile = [dir4search,'/',foldernames{p},'/metadata_all_list.csv'];
           metadata_all_list_table = readtable(csvfile,'delimiter',';');
      catch
           
        disp(['WARNING: ',metadata_all_list_table,' file not found -> need to run first the extract_papers_info function'])
    return;
     end

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
                 %print_searchwords = strrep(char(paper_table_i.Search_Keys),'%20',' ');
                 fprintf(fid, '%s\n\t', ['---->	SEARCH WORDS -> ',main_keyword_searchengine_raw_multiple{p}]);
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
                writetext = ['Publication/article type: ',upper(paper_table_i.Type_of_Publication{:}),' (Year: ',paper_table_i.Year{:},')'];
                fprintf(fid, '%s\n\n', writetext);
                writetext = paper_table_i.Paper_title{:};
                fprintf(fid, '%s\n\n', writetext);
                fprintf(fid, '%s\n','-----------------------------------------------------------------------------------');
                writetext = ['Authors: ',paper_table_i.Authors{:}];
                fprintf(fid, '%s\n', writetext);
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
                fprintf(fid, '%s\n\t', ['SEARCH WORDS: ', main_keyword_searchengine_raw_multiple{p}]);
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
         
