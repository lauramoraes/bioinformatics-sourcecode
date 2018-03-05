%% Lasso for dummies

points = 100;
% mu1 = [0 0 0];
% sigma1 = [3 0 0; 0 3 0; 0 0 3];
% mu2 = [3 3 3];
% sigma2 = [3 0 0; 0 3 0; 0 0 3];

% set1 = mvnrnd(mu1, sigma1, points);
set1 = [];
set2 = [];
set1(:, 1) = 5.5*rand(points,1);
% set2 = mvnrnd(mu2, sigma2, points);
set2(:, 1) = 5 + 5*rand(points,1);
set1(:, 2) = 10*rand(points,1);
set2(:, 2) = 10*rand(points,1);

figure;
% scatter(set1(:,1), set1(:,2));
scatter(set1(:,1), set1(:,2));
hold on;
% scatter(set2(:,1), set2(:,2));
scatter(set2(:,1), set2(:,2));
hold off;

X = [set1; set2]
Y = zeros(length(X), 1);
Y(1:length(set1)) = 1;

balanced_weights = [];
obs_total = find(Y == 0);
balanced_weights(obs_total) = 1/length(obs_total);
obs_total = find(Y == 1);
balanced_weights(obs_total) = 1/length(obs_total);

% [w, FitInfo] = lassoglm(X, Y, 'binomial', 'Standardize', false, 'NumLambda', 50, 'Weights', balanced_weights);
[w, FitInfo] = lassoglm(X, Y, 'binomial', 'Standardize', false, 'NumLambda', 50);
E_in_hist = FitInfo.Deviance;
h_hist = FitInfo.Lambda;
%plot(h_hist, E_in_hist);
%lassoPlot(w,FitInfo,'PlotType','Lambda','XScale','log');

% Weight for min error found
[err, index] = min(E_in_hist)

weight = vertcat(FitInfo.Intercept(index), w(:, index));
disp('Pesos calculados pela regularização:')
disp(weight)

% X = [ones(size(X,1),1) X];
%Y_hat = X*weight;
%Y_out = (exp(Y_hat) ./ (1 + exp(Y_hat)));
Y_out = mnrval(weight,X);
y_out = classify_data([ones(size(X,1),1) X] ,weight);
y_out(find(y_out==-1)) = 0;
% y_out = classify_data(X,weight);
%disp('Minha saida:');
%disp(y_out);
figure;
scatter(X(:,1),Y_out(:,1), 80, Y, 'LineWidth',2);
hold on
line([min(X(:)) max(X(:))], [0.5 0.5])
line([min(X(:)) max(X(:))], [0.65 0.65], 'LineStyle', '--', 'Color', 'red')
line([min(X(:)) max(X(:))], [0.35 0.35], 'LineStyle', '--', 'Color', 'red')
hold off

target = [Y ~Y]';
output = [y_out ~y_out]';
h1 = figure;
plotconfusion(target, output);
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