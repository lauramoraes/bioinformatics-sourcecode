%% Teste regress�o log�stica

separated_list{1} = [6];
separated_list{2} = [1; 2; 3; 4; 5; 7; 8; 9; 10];
marc = 1:784;
train_set = extract_features(marc, train_set);
%[X, original_class] = get_data_from_list(separated_list,train_set, true);
[X, original_class] = get_data_from_list(separated_list,train_set, false);
[X,Y, mu, sigma] = load_data(X, false, false, false);
Y(find(Y==-1)) = 0;


balanced_weights = [];
obs_total = find(Y == 0);
balanced_weights(obs_total) = 1/length(obs_total);
obs_total = find(Y == 1);
balanced_weights(obs_total) = 1/length(obs_total);

opts=struct('standardize',false, 'weights', balanced_weights');
opts.thresh= 1e-03
%opts.nfolds = 20;
%opts.parallel = true;
%opts = [];

tic;
%[w, FitInfo] = lassoglm(X, Y, 'binomial', 'Standardize', false, 'NumLambda', 50, 'Weights', balanced_weights);
%[w, FitInfo] = lassoglm(X, Y, 'binomial', 'Standardize', false, 'NumLambda', 10, 'Weights', balanced_weights);
fit = glmnet(X, Y, 'binomial', opts)
%fit = cvglmnet(X, Y, 'binomial', opts)
t = toc;
disp('Elapsed Time: ')
disp(t);
disp(fit);
%glmnetPlot(fit, 'dev');
%figure;
%glmnetPlot(fit, 'lambda');
%figure;
%glmnetPlot(fit, 'norm');
%cvglmnetPlot(fit);

% [w, FitInfo] = lassoglm(X, Y, 'binomial', 'Standardize', false, 'NumLambda', 50);
E_in_hist = fit.dev;
h_hist = fit.lambda;
%E_in_hist = FitInfo.Deviance;
%h_hist = FitInfo.Lambda;
%E_in_hist = fit.cvm;
%h_hist = fit.lambda;
figure;
plot(log(h_hist), E_in_hist);
%lassoPlot(w,FitInfo,'PlotType','Lambda','XScale','log');

% Weight for min error found
[err, index] = max(E_in_hist);
%[err, index] = min(E_in_hist);

weight = vertcat(fit.a0(index), fit.beta(:, index));
%weight = vertcat(FitInfo.Intercept(index), w(:, index));
%weight = cvglmnetCoef(fit, h_hist(index));
disp('Pesos calculados pela regulariza��o:')
disp(weight')


%%%% Prediction by Tibishirani function %%%%%
%pfit=glmnetPredict(fit, X, h_hist(index),'response');
%pfit=cvglmnetPredict(fit, X, 'lambda_min');

X = [ones(size(X,1),1) X];
%Y_hat = X*weight;
%Y_out = (exp(Y_hat) ./ (1 + exp(Y_hat)))
Y_out = mnrval(weight,X(:,2:end));
y_out = classify_data(X,weight);
%disp('Minha saida:');
%disp(y_out);
figure;
scatter(X(:,2),Y_out(:,2), 50, Y);
hold on
line([min(X(:,2)) max(X(:,2))], [0.5 0.5])
hold off

%%% Compare logit results %%%
%all(ismemberf(pfit, Y_out(:,1), 'rows'))

%

%  Y(find(Y==0)) = 2;
%  [B, dev, stats] = mnrfit(X,Y)
%  [X,Y, mu, sigma] = load_data(X, true, false, true);
%  pihat = mnrval(B,X_norm)
%  figure;
%  scatter(X_total(:,2),pihat(:,1), 50, Y_total);
%  hold on
%  line([min(X_total(:,2)) max(X_total(:,2))], [0.5 0.5])
%  hold off