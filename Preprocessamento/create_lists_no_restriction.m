function first_list = create_list_no_restriction(max_number)
%% Script to create list with all possible combinations, not fixing number
%% of elements in the lists
% Parameters:
% max_number = highest number in list

first_list = [];
for i=1:floor(max_number/2)
    first_list_temp = create_first_list(max_number,i);
    zero_matrix = zeros(size(first_list_temp,1),size(zeros(1,max_number-1),2)-size(first_list_temp,2));
    first_list_temp = [first_list_temp, zero_matrix];
    first_list = vertcat(first_list, first_list_temp);
end