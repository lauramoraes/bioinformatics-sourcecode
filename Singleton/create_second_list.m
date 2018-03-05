function separated_list = create_second_list(quantity, first_list)
%% Create second list of elements, containing the ones not present in the
%% first list
% Parameters:
% quantity: quantity of classes to split
% first_list: first_list array
separated_list{1} = first_list(first_list ~= 0);
second_list = [];

for i=1:quantity
    index = find(separated_list{1}==i);
    if ~any(index)
         second_list = [second_list i];
    end
end

separated_list{2} = second_list;