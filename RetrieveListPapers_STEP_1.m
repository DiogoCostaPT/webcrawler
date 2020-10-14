
% Search List of Papers

function RetrieveListPapers_STEP_1(...
            database_API,...
            main_keyword_searchengine_raw_multiple,...
            num_search_pages,...
            pausetime,...
            show,...
            dir4search)
        
% Retrieve list of papers

h = waitbar(0,'Extracting list of papers (STEP 1)');
set(h,'Position', [500 300 280 70]);

pausetimeurl_list_s = '';

for k = 1:numel(main_keyword_searchengine_raw_multiple)

    main_keyword_searchengine = main_keyword_searchengine_raw_multiple{k};
    main_keyword_searchengine = strrep(main_keyword_searchengine,' ','%20');
        
        url_list_s = [];
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