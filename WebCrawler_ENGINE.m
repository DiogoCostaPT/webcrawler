
%% Web Crawler main engine

function WebCrawler_ENGINE(...
                folder_name_to_store_results,...
                main_keyword_searchengine_raw_multiple,...
                num_search_pages,...
                pausetime,...
                show,...
                myScopusApiKey,...
                RetrieveListPapers_STEP_1_flag,...,
                RequestPapersFromList_STEP_2_flag,...
                ExtractInfoFromPapers_STEP_3_flag,...
                force_overwrite,...
                PlotResults_STEP_4_flag,...
                filter_papers_keywords,...
                PlotMaps_STEP_5_flag,...
                GenerateReport_STEP_6_flag,...
                only_title_and_highlights)
            
            
mkdir('papers');
dir4search = ['papers/',folder_name_to_store_results];
mkdir(dir4search);

by_country = 0;

% If analysis by country
if contains(main_keyword_searchengine_raw_multiple,'country_placeholder')
    by_country = 1;
    main_keyword_searchengine_raw_multiple = add_listing_countries(main_keyword_searchengine_raw_multiple); 
else
    main_keyword_searchengine_raw_multiple = {main_keyword_searchengine_raw_multiple};
end



%% STEP 1: EXTRACT LIST OF PAPERS
if RetrieveListPapers_STEP_1_flag
    
    RetrieveListPapers_STEP_1(myScopusApiKey,...
        by_country,...
        main_keyword_searchengine_raw_multiple,...
        num_search_pages,...
        pausetime,...
        show,...
        dir4search);

end


%% STEP 2: EXTRACT HTML
if RequestPapersFromList_STEP_2_flag 
 
    RequestPapersFromList_STEP_2(dir4search,pausetime);
    
end

%% STEP 3: Extract paper info
if ExtractInfoFromPapers_STEP_3_flag

    ExtractInfoFromPapers_STEP_3(dir4search,...
                                folder_name_to_store_results,...
                                force_overwrite);
    
end

%% Plot results
if PlotResults_STEP_4_flag

    PlotResults_STEP_4(main_keyword_searchengine_raw_multiple,...
        dir4search);
    
end
    
% Plot Maps
%%
if PlotMaps_STEP_5_flag
    
    PlotMaps_STEP_5(dir4search,...
        main_keyword_searchengine_raw_multiple);
   
end

% Generate report
if GenerateReport_STEP_6_flag
  
    GenerateReport_STEP_6(main_keyword_searchengine_raw_multiple,...
        dir4search,...
        only_title_and_highlights,...
        folder_name_to_store_results);
    
end

end

