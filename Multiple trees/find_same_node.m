function [same_struct, node_divisions] = find_same_node(trees, node)
%% Compare in given trees if the node is the same

same_struct = [];
node_divisions = {};

for i=1:size(trees,1)
    current_tree = trees{i};
    if size(current_tree) < node
        same_struct(i) = 0;
        continue;
    end
    node_div = mat2str(current_tree(node).listA);
    ismember(node_div, node_divisions);
    if ~ismember(node_div, node_divisions)
        node_divisions = vertcat(node_divisions, node_div);
    end
    index = find(ismember(node_divisions, node_div));
    same_struct(i) = index;
end