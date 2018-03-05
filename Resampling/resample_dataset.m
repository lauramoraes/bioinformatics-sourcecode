function dataset = resample_dataset(original_dataset, nelements)
%% Resample dataset using linear combination of 2 observations
% Parameters:
% original_dataset: dataset to resample where each row is an observation
% nelements: number of elements that the final dataset should have

total = size(original_dataset, 1);
nmissing = nelements - total;

% Sample 2 times the number of missing elements, so we can use 2
% observations to create a new one
sample_dataset = datasample(original_dataset, nmissing*2);
total_sample = size(sample_dataset, 1);
dataset = original_dataset;

for i=1:(total_sample/2)
    k = rand;
    new_obs = k.*sample_dataset(i,:) + (1-k).*sample_dataset(total_sample-i+1,:);
    dataset = vertcat(dataset, new_obs);
end