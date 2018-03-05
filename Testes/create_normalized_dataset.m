%load 'Datasets/Dataset/seb_cell_2015_07_01.mat'
load 'Datasets/Dataset/cal_housing.mat'
X_temp = [];
for i=1:6
    X_temp = vertcat(X_temp, train_set{i});
end

max_val = max(X_temp);
max_vals = repmat(max_val,size(X_temp,1),1);
min_val = min(X_temp);
min_vals = repmat(min_val,size(X_temp,1),1);
X_total = 10*(X_temp - min_vals)./(max_vals-min_vals);

index=1;
train_set_final = cell(1, 10);
for i=1:6
    index_final = size(train_set{i},1)+index-1;
    fprintf('%d:%d:%d\n', index, size(train_set{i},1), index_final)
    train_set_final{i} = X_total(index:index_final,:);
    index = index_final+1;
end

train_set = train_set_final;
save('Datasets/Dataset/cal_housing_norm.mat', 'train_set', 'marc_label')
