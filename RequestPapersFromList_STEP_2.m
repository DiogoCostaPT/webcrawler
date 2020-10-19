
% Request and Save Papers from Previous Search

function RequestPapersFromList_STEP_2(dir4search,pausetime)


foldernames = dir(dir4search);  
foldernames = {foldernames.name};
foldernames(strcmp(foldernames,'.')) = [];
foldernames(strcmp(foldernames,'..')) = [];
    
h = waitbar(0,'Extracting papers from lists - HTML (STEP 2)');
set(h,'Position', [500 300 280 70]);

fd = fopen('webcrawler.log','w');
for k = 1:numel(foldernames)

    
    new_dir = [dir4search,'/',foldernames{k}];   

    matfilename = [new_dir,'/href_list.mat'];

    try
        load(matfilename);
               
        url_link_clean = {};
        %mkdir(folderpapers);
        files_list_raw = dir(new_dir);
        files_list = {files_list_raw.name};
        files_list = files_list(~strcmp(files_list,'.')); 
        files_list = files_list(~strcmp(files_list,'..')); 
        
        for  i = 1:1:numel(url_list)

            url_link = url_list{i};
            
            filename = strrep(url_link,'https://dx.doi.org/','');
            filename = strrep(filename,'.','_');
            filename = strrep(filename,'/','_');
            %filename = url_link(code_loc(end)+1:end);
            
            exists_paper = ~isempty(find(contains(files_list,[filename,'.mat'])==1));        
            
            %isjournalref = contains(url_link,'/journal/');
            %isnotpaper = contains(url_link,'.pdf');
            %isrefworks = contains(url_link,'/referenceworks/');
            %isbookseries = contains(url_link,'/bookseries/');
            %isbook = contains(url_link,'/book/');

            if exists_paper
               url_link_clean = [url_link_clean,url_link];
               msg = ['> Article already Saved: ',url_link];
               formatid = ['%s',num2str(numel(msg)),'\n'];
               disp(msg); 
               fprintf(fd,formatid,msg);
            %elseif isjournalref || isnotpaper || isrefworks || isbookseries || isbook
            %   msg = ['> WARNING: Not a paper page (excluded): ',url_link];
            %   formatid = ['%s',num2str(numel(msg)),'\n'];
            %   disp(msg); 
            %   fprintf(fd,formatid,msg);
            else
                
                found_flag = false;
                
                try
                    %html_data = webread(url_link); 
                    doi_html = safeDiogo_webread(url_link,pausetime);
                    
                    %% Try different publishers
    
                    % ELSEVIER (sience-direct)
                    if found_flag == false
                        publisherName = 'Elsevier';
                        try % ELSEVIER (sience-direct)
                            publisher_url_encoded = extractBetween(doi_html,...
                                'retrieve/articleSelectSinglePerm?Redirect=',...
                                '&amp;key=');

                            % decode publisher URL
                            publisher_url_decoded = publisher_url_encoded;
                            publisher_url_decoded = strrep(publisher_url_decoded,'%2F','/');
                            publisher_url_decoded = strrep(publisher_url_decoded,'%3A',':');
                            publisher_url_decoded = strrep(publisher_url_decoded,'%3F','?');
                            publisher_url_decoded = strrep(publisher_url_decoded,'%25','%');
                            publisher_url_decoded = strrep(publisher_url_decoded,'','');

                            url_list_s = publisher_url_decoded;
                            
                            % need to go to Science-Direct to retrieve the
                            % data
                            html_data_raw = safeDiogo_webread(publisher_url_decoded{:},pausetime);
                            html_data = {publisherName,url_link,html_data_raw};
                            
                            found_flag = true;

                        catch 
                            found_flag = false;
                        end
                    end
                    
                    % Multiple publishers that give info to doi.org
                    if found_flag == false
                        publisherNames_and_snippets_all = {...
                              'Springer','@SpringerLink';...
                              'Taylor_and_Francis','Taylor & Francis';...
                              'Wiley','<meta name="citation_publisher" content="John Wiley & Sons, Ltd">';...
                              'AGU_pubs','<span><a href="https://agupubs.onlinelibrary.wiley.com/';...
                              'MDPI','<meta content="mdpi" name="sso-service" />';...
                              'ACS_pubs','website:acspubs';...
                              'AIMS_press','<link rel="canonical" href="https://www.aimspress.com/';...
                              'ASABE','<meta property="og:image" content="https://elibrary.asabe.org/images/';...
                              'CNKI','<link rel="stylesheet" type="text/css" href="https://piccache.cnki.net/kdn/';
                              'Canadian_Science_Publishing','<title>Canadian Science Publishing</title>';...
                              'Royal_Society_of Chemistry','"name": "The Royal Society of Chemistry"';...
                              'IWA publishing','IWA Publishing</title>';...
                              'Sielo.br',' content="http://www.scielo.br/';...
                              'JEI online','<link rel="stylesheet" href="http://www.jeionline.org/lib/pkp/styles/pkp.css" type="text/css" />';...
                              'Cambridge University Press','<meta property="og:site_name" content="Cambridge Core" />';...
                              'EGU Copernicus Publications','<a href="http://www.egu.eu/" target="_blank">EGU.eu</a>';...
                              };
                                          
                        publisher_flag = ones(numel(publisherNames_and_snippets_all(:,1)),1) * false;
                        
                        for u = 1:numel(publisher_flag)
                            publisher_flag(u) = contains(doi_html,...
                                        publisherNames_and_snippets_all(u,2));  
                        end
                                
                        if sum(publisher_flag) == 1
                                html_data = {publisherNames_and_snippets_all{...
                                            find(publisher_flag==1),1},...
                                            url_link,...
                                            doi_html};
                                found_flag = true;
                            else
                                found_flag = false;
                        end
                    end


                    if found_flag == false
                        msg = ['> WARNING: Unkown Publisher: ',url_link];
                        formatid = ['%s',num2str(numel(msg)),'\n'];
                        disp(msg); 
                        fprintf(fd,formatid,msg);
                    
                        html_data = {'Unkown_Publisher',...
                                        doi_html};
                        found_flag = true;
                    end
                    
                     save([new_dir,'/',filename],'html_data');

                    %{
                    title_name = extractBetween(html_data,...
                        '<h2 xmlns:localzn="xalan://com.elsevier.scopus.biz.util.LocalizationHelper" class="h3">',...
                        '<span>(Article)</span><span>(<span id="openAccessNotice" class="text-nowrap">Open Access</span>)</span>');
                    if ~isempty(title_name)
                        url_link_clean = [url_link_clean,url_link];
                        save([new_dir,'/',filename],'html_data');
                        msg = ['> Saved: ',url_link];
                        formatid = ['%s',num2str(numel(msg)),'\n'];
                       disp(msg); 
                       fprintf(fd,formatid,msg);
                    else
                        msg = ['> WARNING: Not a paper page (excluded): ',url_link];
                        formatid = ['%s',num2str(numel(msg)),'\n'];
                       disp(msg); 
                       fprintf(fd,formatid,msg);
                    end
                    %}
                    
                catch
                    msg = ['> WARNING: Problem with doi.org link: ',url_link];
                    formatid = ['%s',num2str(numel(msg)),'\n'];
                    disp(msg); 
                    fprintf(fd,formatid,msg);
                end
            end
            waitbar(i/numel(url_list),h,...
                            {'Extracting papers from lists - HTML (STEP 2)',...
                            ['Keyword combination = ',num2str(k),' out of ',num2str(numel(foldernames))],...
                            ['Paper: ', num2str(i),' out of ',num2str(numel(url_list))]});

        end
        
        
    catch
         msg = ['> WARNING: file not found: ',matfilename];
        formatid = ['%s',num2str(numel(msg)),'\n'];
        disp(msg); 
        fprintf(fd,formatid,msg);
    end

end
    fclose(fd);
    close(h)