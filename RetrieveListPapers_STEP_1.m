
% Search List of Papers

function RetrieveListPapers_STEP_1(...
            myScopusApiKey,...
            by_country,...
            main_keyword_searchengine_raw_multiple,...
            num_search_pages,...
            pausetime,...
            show,...
            dir4search)
        
% Retrieve list of papers

h = waitbar(0,'Extracting list of papers (STEP 1)');
set(h,'Position', [500 300 280 70]);

pausetimeurl_list_s = '';

if by_country
   countries_list = listing_countries(); 
end

for k = 1:numel(main_keyword_searchengine_raw_multiple)

        % URL Encoding (see https://dev.elsevier.com/sc_search_tips.html)
        main_keyword_searchengine = main_keyword_searchengine_raw_multiple{k};
        main_keyword_searchengine = strrep(main_keyword_searchengine,' ','%20');
        main_keyword_searchengine = strrep(main_keyword_searchengine,'(','%28');
        main_keyword_searchengine = strrep(main_keyword_searchengine,')','%29');
                   
        url_list_s = [];
        url_list = {};
        %offset_sciencedirect = 0;    
        start_scopus = 0;
        htlm_raw = [];

        for p = 1:num_search_pages 

            waitbar(p/num_search_pages,h,...
                            {'Extracting list of papers (STEP 1)',...
                            ['Keyword combination = ',num2str(k),' out of ',num2str(numel(main_keyword_searchengine_raw_multiple))],...
                            ['ScienceDirect page: ', num2str(p),' out of ',num2str(num_search_pages)]});

            if ~isempty(url_list_s) || p==1

                try
                    %{
                    if contains(database_API,'Science_Direct')
                       url_query = ['https://www.sciencedirect.com/search/advanced?tak=',...
                                    main_keyword_searchengine,...
                                    '&show=',num2str(show),'&offset=',num2str(offset_sciencedirect)];
                    elseif contains(database_API,'Scopus')
                    show = 25; % maximum permited (it will return service-error if hight
                   %}
                    url_query = ['https://api.elsevier.com/content/search/index:SCOPUS?',...
                                'start=',num2str(start_scopus),'&count=',num2str(show),...
                                '&query=',main_keyword_searchengine,...
                                '&apikey=',num2str(myScopusApiKey)];
                    %end
                    
                    % Get titles fro Scopus
                    html_raw = safeDiogo_webread(url_query,pausetime);
                    
                    
                    %{
                    if contains(database_API,'Science_Direct')
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
                        offset_sciencedirect = show * p;
                        start_scopus = offset_sciencedirect;
                    
                    elseif contains(database_API,'Scopus')
                    %}
                        for l = 1:numel(html_raw.search_results.entry)
                            
                            %url_query = ['https://api.elsevier.com/content/search/index:SCOPUS?',...
                            %    '&query=DOI%28',,...
                            %    '%29&apikey=',num2str(myScopusApiKey)];
                            
                            %doi_code = html_raw.search_results.entry{l,1}.prism_doi;
                            %doi = html_raw.search_results.entry{l,1}.prism_doi;
                            %doi = strrep(doi,'"','%22');
                            %doi = strrep(doi,'/','%2F');
                            %url_list_s = ['https://api.elsevier.com/content/search/scopus?query=DOI%28',...
                            %           doi,...
                            %           '%29&apikey=',num2str(myScopusApiKey)];
                             
                            % Get URL from google scholar and extracting
                            % publisher's URL
                            %title = html_raw.search_results.entry{l,1}.dc_title;
                            %title_Encoding4google = strrep(title,' ','+');
                            
                            % Go to DOI.org to get link to publisher
                            try
                                doi_code = html_raw.search_results.entry{l,1}.prism_doi;
                                doi_org_url = ['https://dx.doi.org/',...
                                                  doi_code,...
                                                  ];     
                                url_list_s = doi_org_url;

                                url_list = [url_list;url_list_s];
                            catch
                                 disp('> DOI not found -> entry skipped')
                            end
                            
                        end
                        start_scopus = show * p;
                    %end   
                    
                catch
                    disp('> No more pages to search')
                    break;
                end
            end

        end
        
        if ~isempty(url_list)
            if by_country
                foldername = countries_list{k};
            else
                foldername = 'general';
            end

           new_dir = [dir4search,'/',foldername]; 


            mkdir(new_dir);
            filesave_name = [new_dir,'/href_list'];
            save(filesave_name,'url_list');
        end
    end

close(h)