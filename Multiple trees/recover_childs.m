function tree_struct = recover_childs(tree_struct)

tree = tree_struct{1};

for node=1:size(tree,1)
    child = find([tree.parent] == node);
    if ~isempty(child)
        tree(node).lchild = child(1);
        tree(node).rchild = child(2);
    end
end

tree_struct{1} = tree;