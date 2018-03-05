function new_tree = extract_subtree(tree, root)

new_tree = [tree(root)];
new_tree(1).parent = 0;
tree_ix = find([tree.parent] == root);
parent = [1*ones(1, length(tree_ix))];

while ~isempty(tree_ix)
    tree_ix_new = [];
    new_parent = [];
    for ix=1:length(tree_ix)
        node = tree(tree_ix(ix));
        node.parent = parent(ix);
        new_tree = [new_tree; node];
        tree_index = find([tree.parent] == tree_ix(ix));
        tree_ix_new = [tree_ix_new tree_index];
        new_parent = [new_parent length(new_tree)*ones(1,length(tree_index))];
    end
    tree_ix = tree_ix_new;
    parent = new_parent;
end