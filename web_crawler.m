


%folder_name_to_store_results = 'nutrients_AND_climate_change';
%main_keyword_searchengine_raw_multiple = {'"nutrients" AND "climate change AND country_placeholder"'};   
                                      
folder_name_to_store_results = 'nutrients_AND_climate_change_SCOPUS';                
main_keyword_searchengine_raw_multiple =[
                                        'DOCTYPE(ar) AND ',...
                                        ...%{'TITLE-ABS(',...
                                        'TITLE(',...
                                        '("climate change" OR "global warming")',...
                                        ' AND (nutrient* OR nitrogen* OR *phosph* OR nitrat*)',...
                                        ' AND (river* OR lake* OR wetland OR stream* OR basin* OR watershed* OR runoff OR "run-off" OR reservoir)',...
                                        ' AND NOT ("greenhouse gas*" OR emissions OR methane OR "carbon dioxide" OR "CO<sub>2</sub>" OR "CH<sub>4</sub>")',...
                                        ' AND NOT ("Environment and Climate Change Canada")'...
                                        ' AND NOT (*coral* OR *reef* OR *sea* OR *ocean*)',...
                                        ' AND NOT (*urban* OR *highway* OR "treatment plant" OR *roof*)',...
                                        ')',...
                                        %' AND TITLE-ABS(country_placeholder)'...
                                        ];
                                      

%folder_name_to_store_results = 'nitrogen_AND_climate_change';
%main_keyword_searchengine_raw_multiple = {'"nitrogen" AND "climate change"'
                                          %'permafrost AND Canada';...
                                          %'permafrost AND (chemistry OR biogeochemistry OR geochemistry)';...
                                          %'permafrost AND Canada AND (chemistry OR biogeochemistry OR geochemistry)'
%                                          };   
                                      
%folder_name_to_store_results = 'great_lakes_AND_climate_change';
%main_keyword_searchengine_raw_multiple = {'"great lakes" AND "climate change"'
%                                          };     

%folder_name_to_store_results = 'permafrost_AND_climate_change';
%main_keyword_searchengine_raw_multiple = {'"permafrost" AND "climate change"'

 %                                         };     
     


%% TOOLS

% STEP 1
RetrieveListPapers_STEP_1_flag = false;  % carefull -> it will send requests to Science-Direct server

% STEP 2                                  
RequestPapersFromList_STEP_2_flag = false; % carefull -> it will send requests to Science-Direct server

% STEP 3
ExtractInfoFromPapers_STEP_3_flag = true; 
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
num_search_pages = 200;
pausetime = 10; % in seconds -> CAREFULL, DON'T PUT THIS LOWER THAN 10




%% call WebCrawler_ENGINE
myScopusApiKey = '3291a872bc42269b1594b782de7524c3';

show = 25; % this is the max of # of results that the scupos API allows (will return error if increased)


WebCrawler_ENGINE(folder_name_to_store_results,...
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
                only_title_and_highlights);



