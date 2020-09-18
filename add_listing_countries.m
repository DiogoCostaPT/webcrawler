
function main_keyword_searchengine_raw_multiple = add_listing_countries(main_keyword_searchengine_raw_multiple)

baseline = main_keyword_searchengine_raw_multiple;
countries_list = listing_countries();

for i = 1:numel(countries_list)
    country_i = countries_list{i};
    add_entry = {[baseline,' AND ',country_i]};
    main_keyword_searchengine_raw_multiple = [main_keyword_searchengine_raw_multiple;add_entry];
end

end