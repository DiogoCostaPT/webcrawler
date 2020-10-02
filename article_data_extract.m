
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
        title = 'NOT AVAILABLE';
        Param = 'title';
        ErrDispConsole(Param,list_papers_i);
    end
    try
        year = extractBetween(html_data,'<meta name="citation_publication_date" content="','" />');
        year = extractBefore(year,'/');
    catch
        year = 'NOT AVAILABLE';
        Param = 'year';
        ErrDispConsole(Param,list_papers_i);
    end
    try   
        journal = extractBetween(html_data,'<meta name="citation_journal_title" content="','" />');
    catch
        journal = 'NOT AVAILABLE';
        Param = 'journal';
        ErrDispConsole(Param,list_papers_i);
    end
    try
        article_type = extractBetween(html_data,'<meta name="citation_article_type" content="','" />');
    catch
        article_type = 'NOT AVAILABLE';
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
        authors_name = [];

        for i = 2:numel(authors_givenname_s)
            givenname = html_data(authors_givenname_s(i)+numel(start_key):authors_givenname_e(i)-1);
            familyname = html_data(authors_familyname_s(i)+numel(start_key):authors_familyname_e(i)-1);
            authors_name = [authors_name,[givenname,' ',familyname],', '];
        end
    catch
        authors_name = 'NOT AVAILABLE';
        Param = 'authors_name';
        ErrDispConsole(Param,list_papers_i);
    end
    
    try
        % Parsing Keywords
        start_key = 'keyword"><span>';
        keyword_s = strfind(html_data,start_key) + numel(start_key);
        keywords = [];
        for i = 1:numel(keyword_s)
            temp = strfind(html_data(keyword_s(i):end),'</span>');
            keyword_e = temp(1);
            keyword_i = html_data(keyword_s(i):keyword_s(i) + keyword_e - 2);
            keywords_i_clean = to_lowercase_and_put_singular(keyword_i); % clean up (all lower case and singular)
            keywords = [keywords,keywords_i_clean];
            if i~=numel(keyword_s) keywords = [keywords,', '];end
        end
    catch
        keywords = 'NOT AVAILABLE';
        Param = 'keywords';
        ErrDispConsole(Param,list_papers_i);
    end
    try
        % Abstract (some html code remains at the start, but should not be
        % problematic)
        start_key = 'Abstract</h2><div';
        abstract_s = strfind(html_data,start_key);
        abstract_cut = html_data(abstract_s+numel(start_key):end);
        other_key = 'abstract-sec';
        abstract_s = strfind(abstract_cut,other_key);
        abstract_cut = abstract_cut(numel(other_key)+abstract_s(1):end);
        other_key = '><';
        abstract_s = strfind(abstract_cut,other_key);
        abstract_cut = abstract_cut(abstract_s(1)+numel(other_key):end);
         other_key = '>';
        abstract_s = strfind(abstract_cut,other_key);
        abstract_cut = abstract_cut(abstract_s(1)+numel(other_key):end);
        
        temp = strfind(abstract_cut,'</p>');
        abstract_e = temp(1);
        abstract = abstract_cut(1:abstract_e-1);
    catch
        abstract = 'NOT AVAILABLE';
        Param = 'abstract';
        ErrDispConsole(Param,list_papers_i);
    end
    
     %Extract highlights
     try
      start_key = 'Highlights</h2><div ';
      abstract_s = strfind(html_data,start_key); 
      highlights_cut = html_data(abstract_s+numel(start_key):end); 
      other_key = 'class="list-description"><p';
      loc = strfind(highlights_cut,other_key); 
      highlights_cut = highlights_cut(loc+numel(other_key):end); 
      other_key = '>';
      loc = strfind(highlights_cut,other_key); 
      highlights_cut = highlights_cut(loc(1)+numel(other_key):end); 
      other_key = '</p></dd></dl></p></div></div><div ';
      loc = strfind(highlights_cut,other_key); 
      highlights_cut = highlights_cut(1:loc(1)-1); 
      highlights = {};
      look4 = 1;
      while look4==1
          try 
              first_key = '</p>';
              loc = strfind(highlights_cut,first_key); 
              highlights_i = highlights_cut(1:loc(1)-1);
              
              second_key = 'class="list-description"><p id=';
              loc = strfind(highlights_cut,second_key); 
              highlights_cut = highlights_cut(loc(1)+numel(second_key):end);
              
              last_key = '>';
             loc = strfind(highlights_cut,last_key); 
             highlights_cut = highlights_cut(loc(1)+numel(last_key):end); 

              highlights = [highlights;highlights_i];
          catch
              look4 = 0;
          end
      end
      highlights = [highlights;highlights_cut];
      
      highlights = char(highlights);
      
      if ~isempty(highlights_cut)
          other_key = 'class="list-description"><p ';
          abstract_s = strfind(highlights_cut,other_key); 
          highlights_cut = html_data(abstract_s+numel(start_key):end);
          
          
      else
         highlights = 'NOT AVAILABLE';
        Param = 'highlights';
         ErrDispConsole(Param,list_papers_i);
      end
      
     catch
        highlights = 'NOT AVAILABLE';
        Param = 'highlights';
         ErrDispConsole(Param,list_papers_i);
     end
     


    metadata = {title,year,journal,article_type,authors_name,keywords,abstract,highlights};
    
end

function ErrDispConsole(Param,list_papers_i)
    errmsg = ['> WARNING: Problem in "',Param,'" in ',list_papers_i];
    disp(errmsg);

end
