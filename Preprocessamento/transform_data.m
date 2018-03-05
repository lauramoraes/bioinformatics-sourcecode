function [disorders, train_set, test_set] = transform_data(original_dataset, train_share)
%% Function to transform Seb dataset into the format expected for the
%% algorithm
% Parameters: 
% Orginal dataset: Struct where each field corresponds to a disorder
% train_rate: percentage from whole set that will be used for training.

fields = fieldnames(original_dataset);

disorders = {};
train_set = {};
test_set = {};

for i=1:numel(fields)
    disorders{i} = original_dataset.(fields{i});
    % Add Kappa Lambda column
    kappa_lambda = generate_kappa_lambda(fields{i}, size(disorders{i},1));
    disorders{i} = horzcat(disorders{i}, kappa_lambda);
    %list_index = randperm(size(disorders{i}, 1));
    %train_len = round(train_share * length(list_index));
    train_set{i} = disorders{i};
    % Temporarilly commented (not dividing in train and test set)
    %train_set{i} = disorders{i}(list_index(1:train_len), :);
    %test_set{i} = disorders{i}(list_index(train_len+1:end), :);
end
