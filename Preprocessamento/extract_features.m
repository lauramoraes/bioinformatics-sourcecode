function dataset = extract_features(markers, dataset)
%% Function to extract markers features from dataset
% Parameters:
% markers: vector row containing column indexes to be retrieved
% dataset: dataset that will be used to retrieve data

for i=1:length(dataset)
    disorder = dataset{i};
    if ~isempty(disorder)
        dataset{i} = disorder(:, markers);
    end
end