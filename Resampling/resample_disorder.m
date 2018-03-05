function resample_disorder(original_dataset_path)

original_dataset_path = 'Dataset/seb_cell1_norm.mat';
fname=fullfile(original_dataset_path);
load(fname);
train_set_original = train_set;

disorders = {};
train_set = {};
test_set = {};

for i=1:size(train_set_original,2)
    if isempty(train_set_original{i})
        disorders{i} = [];
        train_set{i} = [];
        test_set{i} = [];
        continue;
    end
    dataset = resample_dataset(train_set_original{i}, 100);
    disorders{i} = dataset;
    new_order = randperm(100);
    train_set{i} = dataset(new_order(1:50),:);
    test_set{i} = dataset(new_order(51:100),:);
end

save('Datasets/Dataset/resampled_seb_cell1_norm.mat', 'disorders', 'train_set', 'test_set', 'marc_label');