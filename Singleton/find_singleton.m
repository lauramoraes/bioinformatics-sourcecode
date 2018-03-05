function [remaining, conf_remaining, removed, classes, found_singleton] = find_singleton(dataset_path, first_list_path, borders_path, save_folder, temp_result, stop, marc, total, verbose, min_w)
%% Function to classify and plot singleton tree
% Parameters:
% dataset_path: dataset path string
% first_list_path: folder containing first list mat
% save_folder: folder to save the results
% temp_results: save node results
% stop: min % of elements in class to be keep dividing node
% marc: markers to extract
% min_w: min weight % representation to be considered in the classifier


% Default value
if ~exist('stop','var')
    stop = 0;
end
if ~exist('min_w','var')
    min_w = false;
end
if ~exist('total','var')|| isempty(total)
    total = [16 27 34 48 38 37 31 40 20 6];
end
if ~exist('verbose','var')
    verbose = true;
end

tic;

% Many warnings of matrix close to singular.
% Turning it off for the moment.
w = warning('on','all');

%Load data
fname=fullfile(dataset_path);
load(fname);

available_classes = [];
for i=1:size(train_set,2)
    available_classes = vertcat(available_classes, ones(size(train_set{i},1),1)*i);
end
%%%%%%%%%%%%%%%%%
%% ALG2-CREATE %%
%%%%%%%%%%%%%%%%%
[tree_index, classes, remaining, removed, conf_remaining, found_singleton] = create_classification_tree(dataset_path, first_list_path, borders_path, temp_result, available_classes, total, stop, marc, min_w, verbose);


save(strcat(save_folder, '/remaining.mat'), 'remaining', 'marc_label');
save(strcat(save_folder, '/removed.mat'), 'removed', 'marc_label');
save(strcat(save_folder, '/classes.mat'), 'classes');
marc_label = marc_label(marc);

if isempty(classes) || length(classes) == 1
    return
end

%%%%%%%%%%%%%%%
%% ALG2-PLOT %%
%%%%%%%%%%%%%%%
if ~verbose
    h = figure('Visible', 'off');
else
    h = figure;
end
treeplot([classes.parent]);
dcm_obj = datacursormode(h);
[x,y] = treelayout([classes.parent]);
set(dcm_obj,'UpdateFcn',{@update_tooltip, x, y, classes, marc_label})
x = x';
y = y';
colors=hsv(10);

data = [];
data_single_elements = [];
level = zeros(1, size(x,1));
level_begin = '';
%marc_label = ['Bias' marc_label];
weight_size = size(marc_label, 2);

% Print data table with node info
fid_ident = fopen(strcat(save_folder, '/nodes_ident.csv'),'w');
fid = fopen(strcat(save_folder, '/nodes.csv'),'w');
fprintf(fid_ident, 'Node;');
fprintf(fid, 'Node;');
for i=1:weight_size
    fprintf(fid_ident, '%s;', marc_label{i});
    fprintf(fid, '%s;', marc_label{i});
end
fprintf(fid_ident, 'Classes/Elements\n');
fprintf(fid, 'Classes/Elements\n');

