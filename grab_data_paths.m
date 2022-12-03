function [paths, names, ids] = grab_data_paths(indx)

    % Rebecca Krall 12/1/22
    
    % Function to easily grab data from my local data folder. Organized
    % into subfolders for each experimental group.
    
    % Inputs:
    %   indx - list of integers referring to the output of listdlg for the
    %   subfolders in the directory. Useful to avoid having the user pick
    %   the groups at each call when doing the same groups consistently.
    %
    % Outputs:
    %   paths: list of the full path to the data folder for each individual
    %   animal
    %   names: name of each animal corresponding to paths above
    %   ids: group of each animal corresponding to paths above, derived
    %   from the subfolder.
    
    % Note: based on the folder structure, both the group and name can be
    % found in the paths variable. 

    groups = dir('C:\Users\natet\Desktop\Experimental_Data');
    groups = groups(cellfun(@(x) contains(x, lettersPattern), {groups.name}));
    
    if nargin < 1
        [indx,~] = listdlg('ListString',{groups.name});
    end
    
    groups = groups(indx);
    
    
    paths = [];
    names = [];
    ids = [];
    for i = 1:length(groups)
        files = dir(strcat(groups(i).folder,'\', groups(i).name));
        files = files(~contains({files.name}, '.'));
        
        filepaths = arrayfun(@(x) strcat(x.folder, '\', x.name), files, 'UniformOutput', false);
        names = cat(1, names, {files.name}');
        paths = cat(1, paths, filepaths);
        ids  = cat(1, ids, repmat({groups(i).name}, size(filepaths)));
    end

end
