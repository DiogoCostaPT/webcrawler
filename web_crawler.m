
% Options

% 1

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
 

%folder_name_to_store_results = 'nitrogen_AND_climate_change';
%main_keyword_searchengine_raw_multiple = {'"nitrogen" AND "climate change"'
                                          %'permafrost AND Canada';...
                                          %'permafrost AND (chemistry OR biogeochemistry OR geochemistry)';...
                                          %'permafrost AND Canada AND (chemistry OR biogeochemistry OR geochemistry)'
%                                          };   
                                      
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
     
myApiKey = '3291a872bc42269b1594b782de7524c3';
 
% 1
search_engine_retrive_list_of_papers_and_urls = false;  % carefull -> it will send requests to Science-Direct server
by_country = 0; % will only take the first entry of main_keyword_searchengine_raw_multiple and add the country names

% 2                                    
request_server_papers_in_list_save_htmls = false; % carefull -> it will send requests to Science-Direct server

% 3
extract_papers_info = false; 
force_overwrite = true;

% 4
plot_paper_info_by_folder = false; %1) # papers and keywords
filter_papers_keywords = {}; % if don't want to 
%filter_papers_keywords = {'biogeochemistry', 'geochemistry', 'chemistry', 'greenhouse', 'ion', 'anion',...
%        'cation','methane','mercur1y','carbon','organic','CO<sub>2</sub>','CH<sub>4</sub>''hydrate','gas','radiocarbon','hydrocarbon'};

% 5
plot_maps = false;

% 6
generate_reports = true;
only_title_and_highlights = false;

% additiona settings
num_search_pages = 1;
show = 100;
pausetime = 10; % CAREFULL, DON'T PUT THIS LOWER THAN 10


%% code starts here........

mkdir('papers');
dir4search = ['papers/',folder_name_to_store_results];
mkdir(dir4search);

% If analysis by country
if by_country 
    main_keyword_searchengine_raw_multiple = add_listing_countries(main_keyword_searchengine_raw_multiple{1}); 
end



%% STEP 1: EXTRACT LIST OF PAPERS
if search_engine_retrive_list_of_papers_and_urls
    
    RetrieveListPapers_STEP_1(main_keyword_searchengine_raw_multiple,num_search_pages,pausetime,show,dir4search);

end


%% STEP 2: EXTRACT HTML
if request_server_papers_in_list_save_htmls 
 
    RequestPapersFromList_STEP_2(dir4search,pausetime);
    
end

%% STEP 3: Extract paper info
if extract_papers_info

    ExtractInfoFromPapers_STEP_3(dir4search,by_country,folder_name_to_store_results);
    
end

%% Plot results
if plot_paper_info_by_folder

    PlotResults_STEP_4(main_keyword_searchengine_raw_multiple,dir4search);
    
end
    
% Plot Maps
%%
if plot_maps
    
    PlotMaps_STEP_5(dir4search,main_keyword_searchengine_raw_multiple);
   
end

% Generate report
if generate_reports
  
    GenerateReport_STEP_6(dir4search,only_title_and_highlights,folder_name_to_store_results);
    
end




