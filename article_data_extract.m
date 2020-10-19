
% Extract data from article
function metadata = article_data_extract(dir_db,...
                                        list_papers_i)

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
    
    
    article_publisher = html_data{1};
    url_link = html_data{2};
    html_paper = html_data{3};
    
    % Parsing Title
        
    if  strcmp(article_publisher,'Elsevier')
        metadata = extrBetween_DB_ELSEVIER(html_paper,url_link);
      
    elseif strcmp(article_publisher,'Springer')
        metadata = extrBetween_DB_SPRINGER(html_paper,url_link);
        

    
elseif strcmp(article_publisher,'Taylor_and_Francis')
    extrBetween_keys.title = {'',''};

elseif strcmp(article_publisher,'Wiley')
    extrBetween_keys.title = {'',''};
    
elseif strcmp(article_publisher,'AGU_pubs')
    extrBetween_keys.title = {'<meta property="og:title" content="','/>'};
    extrBetween_keys.year = {'<meta name="citation_publication_date" content="','/'};
    extrBetween_keys.journal = {'<meta name="citation_journal_title" content="','>'};
    extrBetween_keys.articletype = '';
    extrBetween_keys.authors = {'href="/action/doSearch?ContribAuthorStored=','">Search '};
    
elseif strcmp(article_publisher,'MDPI')
    extrBetween_keys.title = {'',''};
    
elseif strcmp(article_publisher,'AIMS_press')
    extrBetween_keys.title = {'',''};
    
elseif strcmp(article_publisher,'ASABE')
    extrBetween_keys.title = {'',''};    

elseif strcmp(article_publisher,'CNKI')
    extrBetween_keys.title = {'',''}; 
    
elseif strcmp(article_publisher,'Canadian_Science_Publishing')
    extrBetween_keys.title = {'',''}; 
    
elseif strcmp(article_publisher,'Royal_Society_of Chemistry')
    extrBetween_keys.title = {'',''}; 
    
elseif strcmp(article_publisher,'IWA publishing')
    extrBetween_keys.title = {'',''}; 
    
elseif strcmp(article_publisher,'Sielo.br')
    extrBetween_keys.title = {'',''}; 
    
elseif strcmp(article_publisher,'JEI online')
    extrBetween_keys.title = {'',''}; 
    
    
elseif strcmp(article_publisher,'Cambridge University Press')
    extrBetween_keys.title = {'',''}; 
    
    
elseif strcmp(article_publisher,'EGU Copernicus Publications')
    extrBetween_keys.title = {'',''}; 
    
elseif strcmp(article_publisher,'Unkown_Publisher')
    
end
    
    
   
    
end

% Error message
function ErrDispConsole(Param,list_papers_i)
    errmsg = ['> WARNING: Problem in "',Param,'" in ',list_papers_i];
    disp(errmsg);

end


% ELSEVIER parsing

function metadata = extrBetween_DB_ELSEVIER(html_data,url_link)

    
     try
        
        title = extractBetween(html_data,'<meta name="citation_title" content="','" />');
    catch
        title = 'not available';
        Param = 'title';
        ErrDispConsole(Param,list_papers_i);
    end
    try
        year = extractBetween(html_data,'<meta name="citation_publication_date" content="','" />');
        year = extractBefore(year,'/');
    catch
        year = 'not available';
        Param = 'year';
        ErrDispConsole(Param,list_papers_i);
    end
    try   
        journal = extractBetween(html_data,'<meta name="citation_journal_title" content="','" />');
    catch
        journal = 'not available';
        Param = 'journal';
        ErrDispConsole(Param,list_papers_i);
    end
    try
        article_type = extractBetween(html_data,'<meta name="citation_article_type" content="','" />');
    catch
        article_type = 'not available';
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
        authors_name = 'not available';
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
        keywords = 'not available';
        Param = 'keywords';
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
      
      num_highlights = numel(highlights(:,1));
      
      if ~isempty(highlights_cut)
          other_key = 'class="list-description"><p ';
          abstract_s = strfind(highlights_cut,other_key); 
          highlights_cut = html_data(abstract_s+numel(start_key):end);
          
          
      else
         highlights = 'not available';
        Param = 'highlights';
         ErrDispConsole(Param,list_papers_i);
         num_highlights = 0;
      end
      
     catch
        highlights = 'not available';
        Param = 'highlights';
         ErrDispConsole(Param,list_papers_i);
         num_highlights = 0;
     end
    
     
     
    try
        % Abstract (some html code remains at the start, but should not be
        % problematic)
        start_key = 'class="Abstracts';
        abstract_s = strfind(html_data,start_key);
        abstract_cut = html_data(abstract_s+numel(start_key):end);
        %other_key = 'abstract-sec';
        %abstract_s = strfind(abstract_cut,other_key);
        %abstract_cut = abstract_cut(numel(other_key)+abstract_s(1):end);
                
        end_key = '</p>';
        abstract_s = strfind(abstract_cut,end_key);
        
        % If there are highlights, the html changes a bit
        if num_highlights == 0
            start_i = 1;
            end_i = abstract_s(1)-1;
        else
            start_i = abstract_s(num_highlights+1);
            end_i = abstract_s(num_highlights+2);  
        end
        abstract_cut = abstract_cut(start_i:end_i);
        
        find_textstart = '">';
        abstract_s = strfind(abstract_cut,find_textstart);
        abstract_cut = abstract_cut(abstract_s(end)+numel(find_textstart):end);
       
        abstract = erase(abstract_cut,'<p>');
        if strcmp(abstract(end),'<')
            abstract = abstract(1:end-1);
        end
        
    catch
        abstract = 'not available';
        Param = 'abstract';
        ErrDispConsole(Param,list_papers_i);
    end
    
     % get URL
     %start_key = '<link rel="canonical" href="';
     %url_link_init = strfind(html_data,start_key);
     %url_link = html_data(url_link_init+numel(start_key):end);
     %end_key = '" />';
     %url_link_end = strfind(url_link,end_key);
     %url_link = url_link(1:url_link_end(1)-1);     

    metadata = {title,year,journal,article_type,authors_name,keywords,abstract,highlights,url_link};
    

end

function  metadata = extrBetween_DB_SPRINGER(html_paper,url_link)
        
    title = extractBetween(html_paper,'<meta name="citation_title" content="','" />');
    year = {'<meta name="citation_publication_date" content="','" />'};
    journal = {'<meta name="citation_journal_title" content="','" />'};
    article_type = {'<meta name="citation_article_type" content="','" />'};
    %authors_name
    %keywords =
    %abstract = 
    %highlights = 
    %url_link = doi;
    
     metadata = {title,year,journal,article_type,authors_name,keywords,abstract,highlights,url_link};
    
end  
