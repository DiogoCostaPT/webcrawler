
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
      
    else 
        metadata = extrBetween_DB_SPRINGER(html_paper,url_link);
    end
        

   %{ 
elseif strcmp(article_publisher,'Taylor_and_Francis')
    extrBetween_keys.title = {'',''};

elseif strcmp(article_publisher,'Wiley')
    metadata = extrBetween_DB_WILEY(html_paper,url_link);
    
    
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
    %}
    
    
   
    
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
        ErrDispConsole(Param,url_link);
    end
    try   
        journal = extractBetween(html_data,'<meta name="citation_journal_title" content="','" />');
    catch
        journal = 'not available';
        Param = 'journal';
        ErrDispConsole(Param,url_link);
    end
    try
        article_type = extractBetween(html_data,'<meta name="citation_article_type" content="','" />');
    catch
        article_type = 'not available';
        Param = 'article_type';
        ErrDispConsole(Param,url_link);
    end
    
    
    try
        % Parsing Author names
        start_key = '"#name":"given-name","_":"';
        
        auth_givenName = extractBetween(html_data,'given-name">','<');
        auth_surname = extractBetween(html_data,'surname">','<');
        
        authors_name = {};
        for i = 1:numel(auth_givenName)
            authors_name_i = [auth_givenName{i},' ',auth_surname{i}];
            authors_name = [authors_name;authors_name_i]; 
        end

    catch
        authors_name = 'not available';
        Param = 'authors_name';
        ErrDispConsole(Param,url_link);
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
        ErrDispConsole(Param,url_link);
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
         ErrDispConsole(Param,url_link);
         num_highlights = 0;
      end
      
     catch
        highlights = 'not available';
        Param = 'highlights';
         ErrDispConsole(Param,url_link);
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
        ErrDispConsole(Param,url_link);
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
    
   
    % Title
    metadata_i = {};
    NOT_FOUND_text = {'not found'};
    
    struct_fields = {...
                    'Paper_title',...           % 1
                    'Year',...                  % 2
                    'Journal_name',...          % 3
                    'Type_of_Publication',...   % 4 - only available for ELSEVIER
                    'Authors',...               % 5
                    'Keywords',...              % 6
                    'Abstract',...              % 7
                    'Highlights',...            % 8
                    'URL',...
                    };
    % 1) title
    boundwords.(genvarname(struct_fields{1})) = {...
        '<meta property="og:title" content="','"';...
        '<meta name="citation_title" content="','"';... % most publishers
        '<title>','</title>',... ACS pubs
        };
    % 2) Year
    boundwords.(genvarname(struct_fields{2})) = {...
        'class="epub-date">','</span></div>';...
        'name="dc.Date" scheme="WTN8601" content="','"';...
        'class="date-separator">:</span><span class="pub-date-value">','</span><div class="article_header-history';...
        '<span class="article-date">','</span>';...
        'name="citation_online_date" content="','/';...
        'name="citation_publication_date" content="','"';...
        '<meta name="DC.issued" content="','/';...
        'id="param-dbname" value="CJFDLAST','"';...
        'name="citation_date" content="','"';...
        };
    % 3) Journal name
    boundwords.(genvarname(struct_fields{3})) = {...
        'title="Journal cover:','" alt="" ';...
        'meta name="citation_journal_title" content="','"';...
        'name="citation_publication_date" content="','"';...
        'name="citation_journal_title" content="','">';...
        'class="cit-title"><i>','</i></span>';...
        };
    % 4) Type of publication
    boundwords.(genvarname(struct_fields{4})) = {};
    % 5) Authors
    boundwords.(genvarname(struct_fields{5})) = {...
        '<meta name="citation_author" content="','"';...
        '<meta name="DC.Creator" content="','" />';...
        '<meta name="dc.Creator" content="','" />';...
        'TurnPageToKnetV(''au'',''','''';...
        'name="citation_author" content="','"';...
        };
    % 6) Keywords
    boundwords.(genvarname(struct_fields{6})) = {...
        '<meta name="citation_keywords" content="','>';...
        'name="keywords" content="','"';...
        'data-keyword="&quot;','&quot';...
        'data-keywords="','"></div>';...
        '<p><i><b>Keywords</b></i>';'</p>';...
        };
    % 7) Abstract
    boundwords.(genvarname(struct_fields{7})) = {...
        '<p><span class="paraNumber">[1] </span>','</p>';...
        '<div class="article-section__content en main">','</p>';...
        'id="Abs1-content"><p>','</p></div></div></section>';...
        'rscart38">','</p>';...
        'class="articleBody_abstractText">','</p>';...
        'data-abstract-type="normal">',' </div>';...
        'class="summary-title"><b>Abstract</b></p><p>','<';...
        'class="summary-title"><b>ABSTRACT</b></p>','</p>';...
        'roperty="name">Abstract</h2><div role="paragraph">','<';...
        'class="abstract-text">','<';...
        'face="Verdana, Arial, Helvetica, sans-serif"><b>ABSTRACT</b></font></p>     <p><font size="2" face="Verdana, Arial, Helvetica, sans-serif">','</font></p>';...
        '<abstract><p><b><sc>Abstract. </sc></b>','</p>"/>';...
        '<section class="abstract"><p>','</p></section>';...
        '<div class="art-abstract in-tab hypothesis_container">',' <a href';...
        '<meta name="DC.Description" xml:lang="en" content="';'"/>';...
        };
    % 8) Highlights
    boundwords.(genvarname(struct_fields{8})) = {};
                    
    for f = 1:numel(struct_fields)
        success_flag = false;
        notFound_flag = false;
        i = 0; 
        while ~success_flag && ~notFound_flag
            i = i + 1;
            try
                metadata_i.(genvarname(struct_fields{f})) = extractBetween(...
                                    html_paper,...
                                    boundwords.(genvarname(struct_fields{f}))(i,1),...
                                    boundwords.(genvarname(struct_fields{f}))(i,2));
                if ~isempty(metadata_i.(genvarname(struct_fields{f})))
                    success_flag = true;
                end
            catch
                notFound_flag = true;
            end
        end
        if notFound_flag
        	metadata_i.(genvarname(struct_fields{f})) = NOT_FOUND_text; 
        end
    end
    
    % 9) URL
    metadata_i.(genvarname(struct_fields{9})) = url_link;
    
    % Extra steps for some cases
    % year
    index = 2;
    if ~strcmp(metadata_i.(genvarname(struct_fields{index})),NOT_FOUND_text)
        nums = str2double(regexp(metadata_i.(genvarname(struct_fields{index})){:},'\d*','Match'));
        year = max(nums);
        metadata_i.(genvarname(struct_fields{index})) =  {year};
    end 
    
     % Abstract
    index = 7;
    if ~strcmp(metadata_i.(genvarname(struct_fields{index})),NOT_FOUND_text)
        if contains(metadata_i.(genvarname(struct_fields{index})),'<p>')
            abst = metadata_i.(genvarname(struct_fields{index})){:};
            metadata_i.(genvarname(struct_fields{index})) = {extractAfter(...
                 abst,'<p>')};
        end
    end
    
        
    % Save results
    metadata = cell(1,numel(struct_fields));
    for f = 1:numel(struct_fields)
        metadata{f} = metadata_i.(genvarname(struct_fields{f}));
    end
end  

%{
function metadata = extrBetween_DB_WILEY(html_paper,url_link)
    
    extrBetween_keys.title = {'<meta property="og:title" content="','/>'};
    extrBetween_keys.year = {'<meta name="citation_publication_date" content="','/'};
    extrBetween_keys.journal = {'<meta name="citation_journal_title" content="','>'};
    extrBetween_keys.articletype = '';
    extrBetween_keys.authors = {'href="/action/doSearch?ContribAuthorStored=','">Search '};
end
%}