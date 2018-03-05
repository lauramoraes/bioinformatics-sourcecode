function tree_list = construct_tree_list(folders)
%% Construct tree list given a folders list

tree_list = {};

for i=1:size(folders,1)
    fname=fullfile(folders(i), 'tree.mat');
    load(fname{1});
    tree_list = vertcat(tree_list, classification_tree);
end