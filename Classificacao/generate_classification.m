function [classification, X, X_unbalanced, Y, mu, sigma] = generate_classification(first_list, train_set, mode, balance, min_w, leaf, save_folder)
%% Function to generate a classification struct, to be analyzed later
% Parameters:
% first_list: list containing the classes belonging to class 1
% train_set: set that will be used for training
% mode: classifier mode
% balance: flag to balance classes. Default: false
% min_w: deprecated (to be removed)

if ~exist('mode', 'var')
    mode = 'logistic_regression';
end

% Set balance flag
if ~exist('balance', 'var')
    balance = false;
end

if ~exist('min_w', 'var')
    min_w = false;
end

if ~exist('save_folder', 'var')
    save_folder = false;
end

if ~exist('leaf', 'var')
    leaf = false;
end

% Create first and second list
separated_list = create_second_list(length(train_set),first_list);
second_list = separated_list{2};
for i=1:length(train_set)
    if isempty(train_set{i})
        index = find(second_list == i);
        second_list(index) = [];
    end
    if isempty(second_list)
        classification.max_accuracy = 0;
        X = 0;
        Y = 0;
        mu = 0;
        sigma = 0;
        return;
    end
end
separated_list{2} = second_list;
        
[X, X_unbalanced, original_class] = get_data_from_list(separated_list,train_set, balance);

%disp('Classifier:')
switch mode
    case 'linear_regression'
        %disp('Linear Regression')
        [X,Y] = load_data(X);
        
        % Train linear model
        w = linear_regression(X,Y);
        
        if (balance)
            % Load classes again (without balance)
            [X, original_class]=get_data_from_list(separated_list,train_set);
            [X,Y] = load_data(X);
        end
        Y_total = Y;
        
        % Get results (train)
        [Y_out, Y_hat] = classify_data(X, w);
        
    case 'linear_svm'
        disp('Linear SVM')
        % Load w/o bias
        [X,Y] = load_data(X, false, false);
        Y_total = Y;
        % Train SVM linear model
        svm_struct = svm(X,Y,'linear');
        w = vertcat(svm_struct.Bias, svm_struct.Alpha);
        support_vectors = X(svm_struct.SupportVectorIndices, :);
        
        % Get results (train)
        [Y_out, Y_hat] = classify_data(X, svm_struct, 'svm');
    case 'quadratic_svm'
        disp('Quadratic SVM')
        % Load w/o bias
        [X,Y] = load_data(X, false, false);
        Y_total = Y;
        % Train SVM quadratic model
        svm_struct = svm(X,Y,'quadratic');
        w = vertcat(svm_struct.Bias, svm_struct.Alpha);
        support_vectors = X(svm_struct.SupportVectorIndices, :);
        
        % Get results (train)
        [Y_out, Y_hat] = classify_data(X, svm_struct, 'svm');
    case 'linear_discriminant'
        disp('Linear Discriminant Analysis')
        % Load w/o bias
        [X,Y] = load_data(X, false, false);
        Y_total = Y;
        % Train quadratic model and get results (built-in function)
        [Y_out,err,POSTERIOR,logp,coeff] = classify(X, X, Y,'linear');
        w = vertcat(coeff(2,1).const, coeff(2,1).linear);
    case 'quadratic_discriminant'
        disp('Quadratic Discriminant Analysis')
        % Load w/o bias
        [X,Y] = load_data(X, false, false);
        Y_total = Y;
        % Train quadratic model and get results (built-in function)
        [Y_out,err,POSTERIOR,logp,coeff] = classify(X, X, Y,'quadratic');
        w = vertcat(coeff(2,1).const, coeff(2,1).linear);
    case 'linear_regression_modified'
        %disp('Linear Regression Modified')
        % Load in separated variables
        [X,Y, mu, sigma] = load_data(X, true, true, true);
        % Train linear model
        w = linear_regression_modified(X,Y);
        
        % Join datasets
        X_total = vertcat(X{1}, X{2});
        Y_total = vertcat(Y{1}, Y{2});
        
        % Get results (train)
        [Y_out, Y_hat] = classify_data(X_total, w);
    case 'logistic_regression'
        %disp('Logistic Regression')
        % Load in separated variables (apply bias and zscore on original
        % values) - values used for training
        [X,Y, mu, sigma] = load_data(X, true, true, true);
        
        % Train linear model
        w_init = linear_regression_modified(X,Y);
     
        % Join datasets
        X_total = vertcat(X{1}, X{2});
        Y_total = vertcat(Y{1}, Y{2});
        
        % Train linear model
        [w, error_hist, iteraction_w, iteraction_final] = logistic_regression(X_total,Y_total, w_init);
        
        % If min weight 
        if (min_w)
            sil_stat = [];
            for attr = 2:size(X_total,2)
                if (save_folder)
                    h = figure('Visible', 'off');
                    [sil, h] = silhouette(X_total(:,attr), Y_total, 'std_distance', Y_total);
                else
                    sil = silhouette(X_total(:,attr), Y_total, 'std_distance', Y_total);
                end
                elements_c1 = size(X{1},1);
                elements_c2 = size(X{2},1);
                sil_stat_c1 = 0.5*sum(sil(1:elements_c1)>0)/elements_c1;
                sil_stat_c2 = 0.5*sum(sil(elements_c1+1:end)>0)/elements_c2;
                sil_stat(attr) = sil_stat_c1 + sil_stat_c2;
                if (save_folder)
                    title_str = sprintf('%s x %s - Attribute %d', mat2str(separated_list{1}), mat2str(separated_list{2}), attr);
                    title(title_str);
                    saveas(h,strcat(save_folder, '/', title_str),'fig');
                    saveas(h,strcat(save_folder, '/', title_str),'png');
                end
                close all hidden;
            end
            % Get bias
            bias = w(1);
            % Remove from weight list
