function [index, classification_tree] = next_level(classification_list,parent, i, classification_tree, available_classes)

% Trivial solution for the recursive function
if i > size(classification_list,1)
    index = -1;
    return;
end

% Define key for this node
node.key = available_classes;

% Pretty print for unknown class
if isempty(node.key)
    node.key = '??';
end

% Fill other node info
node.parent = parent;
% Possible solutions for the children
node.llist = intersect(available_classes, classification_list(i).listA);
node.rlist = intersect(available_classes, classification_list(i).listB);
node.lchild = -1;
node.rchild = -1;
node.accuracy = classification_tree(parent).accuracy_classified;
node.accuracy_classified = (classification_tree(parent).accuracy_classified*classification_list(i).accuracy)/100;

index = (size(classification_tree,1))+1;
classification_tree = [classification_tree; node];

% Stop conditions (for pretty tree print)
% Stop if already found singleton
if ((isequal(node.llist, node.key) && length(node.key) == 1) || (isequal(node.rlist, node.key) && length(node.key) == 1))
    return;
end

% Stop with there aren't any possibilities anymore
if (isempty(node.llist) && isempty(node.rlist))
    return;
end

% Do the same for the children
[node.lchild, classification_tree] = next_level(classification_list, index, i+1, classification_tree, node.llist);
[node.rchild, classification_tree] = next_level(classification_list, index, i+1, classification_tree, node.rlist);

classification_tree(index) = node;