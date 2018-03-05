train_final = zeros(size(trainh,1), size(trainh,2));
for i = 1:size(trainh,1)
    for j = 1:size(trainh,2)
        train_final(i,j) = trainh{i,j};
    end
end
