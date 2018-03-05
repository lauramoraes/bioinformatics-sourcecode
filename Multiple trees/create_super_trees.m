
level = 4;
tree_result = strcat('Resultados Node/Round1/1/Level', int2str(level));

join_list = [1 3;]
tree_list = {};

for row=1:size(join_list,1)
    tree1_path = strcat(folders{join_list(row, 1)}, '/tree.mat');
    tree2_path = strcat(folders{join_list(row, 2)}, '/tree.mat');
    
    fname=fullfile(tree1_path);
    load(fname);
    plot_tree(classification_tree, [50 50 50 50 50]);
    pause
%     tree_l = delete_node(classification_tree, 5);
%     plot_tree(tree_l, [50 50 50 50 50]);
%     pause
%     tree_l = delete_node(tree_l, 1);
    tree_l = extract_subtree(classification_tree, 2);
    plot_tree(tree_l, [50 50 50 50 50]);
    pause

    fname=fullfile(tree2_path);
    load(fname);
    
    plot_tree(classification_tree, [50 50 50 50 50]);
    pause
%     tree_r = delete_node(classification_tree, 4);
%     plot_tree(tree_r, [50 50 50 50 50]);
%     pause
%     tree_r = delete_node(tree_r, 1);
    tree_r = extract_subtree(classification_tree, 3);
    plot_tree(tree_r, [50 50 50 50 50]);
    pause
    node = classification_tree(1);
    
    tree = join_tree(tree_l, tree_r, node);
    plot_tree(tree, [50 50 50 50 50]);
%     
%     tree_r = tree;
%     tree_l = classification_tree(2);
%     tree_l.parent = 0;
%     node = classification_tree(1);
    
%     tree = join_tree(tree_l, tree_r, node);
%     plot_tree(tree, [50 50 50 50 50]);
    
    tree_list = [tree_list; tree]
    save(strcat(tree_result, '/tree_list.mat'), 'tree_list')
end