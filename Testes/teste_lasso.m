%% Teste regress�o log�stica

%X_not_norm = [2; 3; 4; 7; 10; 20];
X_not_norm = cell(1,2);
X_not_norm{1} = [-5 1; -2 2; 1 2; 2 5; 1 3; 2.5 4; 1.5 6; -1 8;]
X_not_norm{2} = [3 5; 4 7; 5 8; 6 9];
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
X_norm = (X_temp-min_vals)./(max_vals-min_vals);
disp('Entrada normalizada:')
disp(X_norm)


%disp(X_total)
X_total = X_norm;

%Y = [-1; -1; -1; 1; 1; 1];
%scatter(X(:,2),Y);
Y = cell(1,2);
Y{1} = [1; 1; 1; 1; 1; 1; 1; 1;];
Y{2} = [0; 0; 0; 0];
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

balanced_weights = [];
obs_total = find(Y_total == 0)
balanced_weights(obs_total) = 1/length(obs_total)
obs_total = find(Y_total == 1)
balanced_weights(obs_total) = 1/length(obs_total)
pause

[w, FitInfo] = lassoglm(X_total, Y_total, 'binomial', 'Standardize', false, 'Weights', balanced_weights);
E_in_hist = FitInfo.Deviance;
h_hist = FitInfo.Lambda;
plot(h_hist, E_in_hist);
lassoPlot(w,FitInfo,'PlotType','Lambda','XScale','log');

% Weight for min error found
[err, index] = min(E_in_hist)

weight = vertcat(FitInfo.Intercept(index), w(:, index));
disp('Pesos calculados pela regulariza��o:')
disp(weight)
X_total = [ones(size(X_total,1),1) X_total];
Y_hat = X_total*weight;
Y_out = (exp(Y_hat) ./ (1 + exp(Y_hat)));
disp('Minha saida:')
disp(Y_out)
figure;
scatter(X_total(:,2),Y_out, 50, Y_total);
hold on
line([min(X_total(:,2)) max(X_total(:,2))], [0.5 0.5])
hold off

y_out = classify_data(X_total,weight);

Y = [1; 1; 1; 1; 1; 1; 1; 1; 2; 2; 2; 2];
[B, dev, stats] = mnrfit(X_norm,Y)
pihat = mnrval(B,X_norm)
figure;
scatter(X_total(:,2),pihat(:,1), 50, Y_total);
hold on
line([min(X_total(:,2)) max(X_total(:,2))], [0.5 0.5])
hold off