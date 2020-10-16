

function main_keyword_searchengine_raw_multiple = add_listing_countries(main_keyword_searchengine_raw_main)


countries_list = listing_countries();
main_keyword_searchengine_raw_multiple = {};

for i = 1:numel(countries_list)
    country_i = countries_list{i};
    %add_entry = {[baseline,' AND ',country_i]};
    %main_keyword_searchengine_raw_multiple = [main_keyword_searchengine_raw_multiple;add_entry];
    add_searchword = strrep(main_keyword_searchengine_raw_main,'country_placeholder',country_i);
    main_keyword_searchengine_raw_multiple = [main_keyword_searchengine_raw_multiple;add_searchword];
end

end