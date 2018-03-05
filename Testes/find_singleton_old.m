function find_singleton_old(class_list, dataset)
%% Function to classify and plot singleton tree
% Parameters:
% class_list: list containing in which order the classifications should be
% made (how to separate the group of classes). Can be a cell list or double
% list.
% dataset: dataset to classify.

%Load data
fname=fullfile(dataset);
load(fname);

% Initial variables
classification_array = [];
stop = 0;
first_list = [];

if strcmp(class(class_list), 'cell')
    for i=1:size(class_list,1)
        if iscellstr(class_list(i))
            list_partial = strsplit('[',class_list{i});
            list_partial = strsplit(']',list_partial{2});
            list_partial = strsplit(' ',list_partial{1});
            row = [];
            for j=1:length(list_partial)
                row = horzcat(row, str2num(list_partial{j}));
            end
        else
            row = cell2mat(class_list(i));
        end
        zero_matrix = zeros(size(row,1),size(zeros(1,length(dataset)),2)-size(row,2));
        row = [row, zero_matrix];
        first_list = vertcat(first_list, row);
    end
elseif strcmp(class(class_list), 'double')
    first_list = class_list;
end

for i=1:(size(first_list,1))
    % Create first and second list from list with better accuracy
    original_lists = create_second_list(length(train_set),first_list(i,:));
    [original_values,original_class] = get_data_from_list(original_lists, train_set);
    disp('First group:')
    disp(original_lists{1})
    disp('Second group:')
    disp(original_lists{2})
    
    [classification, confusion, classification_plot] = new_classification(separated_list, original_values, original_lists);
    classification_array = [classification_array; classification];
    classes = calculate_classes(classification_array);
    stop = check_singletons(classes, length(disorders));
    if stop
        break;
    end
end

h = figure;
treeplot([classes.parent]);
[x,y] = treelayout([classes.parent]);
x = x';
y = y';
for i=1:size(x,1)
    text(x(i,1), y(i,1), mat2str(classes(i).key), 'VerticalAlignment','bottom','HorizontalAlignment','right');
    text(x(i,1), y(i,1), mat2str(classes(i).accuracy,4), 'VerticalAlignment','top','HorizontalAlignment','left');
end
title({'Singleton Tree'},'FontSize',12,'FontName','Times New Roman');
saveas(h,strcat('singleton_tree'),'fig');
saveas(h,strcat('singleton_tree'),'png');