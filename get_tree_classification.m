function classification_array = get_tree_classification(test_set, model, marc, original_dataset_path)
%% Get a test set and an already trained tree and classify the test set
% Parameters:
% test_set: set to be tested, divided by original classes
% model: model tree to be "walked" through
% marc: markers to be used in each tree in the model

% DOWN_LIMIT = 0.1;
% UP_LIMIT = 0.9;

% Original dataset
%original_dataset_path = 'Dataset/seb_cell1.mat';
% original_dataset_path = 'Dataset/seb_cell1_norm.mat';
% original_dataset_path = 'Dataset/resampled_seb_cell1_norm.mat';
% original_dataset_path = 'Dataset/iris_train_set.mat';
% original_dataset_path = 'Dataset/seb_cell_2015_05_20_norm_5_classes.mat';
%original_dataset_path = 'Dataset/seb_cell_2015_07_23_norm_lpl+mzl.mat';
%original_dataset_path = 'Dataset/digits.mat';
%original_dataset_path = 'Dataset/digits_divided.mat';
%original_dataset_path = 'Dataset/usps.mat';
%original_dataset_path = 'Dataset/usps_divided.mat';
%original_dataset_path = 'Dataset/mnist_divided.mat';
%original_dataset_path = 'Dataset/pendigits_divided.mat';
%original_dataset_path = 'Dataset/glass_norm.mat';
%original_dataset_path = 'Dataset/heart_norm.mat';
%original_dataset_path = 'Dataset/cooking.mat';
%original_dataset_path = 'Dataset/cooking_divided.mat';


%Load data
fname=fullfile(original_dataset_path);
ts = load(fname, 'test_set');
train_set = ts.test_set;

model = add_child_property(model);
classification_array = [];

for i=1:size(test_set,2)
    for element=1:size(test_set{i},1)
        % For each tree in model
        tree_index=1;
        classified = false;
        classification = '';
        %while (tree_index <= size(model, 2)) && (~classified) && (~isempty(model{tree_index}))
        while (tree_index <= size(model, 1)) && (~classified) && (~isempty(model{tree_index})) && (length(model{tree_index}) > 1)
            tree = model{tree_index};
            % For each node in tree
            node = 1;
            while node ~= -1
                classification_temp = tree(node).key;
                if size(tree(node).key) == 1
                    if strcmp(classification, '')
                        classification = num2str(tree(node).key);
                    else
                        classification = strcat(classification, '-', num2str(tree(node).key));
                    end
                end
                if isempty(tree(node).childs)
                    classified = true;
                    break;
                end
                    
                %norm_element = (test_set{i}(element,marc{tree_index}) - tree(node).mu)./tree(node).sigma;
                %norm_element = 10*(test_set{i}(element,marc{tree_index}) - tree(node).sigma(1,:))./(tree(node).mu(1,:)-tree(node).sigma(1,:));
                norm_element = test_set{i}(element,marc{tree_index});
            
                if (size(tree(node).key) == 1)
                    parent_node = node;
                    classification_prefix = classification;
                    classification = '';

                    for child=1:length(tree(node).childs)
                        
                        % Get node
                        node = tree(parent_node).childs(child);
                        [y_out, y_hat] = classify_data([1 norm_element], tree(node).model);
                        % Go to the left children
                        if (y_hat < tree(node).lower_limit && tree(node).under_cut==1) || (y_hat > tree(node).upper_limit && tree(node).under_cut==2)
