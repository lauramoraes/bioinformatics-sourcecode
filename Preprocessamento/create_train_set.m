function train_set = create_train_set(train)
% Receive train set as a matrix with target in last column and transform it
% to expected tree format

train_set = {}

fprintf('Dataset has %i rows and %i columns\n', size(train, 1), size(train,2)); 

target = train(:, size(train,2));
unique_target = unique(target);
fprintf('There are %i unique targets\n', size(unique_target,1));
for i=1:size(unique_target,1)
    idx = find(train(:,size(train, 2)) == unique_target(i));
    fprintf('There are %i elements with target %i\n', size(idx,1), unique_target(i))
    train_set{i} = train(idx,1:size(train,2)-1);
end

end
