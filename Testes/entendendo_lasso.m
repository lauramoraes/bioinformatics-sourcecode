%clear
%load 'Resultados Node/1_2/Round1/1/3/rdata';
load 'Resultados Node/Round1/1/3/rdata';

separated_list{1} = [1];
separated_list{2} = [2; 3; 5; 7; 8; 9];


[X1, original_class] = get_data_from_list(separated_list,train_set, false);
%isequal(X1{1}, train_set{1})
%pause

[X,Y, mu, sigma] = load_data(X1, false, false, false);
%isequal(X(1:16,:), train_set{1})
%pause

% Train linear model
[w, E_in_hist, lambda, h_hist, weight]  = lasso_regression(X,Y);
fprintf('%.3f ', w')
fprintf('\n')


X = [ones(size(X,1),1) X];
Y_out = classify_data(X, w)