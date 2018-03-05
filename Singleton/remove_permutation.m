function first_list = remove_permutation(first_list, available_classes)
%% Remove permutation from list
% Parameters
% first_list: array containing the list of classes from one side
% available_classes: array containing available classes in that division

perm_index = [];
for i=1:size(first_list,1)
    found = false;
    if ismember(i,perm_index)
        fprintf('Continue on index %d\n', i)
        continue;
    end
    for j=2:size(first_list,1)
        if isempty(setdiff(available_classes, [first_list(i,:) first_list(j,:)]))
            fprintf('Found permutation %s and %s\n', mat2str(first_list(i,:)), mat2str(first_list(j,:)))
            perm_index = [perm_index j];
            found = true;
            break;
        end
    end
    if found == true
         fprintf('Continue in indexes %d and %d\n', i, j)
        continue;
    end
end

first_list(perm_index,:) = [];