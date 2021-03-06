%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2021, Diogo Costa, diogo.pinhodacosta@canada.ca
% This file is part of WebCrawler tool.

% This program, WebCrawler tool, is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) later version.

% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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
        year = str2double(extractBefore(year,'/'));
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
        auth_givenName = extractBetween(html_data,'given-name">','<');
        auth_surname = extractBetween(html_data,'surname">','<');
        
        authors_name = [];
        for i = 1:numel(auth_givenName)
            authors_name_i = [auth_givenName{i},' ',auth_surname{i}];
            authors_name = [authors_name,authors_name_i,', ']; 
        end
        authors_name = authors_name(1:end-2);

    catch
        authors_name = 'not available';
        Param = 'authors_name';
        ErrDispConsole(Param,url_link);
    end
    
    try
        % Parsing Keywords
        keywords_raw = extractBetween(html_data,'class="keyword"><span','</span></div><div');
        keywords = extractAfter(keywords_raw{1},'>');
        for i = 2:numel(keywords_raw)
            keyword_i = extractAfter(keywords_raw{i},'>');        
            keywords = [keywords,', ',keyword_i];
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
         highlights = 'not found';
        Param = 'highlights';
         ErrDispConsole(Param,url_link);
         num_highlights = 0;
      end
      
     catch
        highlights = 'not found';
        Param = 'highlights';
         ErrDispConsole(Param,url_link);
         num_highlights = 0;
     end
    
     
     
    try
        % Abstract (some html code remains at the start, but should not be
        % problematic)
        start_key = 'class="Abstracts';
        %abstract_s = strfind(html_data,start_key);
        %abstract_cut = html_data(abstract_s+numel(start_key):end);
        %other_key = 'abstract-sec';
        %abstract_s = strfind(abstract_cut,other_key);
        %abstract_cut = abstract_cut(numel(other_key)+abstract_s(1):end);
        
        end_key = '</p></div></div></div'; 
                  
        abstract_cut = extractBetween(html_data,start_key,end_key);
        
                
        % If there are highlights, the html changes a bit
        if num_highlights == 0
            if strfind(abstract_cut{:},'</p></div></div><div')
                abstract_cut = extractBefore(abstract_cut,'</p></div></div><div');
            end
            temp = abstract_cut{:};
            loc = strfind(temp,'">');
            abstract_cut = temp(loc(end)+2:end);
            abstract = {abstract_cut};
            %abstract_cut = extractAfter(abstract_cut,'<p>');
        else
            abstract_cut = extractAfter(abstract_cut,'u-margin-xs-bottom">Abstract</h2><div'); 
            abstract_cut = extractAfter(abstract_cut,'">');
            abstract = extractAfter(abstract_cut,'">');
             if strfind(abstract{:},'</p></div></div><div')
                abstract = extractBefore(abstract,'</p></div></div><div');
            end
        end
        
       
        
    catch
        abstract = {'not found'};
        Param = 'abstract';
        ErrDispConsole(Param,url_link);
    end
    
    abstract = abstract{:};
    
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
    NOT_FOUND_text = 'not found';
    
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
        '/><meta name="dc.Title" content="','"';...
        '<meta property="og:title" content="','"';...
        '<meta name="citation_title" content="','"';... % most publishers
        %'<title>',' - ';...
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
        '<meta name="citation_keywords" content="','"  />';...
        '<meta name="Keywords" content="','" />';...
        '<meta name="citation_keywords" content="','">';...
        'name="keywords" content="','"';...
        'data-keyword="&quot;','&quot';...
        'data-keywords="','"></div>';...
        '<p><i><b>Keywords</b></i>','</p>';...
        '"Keywords":"','"';...
        'href="/action/doSearch?ConceptID=','">';...
        'TurnPageToKnetV(''kw'',''',''',';...
        'sans-serif"><b>Keywords:</b> ','</font></p>';...
        '<a href="/search/keyword/','"';...
        '<meta name="citation_keywords" content="','"  />',...
        };
    % 7) Abstract
    boundwords.(genvarname(struct_fields{7})) = {...
        '<p><span class="paraNumber">[1] </span>','</p>';...
        '<div class="article-section__content en main">','</div>';...
        'id="Abs1-content"><p>','</p></div></div></section>';...
        'rscart38">','</p>';...
        'class="articleBody_abstractText">','</p>';...
        'data-abstract-type="normal">',' </div>';...
        'class="summary-title"><b>Abstract</b></p><p>','</p></div></div><div';...
        'class="summary-title"><b>Abstract</b></p><p>','<';...
        'class="summary-title"><b>ABSTRACT</b></p>','</p>';...
        'property="name">Abstract</h2><div role="paragraph">','</div></section><section';...
        'class="abstract-text">','<';...
        'face="Verdana, Arial, Helvetica, sans-serif"><b>ABSTRACT</b></font></p>     <p><font size="2" face="Verdana, Arial, Helvetica, sans-serif">','</font></p>';...
        '<abstract><p><b><sc>Abstract. </sc></b>','</p>"/>';...
        '<section class="abstract"><p>','</p></section>';...
        '<div class="art-abstract in-tab hypothesis_container">','">';...
        '<div class="art-abstract in-tab hypothesis_container">',' <a ';...
        '<meta name="DC.Description" xml:lang="en" content="','"/>';...
        '<meta name="citation_abstract" content="','"  />';...
        '<meta name="description" content="','/>';...
        'name="citation_abstract" content="&lt;p&gt;&lt;strong&gt;Abstract.&lt;/strong&gt;','&lt;/p&gt;"/>';...
        '<meta name="description" content="','"/>';...
        '<meta name="DC.Description" content="','" />';...
        '<meta name="citation_abstract" content="&lt;p&gt;&lt;strong class=&quot;journal-contentHeaderColor&quot;&gt;Abstract.&lt;/strong&gt;','&lt;/p&gt;"/>';...
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
        if numel((num2str(year)-'0')) > 4
            a = num2str(year);
            b = a(1:4);
            year = str2num(b);
        end
        metadata_i.(genvarname(struct_fields{index})) =  {year};
    end
    
    % 3) Journal name
    index = 3;
    if (iscell(metadata_i.(genvarname(struct_fields{index}))) &&...
            numel(metadata_i.(genvarname(struct_fields{index})))>1)
        journal_name = metadata_i.(genvarname(struct_fields{index})){1};
        metadata_i.(genvarname(struct_fields{index})) = journal_name;
    end
    
     % Abstract
    index = 7;
    if ~strcmp(metadata_i.(genvarname(struct_fields{index})),NOT_FOUND_text)
        if contains(metadata_i.(genvarname(struct_fields{index})),'<p>')
            abst = metadata_i.(genvarname(struct_fields{index})){:};
            metadata_i.(genvarname(struct_fields{index})) = {extractAfter(abst,'<p>')};
        end
        if contains(metadata_i.(genvarname(struct_fields{index})),'<a')
            abst = metadata_i.(genvarname(struct_fields{index})){:};
            metadata_i.(genvarname(struct_fields{index})) = {extractBefore(abst,'<a')};
        end
         if contains(metadata_i.(genvarname(struct_fields{index})),'</div>')
            abst = metadata_i.(genvarname(struct_fields{index})){:};
            metadata_i.(genvarname(struct_fields{index})) = {extractBefore(abst,'</div>')};
        end
    end
    
     % Authors
    index = 5;
    authors = metadata_i.(genvarname(struct_fields{index}));
    if iscell(authors)
        metadata_i.(genvarname(struct_fields{index})) = '';
        authors_i = '';
        authors_all = authors{i}; 
        for i = 2:numel(authors)
            authors_all = [authors_all,', ',authors{i}]; 
        end
    else
        authors_all = '';
    end
    metadata_i.(genvarname(struct_fields{index})) = authors_all;
    
    % Keywords
    index = 6;
    keywords = metadata_i.(genvarname(struct_fields{index}));
    if iscell(keywords)
        metadata_i.(genvarname(struct_fields{index})) = '';
        concowords = [];
        for i = 1:numel(keywords)
            keyword_i = keywords{i};
            if contains(keyword_i,'=')
                keyword_i = extractAfter(keyword_i,'=');
            end
            concowords = [concowords,keyword_i,', '];
        end
    else
        concowords = keywords;
    end
    concowords = strrep(concowords,'"','');
    if strcmp(concowords,'') || strcmp(concowords,', ') || strcmp(concowords,'"') || strcmp(concowords,NOT_FOUND_text)
        concowords = [NOT_FOUND_text,'  ']; 
    end
    metadata_i.(genvarname(struct_fields{index})) = lower(concowords(1:end-2)); 
        
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