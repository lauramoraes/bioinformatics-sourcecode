function classification_tree = calculate_classes(classification_list)
%% Function that goes through the classification list and calculates the
%% possible class outputs
% Parameters:
% classification_list: struct array with fields listA, listB, w, error
% listA: linfomas classified as A
% listB: linfomas classified as B
% w: weight vector for linear regression
% error: error percentage for test set

i = 1;
classification_tree = [];
root.key = horzcat(classification_list(1).listA, classification_list(1).listB);
root.parent = 0;
root.llist = classification_list(1).listA;
root.rlist = classification_list(1).listB;
root.lchild = -1;
root.rchild = -1;
root.accuracy = 100;
root.accuracy_classified = classification_list(1).accuracy;

classification_tree = [classification_tree; root];

[root.lchild, classification_tree] = next_level(classification_list, 1, i+1, classification_tree, root.llist);
[root.rchild, classification_tree] = next_level(classification_list, 1, i+1, classification_tree, root.rlist);

classification_tree(1) = root;

