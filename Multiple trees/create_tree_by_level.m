function [trees, folders] = create_tree_by_level(dataset_path, first_list_path, tree_result_base, available_classes, marc, total, level)
level = 1;
keep_level = true;
max_trees = 3000;

% While level
while keep_level
    fprintf('Starting level %d\n', level)
    remove_dirs = {};
    
    % Create level folder
    tree_result = strcat(tree_result_base, '/Level ', int2str(level));
    
    if ~exist(tree_result, 'dir')
        mkdir(tree_result);
    end
    
    % Create branches for each side of each possible node
    if level == 1
        middleware_tree(dataset_path, first_list_path, tree_result, available_classes, marc, total, [], 1);
    else
        for dataset=1:size(dataset_list, 1)
            fprintf('Working on node %d, folder %s for level %d\n', dataset, dataset_list(dataset,:), level)
            
            dataset_folder = strtrim(dataset_list(dataset,:));
            ldataset = strcat(dataset_folder,'/ldata.mat');
            rdataset = strcat(dataset_folder,'/rdata.mat');
            treeset = strcat(dataset_folder,'/tree.mat');
            % Tree finishes in this node
            if (~exist(ldataset, 'file')) && (~exist(rdataset, 'file'))
                % Get next available folder
               all_folders = dir(tree_result);
               next_folder = size(all_folders([all_folders.isdir]),1)-1;                           
               tree_folder_data = strcat(tree_result, '/', int2str(next_folder));
%                disp('dead node')
%                pause
               mkdir(tree_folder_data);
               fprintf('Copy %s to %s\n', treeset, tree_folder_data)
               copyfile(treeset, tree_folder_data);
            % Tree grows only to right side
            elseif ~exist(ldataset, 'file')
                middleware_tree(rdataset, first_list_path, tree_result, available_classes, marc, total, treeset);
            % Tree grows only to left side
            elseif ~exist(rdataset, 'file')
                middleware_tree(ldataset, first_list_path, tree_result, available_classes, marc, total, treeset);
            % Tree grows to both sides
            else
                tree_path_ldata = middleware_tree(ldataset, first_list_path, tree_result, available_classes, marc, total, treeset);
                fprintf('tree path for ldata %s on node %d, folder %s for level %d\n', mat2str(tree_path_ldata), dataset, dataset_list(dataset,:), level)
                pathstr = [];
                % For each left side, copy result tree to the right side
                for tree=1:size(tree_path_ldata,1)
                    ltreeset = strtrim(tree_path_ldata(tree,:));
                    tree_path_rdata = middleware_tree(rdataset, first_list_path, tree_result, available_classes, marc, total, ltreeset);
                    fprintf('Working on rdata %s for ldata %s on node %d, folder %s for level %d\n', mat2str(tree_path_rdata), tree_path_ldata(tree,:), dataset, dataset_list(dataset,:), level)
                    % For each right side, copy back the result tree to the
                    % left side
                    for tree_rdata=1:size(tree_path_rdata,1)
                       rtreeset = strtrim(tree_path_rdata(tree_rdata,:));
                       
                       % Get next available folder
                       all_folders = dir(tree_result);
                       next_folder = size(all_folders([all_folders.isdir]),1)-1;
                       tree_folder_ldata = strcat(tree_result, '/', int2str(next_folder));
%                        disp('copy from left to right')
%                        pause
                       mkdir(tree_folder_ldata);

                       [pathstr,name,ext] = fileparts(ltreeset);
                       fprintf('Copy %s to %s\n', pathstr, tree_folder_ldata)
                       copyfile(pathstr, tree_folder_ldata);
                       fprintf('Copy %s to %s\n', rtreeset, tree_folder_ldata)
                       copyfile(rtreeset, tree_folder_ldata);
                    end
                    if ~isempty(pathstr)
                        remove_dirs = [remove_dirs; pathstr];
                    end
                end
            end
            all_folders = dir(tree_result);
            number_of_folders = size(all_folders([all_folders.isdir]),1)-2;
            if (number_of_folders-size(remove_dirs,1)) > max_trees
                fprintf('Reached %d trees in folder %s. Going to the next level\n', (number_of_folders-size(remove_dirs,1)), tree_result)
%                 pause
                break;
            end
        end
    end
    
    % Remove incomplete dirs
    remove_dirs = char(remove_dirs);
    for direct=1:size(remove_dirs,1)
        pathstr = strtrim(remove_dirs(direct,:));
        fprintf('Removing dir %s\n', pathstr)
        rmdir(pathstr, 's');
    end
    
    i=1;
    dataset_list = {};
    trees = {};
    folders = {};
    
    all_folders = dir(tree_result);
    all_folders = all_folders([all_folders.isdir]);
    for i=3:size(all_folders,1)
        % Create list of available node continuation
        tree_folder = strcat(tree_result, '/', all_folders(i).name);
        dataset_list = [dataset_list; tree_folder];
        
        % Load trees from last level
        fname=fullfile(strcat(tree_folder,'/tree.mat'));
        load(fname);
        trees = [trees; classification_tree];
        folders = [folders; tree_folder];
    end
     dataset_list = char(dataset_list);
%     ix = randperm(size(dataset_list,1));
%     dataset_list = dataset_list(ix,:);
    
    level = level + 1;
    
    if level == 15
        keep_level = false;
    end
end
