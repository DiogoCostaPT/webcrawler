

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
                                      
folder_name_to_store_results = 'nutrients_AND_climate_change_SCOPUS';                
main_keyword_searchengine_raw_multiple ={'("climat* *chang*" OR "global warming") AND (nutrient* OR nitrogen* OR *phosph* OR nitrat*) AND (river* OR lake* OR wetland OR stream* OR basin* OR watershed*)'};
                                      

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
     


%% TOOLS

% STEP 1
RetrieveListPapers_STEP_1_flag = true;  % carefull -> it will send requests to Science-Direct server
by_country = true; % will only take the first entry of main_keyword_searchengine_raw_multiple and add the country names

% STEP 2                                  
RequestPapersFromList_STEP_2_flag = false; % carefull -> it will send requests to Science-Direct server

% STEP 3
ExtractInfoFromPapers_STEP_3_flag = false; 
force_overwrite = true;

% STEP 4
PlotResults_STEP_4_flag = false; %1) # papers and keywords
filter_papers_keywords = {}; % if don't want to 
%filter_papers_keywords = {'biogeochemistry', 'geochemistry', 'chemistry', 'greenhouse', 'ion', 'anion',...
%        'cation','methane','mercur1y','carbon','organic','CO<sub>2</sub>','CH<sub>4</sub>''hydrate','gas','radiocarbon','hydrocarbon'};

% STEP 5
PlotMaps_STEP_5_flag = false;

% STEP 6
GenerateReport_STEP_6_flag = false;
only_title_and_highlights = false;


% additional settings
myScopusApiKey = '3291a872bc42269b1594b782de7524c3';
database_API_available = {'Science_Direct','Scopus'};
database_API_select = 2;
num_search_pages = 60;
show = 100;
pausetime = 10; % CAREFULL, DON'T PUT THIS LOWER THAN 10






%% call WebCrawler_ENGINE

database_API = database_API_available{database_API_select};

WebCrawler_ENGINE(folder_name_to_store_results,...
                by_country,...
                main_keyword_searchengine_raw_multiple,...
                num_search_pages,...
                pausetime,...
                show,...
                database_API,...
                myScopusApiKey,...
                RetrieveListPapers_STEP_1_flag,...,
                RequestPapersFromList_STEP_2_flag,...
                ExtractInfoFromPapers_STEP_3_flag,...
                force_overwrite,...
                PlotResults_STEP_4_flag,...
                filter_papers_keywords,...
                PlotMaps_STEP_5_flag,...
                GenerateReport_STEP_6_flag,...
                only_title_and_highlights);

            