%                             node = tree(node).lchild;
                            if strcmp(classification, '')
                                classification = strcat(classification_prefix, '-', num2str(tree(node).listA));
                            else
                                classification = strcat(classification, '/', classification_prefix, '-', num2str(tree(node).listA));
                            end
                        elseif (y_hat > tree(node).lower_limit && y_hat < tree(node).upper_limit)
                            if strcmp(classification, '')
                                classification = strcat(classification_prefix, '-', num2str(strrep(tree(node).key',' ', '')));
                            else
                                classification = strcat(classification, '/', classification_prefix, '-', num2str(strrep(tree(node).key',' ','')));
                            end
                        % Go to the right children
                        else 
                            if strcmp(classification, '')
                                classification = strcat(classification_prefix, '-', num2str(tree(node).listB));
                            else
                                classification = strcat(classification, '/', classification_prefix, '-', num2str(tree(node).listB));
                            end
                        end
                    end
                    classified = true;
                    break
                else
                    [y_out, y_hat] = classify_data([1 norm_element], tree(node).model);
                    
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     %Load data
%                     fname=fullfile(tree(node).dataset_path);
% %                     fname=fullfile(original_dataset_path);
%                     load(fname, 'train_set');
%                     markers = marc{tree_index};
%                     train_set = extract_features(markers, train_set);
%                     separated_list = {};
%                     separated_list{1} = tree(node).listA;
%                     separated_list{2} = tree(node).listB;
% 
%                     [X, original_class] = get_data_from_list(separated_list,train_set, false);
%                     [X,Y, mu, sigma] = load_data(X, false, false, false);
%                     
%                     Y(find(Y==-1)) = 0;
%                     
%                     balanced_weights = [];
%                     obs_total = find(Y == 0);
%                     balanced_weights(obs_total) = 1/length(obs_total);
%                     obs_total = find(Y == 1);
%                     balanced_weights(obs_total) = 1/length(obs_total);
%                     
%                     [w, FitInfo] = lassoglm(X, Y, 'binomial', 'Standardize', false, 'NumLambda', 50, 'Weights', balanced_weights);
%                     E_in_hist = FitInfo.Deviance;
%                     [err, index] = min(E_in_hist)
%                     weight = vertcat(FitInfo.Intercept(index), w(:, index));
%                     assignin('base', 'weight_outsample', weight)
%                     disp('Pesos calculados pela regularização:')
%                     disp(weight)
%                     
%                     %                     Y_out = mnrval(weight,X)
%                     [y_out_log, y_hat_log] = classify_data([ones(size(X,1),1) X] ,weight);
%                     [~, y_hat2] = classify_data([1 norm_element], weight);
%                     
% %                     y_out_log(find(y_out_log==-1)) = 0;
% %                     h1 = figure;
% %                     scatter(X(:,1),y_hat_log(:,1), 80, Y, 'LineWidth',2);
% %                     hold on
% %                     line([min(X(:)) max(X(:))], [0.5 0.5])
% %                     line([min(X(:)) max(X(:))], [tree(node).upper_limit tree(node).upper_limit], 'LineStyle', '--', 'Color', 'red')
% %                     line([min(X(:)) max(X(:))], [tree(node).lower_limit tree(node).lower_limit], 'LineStyle', '--', 'Color', 'red')
% %                     scatter(5,y_hat, 80, 'red', 'fill', 'LineWidth',2);
% %                     scatter(5,y_hat2, 80, 'green', 'LineWidth',2);
% %                     hold off
%                     
%                     fprintf('List A: %s, List B: %s\n', mat2str(separated_list{1}), mat2str(separated_list{2}));
%                     fprintf('No: %d, Classe: %d, Logist: %f, Logist2: %f\n\n', node, y_out, y_hat, y_hat2);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                    % Go to the left children
                    if (y_hat < tree(node).lower_limit && tree(node).under_cut==1) || (y_hat > tree(node).upper_limit && tree(node).under_cut==2)
                        node = tree(node).lchild;
                    elseif (y_hat > tree(node).lower_limit && y_hat < tree(node).upper_limit)
                        classification = num2str(tree(node).key');
                        %disp(1)
                        %pause
                        classified = true;
                        break;
                    % Go to the right children 
                    else 
                        node = tree(node).rchild;
                    end
                end
            end
            tree_index = tree_index + 1;
        end
        
%         if ~classified
        if strcmp(classification, '')
            N = size(classification_temp, 1);
            m_array = 10.^[N-1:-1:0];
            classification = sum(classification_temp.*m_array');
            classification = num2str(classification);
            %disp(2)
            %pause
        end
        fprintf('Element %d from original class %d classified as %s\n', element, i, classification);
        [p, original_index] = ismember(test_set{i}(element,:), train_set{i}, 'rows');
        
        classification_array = [classification_array; {element i classification original_index test_set{i}(element,:)}];
    end
end

% Print classification matrix
fid = fopen('classification_removed.csv','w');
%colheadings = {'Row', 'Target','Output', 'Original Index'};
classification_array
%displaytable(classification_array, [], [], 's');
%displaytable(classification_array, [], [], 's', [], fid, ';', ';');
fclose(fid);
