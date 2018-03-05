function cascade_classification(mode)
dataset_path = 'Dataset/seb_cell.mat';
first_list_path = 'Dataset/first_list.mat';
save_folder = 'Resultados';

if ~exist('mode','var')
    mode = 'logistic_regression';
end

if ~exist(save_folder, 'dir')
  mkdir(save_folder);
end

%Load data
fname=fullfile(dataset_path);
load(fname);
% Load first list
fname=fullfile(first_list_path);
load(fname);

% Get possible combination of attributes
total_attr =  attribute_combination(size(train_set{1},2));
index_list = 4;
%for index_list=1:size(first_list,1)
%for index_list=1:1
    % Divide while precision = 100% for at least one of the classes.
    % Get modified train set back and corresponding original class
    all_classification = [];
    
    % Create first and second list from list with better accuracy
    separated_list = create_second_list(length(train_set),first_list(index_list,:));
    [original_values,original_class] = get_data_from_list(separated_list, train_set);
    disp('First group:')
    disp(separated_list{1})
    disp('Second group:')
    disp(separated_list{2})
    %for i=1:size(total_attr,1)
    %for i=1:7

        for j=1:size(original_values,2)
            %train_group{j} = original_values{j}(:, total_attr(i,total_attr(i,:)~=0));
            train_group{j} = original_values{j};
            %attr_label = {marc_label{total_attr(i,total_attr(i,:)~=0)}};
        end
        disp('Using attribute(s):')
        attr_label = marc_label;
        disp(attr_label)

        subfolder_name = strcat(save_folder, '/', strjoin(attr_label, '_'));
        if ~exist(subfolder_name, 'dir')
          mkdir(subfolder_name);
        end

        classification = second_round(train_group, mode, attr_label, subfolder_name);
        all_classification = vertcat(all_classification, classification);
    %end
    [all_classification, class_index] = sort_classification(all_classification);
    disp('Best classification:')
    disp(all_classification(1))
    disp('Using attributes:')
    %attr_label = {marc_label{total_attr(class_index(1),total_attr(class_index(1),:)~=0)}};
    disp(attr_label)
%end
end