% Create weight print format
col_fmt = repmat('%.2f;', 1, weight_size);
class_node = zeros(size(train_set,2), size(x,1));
for i=1:size(x,1)
    
    % Add it to general class-node matrix
    for j=1:size(classes(i).key, 1)
        class_node(classes(i).key(j), i) = class_node(classes(i).key(j), i) + classes(i).elements(j);
    end
    
    fmt = sprintf('(%d)', i);
    text(x(i,1), y(i,1), fmt, 'VerticalAlignment','bottom','HorizontalAlignment','right');
    
    % Calculate printing level
    if i > 1
        level(i) = level(classes(i).parent) + 1;
        level_begin = repmat(';', 1, level(i));
    end
    
    % Get resulting list and format of classes for each side
    llist = unique(classes(i).llist)';
    llist_fmt = repmat('%d;', 1, size(llist, 2));
    rlist = unique(classes(i).rlist)';
    rlist_fmt = repmat('%d;', 1, size(rlist, 2));
    listA = unique(classes(i).listA);
    listA_fmt = repmat('%d;', 1, size(listA, 2));
    listB = unique(classes(i).listB);
    listB_fmt = repmat('%d;', 1, size(listB, 2));
    % Print to file (with and without identation)
    if isempty(classes(i).llist) && ~isempty(classes(i).weight)
        % Print regular node
        fprintf(fid_ident, strcat('%s%d;', col_fmt, ';', listA_fmt, 'x;', listB_fmt, '\n'), level_begin, i, classes(i).model', listA, listB);
        fprintf(fid, strcat('%d;', col_fmt, ';', listA_fmt, 'x;', listB_fmt, '\n'), i, classes(i).weight', listA, listB);
        next_line = repmat(';', 1, weight_size+2);
    elseif ~isempty(classes(i).weight)
        % Print regular node
        fprintf(fid_ident, strcat('%s%d;', col_fmt, ';', llist_fmt, 'x;', rlist_fmt, '\n'), level_begin, i, classes(i).model', llist, rlist);
        fprintf(fid, strcat('%d;', col_fmt, ';', llist_fmt, 'x;', rlist_fmt, '\n'), i, classes(i).weight', llist, rlist);
        next_line = repmat(';', 1, weight_size+2);
        if length(llist) > 1
            llist_elements = hist(classes(i).llist, llist);
        else
            llist_elements = hist(classes(i).llist, 1);
        end
        if length(rlist) > 1
            rlist_elements = hist(classes(i).rlist, rlist);
        else 
            rlist_elements = hist(classes(i).rlist, 1);
        end
        fprintf(fid_ident, strcat(level_begin, next_line, llist_fmt,'x;', rlist_fmt, '\n'),llist_elements, rlist_elements);
        fprintf(fid, strcat(next_line, llist_fmt,'x;', rlist_fmt, '\n'), llist_elements, rlist_elements);
    else
        % Print singletons
        fprintf(fid_ident, '%s%d;%d\n%s;%d\n', level_begin, i, classes(i).key, level_begin, classes(i).elements);
        fprintf(fid, '%d;%d\n;%d\n', i, classes(i).key, classes(i).elements);
    end
    
    % Print accuracy in plot if not 100
    if classes(i).accuracy ~= 100
        %text(x(i,1), y(i,1), mat2str(classes(i).accuracy,4), 'VerticalAlignment','top','HorizontalAlignment','left');
        %text(x(i,1), y(i,1), mat2str(classes(i).key), 'VerticalAlignment','bottom','HorizontalAlignment','left');
        fmt = sprintf('%s x %s', mat2str(classes(i).listA), mat2str(classes(i).listB));
        text(x(i,1), y(i,1), fmt, 'VerticalAlignment','top','HorizontalAlignment','left');
    end
    % Print lists in plot
    if ~isempty(classes(i).llist)
        %text(x(i,1), y(i,1), mat2str(classes(i).key),
        %'VerticalAlignment','bottom','HorizontalAlignment','left');
        fmt = sprintf('%s x %s', mat2str(llist), mat2str(rlist));
        text(x(i,1), y(i,1), fmt, 'VerticalAlignment','bottom','HorizontalAlignment','left');
        fmt = sprintf('%s x %s', mat2str(llist_elements), mat2str(rlist_elements));
        text(x(i,1), y(i,1), fmt, 'VerticalAlignment','top','HorizontalAlignment','left');
    end
    % Print quantity of elements (for singletons)
    if size(classes(i).elements, 2) == 1
        text_color = (~round(colors(classes(i).key,1)) & ~round(colors(classes(i).key,2))) + zeros(1,3);
        text(x(i,1), y(i,1), mat2str(classes(i).key), 'VerticalAlignment','bottom','HorizontalAlignment','left', 'BackgroundColor', colors(classes(i).key,:), 'Color', text_color);
        %leaf = strcat(int2str(classes(i).elements), '/', int2str(size(train_set{classes(i).key},1)));
        leaf = strcat(int2str(classes(i).elements), '/', int2str(total(classes(i).key)));
        text(x(i,1), y(i,1), leaf, 'VerticalAlignment','top','HorizontalAlignment','right', 'BackgroundColor', colors(classes(i).key,:), 'Color', text_color);
       % summary = 
    end
    % Get singleton classes with just one element
    if ~isempty(classes(i).single_elements)
        data_single_elements = [data_single_elements; num2cell([i classes(i).key classes(i).single_elements])];
    end
end
fclose(fid_ident);
fclose(fid);

% Print class-node matrix
fid = fopen(strcat(save_folder, '/class-node.csv'),'w');
rowheadings_array = 1:size(class_node,2);
colheadings_array = 1:size(class_node,1);
rowheadings = cellstr(num2str(rowheadings_array(:)))';
colheadings = cellstr(num2str(colheadings_array(:)))';
fms = cell(1, size(class_node, 1));
[fms{:}] = deal('d');
if verbose
    displaytable(class_node',colheadings,[], fms, rowheadings);
end
displaytable(class_node',colheadings,[], fms, rowheadings, fid, ';', ';');
fclose(fid);

% Print singleton table with single classes elements info
if ~isempty(data_single_elements)
    fid = fopen(strcat(save_folder, '/singles.csv'),'w');
    colheadings = ['Node' 'Class' marc_label];
    col_fms = cell(1, size(marc_label, 2));
    [col_fms{:}] = deal('.2f');
    fms = ['d' 'd' col_fms];
    size(data_single_elements)
if verbose
    displaytable(data_single_elements,colheadings,[], fms);
end
    displaytable(data_single_elements,colheadings,[], fms, {}, fid, ';', ';');
    fclose(fid);
end

title({'Singleton Tree', strjoin(marc_label, ', ')});
saveas(h,strcat(save_folder, '/singleton_tree'),'fig');
saveas(h,strcat(save_folder, '/singleton_tree'),'png');
t = toc;
if verbose
    disp('Elapsed Time: ')
    disp(t);
else
    close all;
end
