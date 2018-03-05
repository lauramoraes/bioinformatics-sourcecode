function tree = join_tree(tree_l, tree_r, node)

tree = [node; tree_l];
tree(1).parent = 0;
for i=2:size(tree,1)
    tree(i).parent = tree(i).parent + 1;
end
threshold = size(tree,1);
tree_r(1).parent = tree_r(1).parent + 1;
for i=2:size(tree_r,1)
    tree_r(i).parent = tree_r(i).parent + threshold;
end
    
tree = [tree; tree_r];
end