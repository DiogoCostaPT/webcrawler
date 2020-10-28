

%% NUTRIENTS AND CLIMATE CHANGE REPORT            
%{
folder_name_to_store_results = 'nutrients_AND_climate_change_SCOPUS';                
main_keyword_searchengine_raw_multiple =[
                                        'DOCTYPE(ar) AND ',...
                                        ...{'TITLE-ABS(',...
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
                                      
%}


% Second run: Nutrients and climate change review paper
%folder_name_to_store_results = 'nutrients_AND_climate_change_SCOPUS_3';      
folder_name_to_store_results = 'nutrients_AND_climate_change_by_country_SCOPUS_3';
main_keyword_searchengine_raw_multiple =[...
                                    'DOCTYPE(ar)',...
                                    ' AND TITLE(',...
                                       '(nutrient* OR nitrogen* OR *phosph* OR nitrat* OR "water quality")',...
                                        ' AND (',...
                                            '(climate AND (chang* OR variab*))',... 
                                            ' OR "global warming"',... 
                                            ' OR (extreme AND (event* OR precipitation OR rain* OR climat*))',...
                                            ')',...
                                        ' AND NOT (',...
                                            '"use efficienc*" OR socia* OR yield* OR sea OR ocean OR marine OR mortality OR reproduction OR sexual',...
                                            ' OR phenolog* OR biofuel* OR food* OR "ecosystem services"',...
                                        ')',...
                                    ')',...
                                    ' AND TITLE-ABS-KEY(',...
                                       'country_placeholder',...
                                        ' AND NOT (',...
                                        ...    '(river* OR lake* OR wetland OR stream* OR basin* OR watershed* OR runoff OR "run-off" OR reservoir)',... 
                                        ...    ' AND NOT ("greenhouse gas*" OR methane OR "carbon dioxide" OR "CO<sub>2</sub>" OR "CH<sub>4</sub>")',... 
                                            '*coral* OR wave OR *reef* OR oceanogra* OR tsunami* OR tid* OR bathyal OR abyssal OR hadal',... 
                                            ' OR neogene OR miocene OR oligocene OR eocene OR paleo* OR cretaceus or triassic',...
                                        ...    ' OR "renewable energy" OR "solar energy"',...
                                        ...    ' AND NOT (*sea* OR *ocean*)',... 
                                        ...    ' AND NOT (*urban* OR *highway* OR "treatment plant" OR *roof*)',...
                                        ')',...
                                    ')',...
                                        ];


%% GW AND CC REPORT
%{
folder_name_to_store_results = 'groundwater_AND_climate_change_TITLE_SCOPUS';                
main_keyword_searchengine_raw_multiple =[
                                        'DOCTYPE(ar) AND ',...
                                        ...%{'TITLE-ABS(',...
                                        'TITLE(',...
                                        '("climate change" OR "global warming")',...
                                        ' AND (*groundwater* OR *aquifer* OR *subsurface* OR *underground*)',...
                                        ' AND ("Great Lakes" OR "Lake Superior" OR "Lake Michigan" OR "Lake Huron" OR "Lake Erie" OR "Lake Ontario")',...
                                        ' AND NOT ("Environment and Climate Change Canada"))',...
                                        ...%' AND TITLE-ABS(country_placeholder)'...
                                        ];

%}

%{
folder_name_to_store_results = 'groundwater_AND_climate_change_TITLE-ABS-KEY_SCOPUS';                
main_keyword_searchengine_raw_multiple =[
                                        'DOCTYPE(ar) AND ',...
                                        ...%{'TITLE-ABS(',...
                                        'TITLE-ABS-KEY(',...
                                        '("climate change" OR "global warming")',...
                                        ' AND (*groundwater* OR *aquifer* OR *subsurface* OR *underground*)',...
                                        ' AND ("Great Lakes" OR "Lake Superior" OR "Lake Michigan" OR "Lake Huron" OR "Lake Erie" OR "Lake Ontario")',...
                                        ' AND NOT ("Environment and Climate Change Canada"))',...
                                        ...%' AND TITLE-ABS(country_placeholder)'...
                                        ];     
%}


                                    
%% TOOLS

% STEP 1
RetrieveListPapers_STEP_1_flag = false;  % carefull -> it will send requests to Science-Direct server

% STEP 2                                  
RequestPapersFromList_STEP_2_flag = false; % carefull -> it will send requests to Science-Direct server

% STEP 3
ExtractInfoFromPapers_STEP_3_flag = false; 
force_overwrite = true;

% STEP 4true
PlotResults_STEP_4_flag = false; %1) # papers and keywords
filter_papers_keywords = {}; % if don't want to 
%filter_papers_keywords = {'biogeochemistry', 'geochemistry', 'chemistry', 'greenhouse', 'ion', 'anion',...
%        'cation','methane','mercur1y','carbon','organic','CO<sub>2</sub>','CH<sub>4</sub>''hydrate','gas','radiocarbon','hydrocarbon'};

% STEP 5
PlotMaps_STEP_5_flag = true;

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



