
% Extract data from article
function metadata = article_data_extract(dir_db,list_papers_i)

    metadata = {};
    
    
    try
        % url_link = 'https://www.sciencedirect.com/science/article/pii/S0013935119308928';
        %url_link = 'https://www.sciencedirect.com/science/article/pii/S0048969719351198';

        html_data_raw = load([dir_db,'/',list_papers_i]);
        html_data = html_data_raw.html_data;
    catch
        Param = 'html data';
        ErrDispConsole(Param,list_papers_i);
        return;
    end
    
    % Parsing Varia
    try
        
        title = extractBetween(html_data,'<meta name="citation_title" content="','" />');
    catch
        title = '';
        Param = 'title';
        ErrDispConsole(Param,list_papers_i);
    end
    try
        year = extractBetween(html_data,'<meta name="citation_publication_date" content="','" />');
        year = extractBefore(year,'/');
    catch
        year = '';
        Param = 'year';
        ErrDispConsole(Param,list_papers_i);
    end
    try   
        journal = extractBetween(html_data,'<meta name="citation_journal_title" content="','" />');
    catch
        journal = '';
        Param = 'journal';
        ErrDispConsole(Param,list_papers_i);
    end
    try
        article_type = extractBetween(html_data,'<meta name="citation_article_type" content="','" />');
    catch
        article_type = '';
        Param = 'article_type';
        ErrDispConsole(Param,list_papers_i);
    end
    
    
    try
        % Parsing Author names
        start_key = '"#name":"given-name","_":"';
        authors_givenname_s = strfind(html_data,start_key);
        end_key = '"},{"#name":"surname","_":"';
        authors_givenname_e = strfind(html_data,end_key);
        authors_familyname_s = authors_givenname_e + numel(authors_givenname_e) - 2;
        temp = strfind(html_data(authors_familyname_s:end),'"}');
        authors_familyname_e = authors_familyname_s + temp(1) - 1;
        authors_name = {};

        for i = 2:numel(authors_givenname_s)
            givenname = html_data(authors_givenname_s(i)+numel(start_key):authors_givenname_e(i)-1);
            familyname = html_data(authors_familyname_s(i)+numel(start_key):authors_familyname_e(i)-1);
            authors_name = [authors_name,[givenname,' ',familyname]];
        end
    catch
        authors_name = '';
        Param = 'authors_name';
        ErrDispConsole(Param,list_papers_i);
    end
    
    try
        % Parsing Keywords
        start_key = 'keyword"><span>';
        keyword_s = strfind(html_data,start_key) + numel(start_key);
        keywords = {};
        for i = 1:numel(keyword_s)
            temp = strfind(html_data(keyword_s(i):end),'</span>');
            keyword_e = temp(1);
            keyword_i = html_data(keyword_s(i):keyword_s(i) + keyword_e - 2);
            keywords_i_clean = to_lowercase_and_put_singular(keyword_i); % clean up (all lower case and singular)
            keywords = [keywords,keywords_i_clean];
        end
    catch
        keywords = '';
        Param = 'keywords';
        ErrDispConsole(Param,list_papers_i);
    end
    try
        % Abstract (some html code remains at the start, but should not be
        % problematic)
        abstract_s = strfind(html_data,'class="abstract author"');
        temp = strfind(html_data(abstract_s:end),'</p>');
        abstract_e = temp(1);
        abstract = html_data(abstract_s:abstract_s + abstract_e - 2);
    catch
        abstract = '';
        Param = 'abstract';
        ErrDispConsole(Param,list_papers_i);
    end


    metadata = {title,year,journal,article_type,authors_name,keywords,abstract};
    
end

function ErrDispConsole(Param,list_papers_i)
    errmsg = ['> ERR: Problem in "',Param,'" in ',list_papers_i];
    disp(errmsg);

end
