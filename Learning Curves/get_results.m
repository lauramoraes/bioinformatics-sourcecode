function  get_results(accuracy_array, step, dataset_name)
%% Get important results for accuracy array after Learning Curves

max_per_dataset = max(accuracy_array);
[max_total, idx_max] = max(max_per_dataset);
fprintf('Found max accuracy %.4f at %s%d\n', max_total, dataset_name, idx_max*step)

min_per_dataset = min(accuracy_array);
[min_total, idx_min] = min(min_per_dataset);
fprintf('Found min accuracy %.4f at %s%d\n', min_total, dataset_name, idx_min*step)

mean_max_config = mean(accuracy_array(:,idx_max));
fprintf('Found mean accuracy %.4f\n', mean_max_config)

std_max_config = std(accuracy_array(:,idx_max));
fprintf('Found std accuracy %.4f\n', std_max_config)

end

