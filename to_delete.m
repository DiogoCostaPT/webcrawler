
subdir = 'papers/';
folders = dir(subdir);

folders = {folders.name};

for i = 1:numel(folders)
   
    folder_i = folders{i};
    
    yes = contains(folder_i,'%22climate%20change%22%20AND%20');
    
    if yes
       folder_i_new = strrep(folder_i,'%22climate%20change%22%20AND%20','"climate%20change"%20AND%20');
        
        movefile([subdir,folder_i],[subdir,folder_i_new]);
    end
    
end
