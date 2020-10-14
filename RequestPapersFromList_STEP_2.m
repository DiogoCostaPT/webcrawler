
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
        options = weboptions('ContentType','text','RequestMethod','get');
       
        url_link_clean = {};
        %mkdir(folderpapers);
        files_list_raw = dir(new_dir);
        files_list = {files_list_raw.name};
        
        for  i = 1:1:numel(url_list)

            url_link = url_list{i};
            code_loc = strfind(url_link,'/');
            filename = url_link(code_loc(end)+1:end);
            exists_paper = ~isempty(find(contains(files_list,[filename,'.mat'])==1));
            isjournalref = contains(url_link,'/journal/');
            isnotpaper = contains(url_link,'.pdf');
            isrefworks = contains(url_link,'/referenceworks/');
            isbookseries = contains(url_link,'/bookseries/');
            isbook = contains(url_link,'/book/');

            if exists_paper
               url_link_clean = [url_link_clean,url_link];
               msg = ['> Had already been Saved: ',url_link];
               formatid = ['%s',num2str(numel(msg)),'\n'];
               disp(msg); 
               fprintf(fd,formatid,msg);
            elseif isjournalref || isnotpaper || isrefworks || isbookseries || isbook
               msg = ['> WARNING: Not a paper page (excluded): ',url_link];
               formatid = ['%s',num2str(numel(msg)),'\n'];
               disp(msg); 
               fprintf(fd,formatid,msg);
            else
                try
                    pause(pausetime);
                    html_data = webread(url_link,options);              
                    title_name = extractBetween(html_data,'<meta name="citation_title" content="','" />');
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
                catch
                    msg = ['> WARNING: Server returned error: ',url_link];
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