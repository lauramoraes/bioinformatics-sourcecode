function first_list = create_first_list(quantity, in_group)
%% Create a list with the combinations from 1..quantity taken 'in_group'
%% elements at a time. The elements not in the first list are stored in a 
% second list.

% Parameters:
% quantity: total number of elements
% in_group: how many elements should be in first group

first_list = combnk(1:quantity, in_group);

