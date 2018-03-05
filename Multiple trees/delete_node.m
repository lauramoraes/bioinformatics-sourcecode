function tree = delete_node(tree, node_ix)

for i=1:size(tree,1)
    if tree(i).parent > node_ix
        tree(i).parent = tree(i).parent-1;
    elseif tree(i).parent == node_ix
        tree(i).parent = tree(node_ix).parent;
    end
end

tree(node_ix) = [];
end