%            w_temp = w(2:end);
%            % Calculate important attributes
%            total = sum(abs(w));
%            min_w = min_w * total;
            index_w = find(sil_stat >= min_w);
            w(find(sil_stat < min_w)) = 0;
            w_init = [bias; w(index_w)];
            % Add 1 to index_w to consider bias. Get bias
            X_total_temp = X_total(:, [1 index_w]);
%            % Train NEW linear model
            [w_final, error_hist, iteraction_w, iteraction_final] = logistic_regression(X_total_temp,Y_total, w_init);
            w([1 index_w]) = w_final;
        end 
        
        % Get results (train)
        [Y_out, Y_hat] = classify_data(X_total, w);
    otherwise
        %disp('Lasso Regularization')
        
        % Load in one variable and do not apply bias
        [X_total,Y, mu, sigma] = load_data(X, false, false, false);
        
        % Train linear model
        if leaf
            %[w, error_hist, lambda] = lasso_regression(X_total,Y, leaf);
            [w, error_hist, lambda] = lasso_regression_tibishirani(X_total,Y, leaf);
        else
            %[w, error_hist, lambda] = lasso_regression(X_total,Y);
            [w, error_hist, lambda] = lasso_regression_tibishirani(X_total,Y);
        end
        
        % Get results (train)
        X_total = [ones(size(X_total,1),1) X_total];
        [Y_out, Y_hat] = classify_data(X_total, w);
        separability = calculate_separability(Y_hat, Y);
        Y_total = Y;
        
        % Reload X in separated variables
        if (balance)
            % Load classes again (without balance)
            [X, X_unbalanced, original_class]=get_data_from_list(separated_list,train_set);
            [X,Y, mu, sigma] = load_data(X, true, true, false);
        else
            [X,Y, mu, sigma] = load_data(X, true, true, false);
        end
end

%            Output
%Tar   list1 as 1    list1 as 2
%get   list2 as 1    list2 as 2
%
confusion_matrix = confusionmat(Y_total, Y_out);
%confusion = plot_confusion(Y, Y_out, 'Train');
%saveas(confusion, strcat(result_path,'/', 'train_confusion_plot'), 'fig');
% If disorder not used, consider accuracy 0 (list not suitable for classification)
if size(confusion_matrix, 1) ~= 2
   classification.max_accuracy = 0; 
   return
end
total_percent = (confusion_matrix(1,1)+confusion_matrix(2,2))/sum(confusion_matrix(:))*100;
% Precision: from all that I classified as a certain class, how many
% are really from that class?
% Recall: from all that are from a certain class, how many did I
% classify as being from that class?
for i=1:2
    recall(i) = confusion_matrix(i,i)/sum(confusion_matrix(i,:))*100;
    precision(i) = confusion_matrix(i,i)/sum(confusion_matrix(:,i))*100;
end

% Save results
% Get max from recall and precision
classification.max_accuracy = max(max(precision, recall));
classification.accuracy = total_percent;
classification.precision = precision;
classification.recall = recall;
classification.confusion_matrix = confusion_matrix;
classification.first_list = separated_list{1};
classification.second_list = separated_list{2};
% Save weight vector but without bias. Normalize the weight to sum 100.
classification.w_norm = 100.*abs(w(2:end))./sum(abs(w(2:end)));
classification.w = w;
% Save logistic separability result
if exist('separability', 'var')
    classification.separability = separability;
end
% Save logistic raw result
if exist('Y_hat', 'var')
    classification.y_hat = Y_hat;
end
% Save SVM support vectors
if exist('support_vectors','var')
    classification.support_vectors = support_vectors;
end
% Save discriminant analysis coefficients
if exist('coeff','var')
    classification.coefficients = coeff;
end
% Save error for iterative methods
if exist('error_hist','var')
    classification.error_hist = error_hist;
end
if exist('iteraction_w','var')
    classification.iteraction_w = iteraction_w;
    classification.iteraction_final = iteraction_final;
end
if exist('lambda','var')
    classification.lambda = lambda;
end
% Get from which class were the wrong items classified.
%[wrong_classified, class] = hist(original_class(find(~(Y == Y_out))), unique(original_class));
%classification.wrong_classified = wrong_classified;
