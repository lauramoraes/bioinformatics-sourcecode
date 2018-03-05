function [train_set, test_set] = separate_train_and_test(dataset, train_share)
%% Separate dataset into train and test set
% Parameters:
% disorders: whole dataset
% train_share: percentage that will be assigned to train_set

for i=1:size(dataset, 2)
    list_index = randperm(size(dataset{i}, 1));
    train_len = round(train_share * length(list_index));
    train_set{i} = dataset{i}(list_index(1:train_len), :);
    test_set{i} = dataset{i}(list_index(train_len+1:end), :);
end
    