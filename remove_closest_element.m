function [rem_class, rem_index] = remove_closest_element(dataset_path, classes)
%% Function to remove closest element to the regression hyperplane border
% Parameters:
% dataset_path: path to dataset
% classes: model struct
% marc: markers used in model

%Load data
fname=fullfile(dataset_path);
load(fname);

separated_list{1} = classes.listA;
separated_list{2} = classes.listB;
[X_init, original_class, original_index] = get_data_from_list(separated_list,train_set);
[X, Y] = load_data(X_init, false, true, true);
[Y_out, Y_hat] = classify_data(X, classes.model);

cut = 0.5; %value to find
cut_diff = abs((Y_hat-cut).*((Y_out-Y)/2));
cut_diff(cut_diff==0) = Inf;
[p, idx] = min(cut_diff); %index of closest value
total_original_index = vertcat(original_index{1}, original_index{2});
rem_class = total_original_index(idx, 1);
rem_index = total_original_index(idx, 2);
