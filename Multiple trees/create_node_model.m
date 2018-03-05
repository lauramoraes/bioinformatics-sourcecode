function [train_set_ldata, train_set_rdata, node, found_singleton] = create_node_model(dataset_path, parent, available_classes, first_list, total)

% Print confusion matrix and partition?
verbose = false;

%Load data
fname=fullfile(dataset_path);
load(fname);

% Create node model
node = struct('parent', parent, 'key', unique(available_classes), 'lchild', -1, 'rchild',-1, 'confusion_matrix', [], 'accuracy', 100, 'llist',[], 'rlist',[],'listA', [], 'listB',[], 'elements',0, 'weight', [], 'model', [], 'under_cut', 0, 'mu', [], 'sigma', []);
% Available elements per class
node.elements = hist(available_classes, unique(available_classes));
node.elements = node.elements(node.elements~=0);
found_singleton = false;

%%%%%%%%%%%%%%%%%%%%
%% ALG3-SINGLETON %%
%%%%%%%%%%%%%%%%%%%%
% Find singleton
if length(node.key) == 1
    node.elements = hist(available_classes, length(node.key));
    found_singleton = true;
    train_set_ldata = [];
    train_set_rdata = [];
    return
end

% Create second list after choosing the best combination
separated_list = create_second_list(length(train_set),first_list); 
        
node.listA = intersect(available_classes, separated_list{1});
node.listB = intersect(available_classes, separated_list{2});
if verbose
    disp('First list:')
    disp(node.listA)
    disp('Second list:')
    disp(node.listB)
end
% Separate data
[X_init, original_class, original_index] = get_data_from_list(separated_list,train_set);

%%%%%%%%%%%%%%%%%%
%% ALG3-CLASSIF %%
%%%%%%%%%%%%%%%%%%
% Train, test and get results
% [classification, X, Y, mu, sigma] = generate_classification(first_list, train_set,'linear_regression_modified', false, 0);
[classification, X, Y, mu, sigma] = generate_classification(first_list, train_set, 'lasso_regression', false, 0);
% [classification, X, Y, mu, sigma] = generate_classification(best_class, train_set, 'logistic_regression', false, min_w, save_folder);
if verbose
    classification.confusion_matrix
end
node.mu = mu;
node.sigma = sigma;

%%%%%%%%%%%%%%%%%%%%
%% ALG3-PRECISION %%
%%%%%%%%%%%%%%%%%%%%
index = 1;
classified_any = all(any(classification.confusion_matrix, 1));
if classified_any
    ldata = cell(size(total,2),1);
    original_ldata = [];
    rdata = cell(size(total,2),1);
    original_rdata = [];
    train_set_ldata = cell(size(total,2),1);
    train_set_rdata = cell(size(total,2),1);
    node.under_cut = index;
    
    %%%%%%%%%%%%%%%%%%
    %% ALG3-NOTPURE %%
    %%%%%%%%%%%%%%%%%%
    % Separate the ones that are correct and incorrect into ldata and rdata
    for index=1:2
        % Just classify the data from one class
        Y_out = classify_data(X{index}, classification.w);
        ldata_index = find(Y_out == -1);
                
        for i=1:size(ldata_index,1)
            ldata{original_class{index}(ldata_index(i))} = vertcat(ldata{original_class{index}(ldata_index(i))}, X_init{index}(ldata_index(i),:));
            original_ldata = vertcat(original_ldata, original_class{index}(ldata_index(i)));
            ts_class = original_index{index}(ldata_index(i), 1);
            ts_index = original_index{index}(ldata_index(i), 2);
            train_set_ldata{ts_class} = vertcat(train_set_ldata{ts_class}, train_set{ts_class}(ts_index,:));
        end
        
        rdata_index = find(Y_out == 1);
        
        for i=1:size(rdata_index,1)
            rdata{original_class{index}(rdata_index(i))} = vertcat(rdata{original_class{index}(rdata_index(i))}, X_init{index}(rdata_index(i),:));
            original_rdata = vertcat(original_rdata, original_class{index}(rdata_index(i)));
            ts_class = original_index{index}(rdata_index(i), 1);
            ts_index = original_index{index}(rdata_index(i), 2);
            train_set_rdata{ts_class} = vertcat(train_set_rdata{ts_class}, train_set{ts_class}(ts_index,:));
        end
    end
%         ldata
%         rdata
%         pause
    
    % Pretty print for unknown class
    if isempty(node.key)
        node.key = '??';
    end
    
    % Available classes in each children
    node.llist = original_ldata;
    node.rlist = original_rdata;
else
    %%%%%%%%%%%%%%%%%%%%%%
    %% ALG3-NOPRECISION %%
    %%%%%%%%%%%%%%%%%%%%%%
    % Stop! Didn't find 100% precision. Just show accuracy.
    node.accuracy = classification.accuracy;
    train_set_ldata = [];
    train_set_rdata = [];
end

% Confusion matrix for node
node.confusion_matrix = classification.confusion_matrix; 
% Normalized weight vector for node
node.weight = classification.w_norm;
node.model = classification.w;
end