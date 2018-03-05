function stop = check_singletons(classes, number_of_classes)
%% Function to check if every singleton was already found
% Parameters:
% classes: struct containing classes in level order of tree nodes
% number_of_classes: number of different singletons to find

singleton = zeros(1, number_of_classes);
for i=1:size(classes, 1)
    if length(classes(i).key) == 1
        singleton(classes(i).key) = 1;
    end
    if all(singleton)
        stop = 1;
        break
    else
        stop = 0;
    end
end
