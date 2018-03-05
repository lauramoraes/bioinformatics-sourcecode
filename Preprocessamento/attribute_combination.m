function total_attr = attribute_combination(max_number)
%% Script to create list with all possible combinations, not fixing number
%% of elements in the lists
% Parameters:
% max_number = highest number in list

total_attr = [];

for i=1:max_number
    attr_comb = combnk(1:max_number,i);
    zero_matrix = zeros(size(attr_comb,1),size(zeros(1,max_number),2)-size(attr_comb,2));
    attr_comb = [attr_comb, zero_matrix];
    total_attr = vertcat(total_attr, attr_comb);
end