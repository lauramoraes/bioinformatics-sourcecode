%% Teste regressão logística

%X_not_norm = [2; 3; 4; 7; 10; 20];
X_not_norm = cell(1,2);
X_not_norm{1} = [-5; -2; 1; 2;]
X_not_norm{2} = [3; 4; 5; 6];
disp('Entrada 1:')
disp(X_not_norm{1})
disp('Entrada 2:')
disp(X_not_norm{2})

%X_norm = zscore(vertcat(X_not_norm{1}, X_not_norm{2}));
X_temp = vertcat(X_not_norm{1}, X_not_norm{2});
max_val = max(X_temp);
max_vals = repmat(max_val,size(X_temp,1),1);
min_val = min(X_temp);
min_vals = repmat(min_val,size(X_temp,1),1);
X_norm = (X_temp - min_vals)./(max_vals-min_vals);
disp('Entrada normalizada:')
disp(X_norm)

X_total = [ones(size(X_norm,1),1) X_norm];
disp('Entrada normalizada com vies:')
disp(X_total)

%Y = [-1; -1; -1; 1; 1; 1];
%scatter(X(:,2),Y);
Y = cell(1,2);
Y{1} = [1; 1; 1; 1;];
Y{2} = [-1; -1; -1; -1];
Y_total = vertcat(Y{1},Y{2});
disp('Classes:')
disp(Y_total)

X = cell(1,2);
X{1}= X_total(1:size(X_not_norm{1},1),:);
X{2}= X_total(size(X_not_norm{1},1)+1:end,:);
disp('Entrada classe 1:')
disp(X{1})
disp('Entrada classe 2:')
disp(X{2})

w_init = linear_regression_modified(X,Y);
disp('Pesos iniciais calculados pela minha regressao:')
disp(w_init)

[w, error_hist] = logistic_regression(X_total,Y_total, w_init);
t = 1:size(error_hist,1);
%all_error = [error_hist sum(error_hist,2)];
%plot(t, abs(all_error));
disp('Erro final:')
disp(error_hist(end))
plot(t, error_hist);
disp('Pesos calculados pela minha regressao:')
disp(w)

Y_hat = X_total*w;
Y_out = (exp(Y_hat) ./ (1 + exp(Y_hat)));
disp('Minha saida:')
disp(Y_out)
figure;
scatter(X_total(:,2),Y_out, 50, Y_total);
hold on
line([min(X_total(:,2)) max(X_total(:,2))], [0.5 0.5])
hold off

y_out = classify_data(X_total,w);

Y = [1; 1; 1; 1; 2; 2; 2; 2];
B = mnrfit(X_norm,Y)
pihat = mnrval(B,X_norm)
figure;
scatter(X_total(:,2),pihat(:,1), 50, Y_total);
hold on
line([min(X_total(:,2)) max(X_total(:,2))], [0.5 0.5])
hold off