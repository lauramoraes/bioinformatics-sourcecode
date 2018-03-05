function [ tree_final ] = create_next_level(dataset_path, first_list_path, tree_result, available_classes, marc, total, classification_tree, parent)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    tree_final = []; 
    [first_list, all_lists] = create_possible_lists(dataset_path, first_list_path, tree_result, available_classes, marc, total);
    for item=1:size(first_list, 1)
        fprintf('Partition %d', item)
        
        tree_folder = strcat(tree_result, '/', int2str(item))
        if ~exist(tree_folder, 'dir')
            mkdir(tree_folder);
        end
        fprintf('Folder %s', tree_folder)
        tree_new = classification_tree;
        [train_set_ldata, train_set_rdata, node, found_singleton] = create_node_model(dataset_path, parent, available_classes, first_list(item,:), total);
        classification_tree = [classification_tree; node]
        pause
      
        if found_singleton == true
            continue;
        end
        
        parent = (size(tree_new,1))+1;
        
        train_set = train_set_ldata';
        save(strcat(tree_folder, '/ldata.mat'), 'train_set');
        ltree = create_next_level(strcat(tree_folder, '/ldata.mat'), first_list_path, tree_folder, node.llist, marc, total, tree_new, parent);
    
        train_set = train_set_rdata';
        save(strcat(tree_folder, '/rdata.mat'), 'train_set');
        rtree = create_next_level(strcat(tree_folder, '/rdata.mat'), first_list_path, tree_folder, node.rlist, marc, total, tree_new, parent);
        
        tree_final = [tree_final; ltree; rtree];
    end
end

