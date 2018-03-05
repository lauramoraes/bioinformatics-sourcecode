function tree_struct = add_child_property(tree_struct)

tree = tree_struct{size(tree_struct, 1)};

for node=1:size(tree,1)
    child = find([tree.parent] == node);
    tree(node).childs = child;
end

tree_struct{size(tree_struct, 2)} = tree;