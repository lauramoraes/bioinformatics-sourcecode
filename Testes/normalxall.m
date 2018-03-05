function normalxall()
%% Train and check results for Normal x All

dataset_path = 'Datasets/Dataset/train_set.mat';

%Load data
fname=fullfile(dataset_path);
load(fname);

separated_list{1} = [1];
separated_list{2} = [2 3 4 5 6 7 8 9 10];

%disp('Size of train_set:')
%disp(size(train_set))

% Separate in 2 datasets
X_init = get_data_from_list(separated_list, train_set);
% disp('Size of X_init:')
% disp(size(X_init))
% disp('Size of X class 1:')
% disp(size(X_init{1}))
% disp('Size of X class 2:')
% disp(size(X_init{2}))

% Label before zscore (for testing)
% Y_aux = [];
% for k=1:size(X_init, 2)
%     for i=1:size(X_init{k}, 1)
%         if X_init{k}(i) < 3.5
%             if k~=1
%                 fmt = sprintf('CLASSE 2 encontrada, elemento %d', i);
%                 disp(fmt)
%             end
%             Y_aux = vertcat(Y_aux, -1);
%         else
%             Y_aux = vertcat(Y_aux, 1);
%             if k==1
%                 fmt = sprintf('CLASSE 1 encontrada, elemento %d', i);
%                 disp(fmt)
%             end
%         end
%     end
% end

% Put everything together, apply bias, zscore and label it
[X,Y] = load_data(X_init, false, true, true);
%disp('Size of X:')
%disp(size(X))

% Check if label is correct
% find((Y - Y_aux) ~= 0)

% Train logistic model
[w, error_hist] = logistic_regression(X,Y, [0.5 0.5 0.5 0.5 0.5 0.5 0.5]);
%disp('Meus pesos:')
%disp(w)
%w = linear_regression(X,Y);

Y_hat = X*w;
Y_hat = (exp(Y_hat) ./ (1 + exp(Y_hat)));
Y_out = sign(Y_hat-0.5);
disp('Minha saida:')
disp(Y_hat(1:16,:))
%figure;
%scatter(X(1:size(X_init,1),2),Y_hat(1:size(X_init,1)), 50, Y(1:size(X_init,1)));
%hold on
%scatter(X(size(X_init,1)+1:end,2),Y_hat(size(X_init,1)+1:end), 50, Y(size(X_init,1)+1:end));
%line([min(X(:,2)) max(X(:,2))], [0.5 0.5])
%hold off