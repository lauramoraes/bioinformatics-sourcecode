function [weight, E_in_hist, iteraction_w, iteraction_final, w] = logistic_regression(X, Y, w_init, t_max)
%% Function to calculate the weight vector that represents the hyperplane
%% to separate two classes using logistic regression

% W init is an uniform distribution
%min_val = -10;
%max_val = 10;
%w_init = unifrnd(min_val,max_val, 1, size(X,2));

% W init is a normal distribution
%mu = 0;
%sigma = 1/3;
%w_init = normrnd(mu,sigma,1, size(X,2));

% W init starts at 0.5
%w_init = 0.5 * ones(1, size(X,2));

w(1,:) = w_init;

% Max iteration
if ~exist('t_max','var')
    t_max = 3000;
end
% Error threshold
threshold = 0.1;
% Learning rate
alfa = 0.7;
% Regularization lambda
lambda = 0.01;

% Calcular o erro tamb�m - save the best!!
E_in_hist = [];
%E_in_ln = 1;
E_aug = 1;
init_i = 10;
iteraction = 0;
%tic;
for t=1:t_max
    %if ~rem(t,t_max)
       %fprintf('Iteracao %d\n',t);
       %fprintf('Error: %f\n',E_in_ln);
       %fprintf('Error old: %f\n',E_in_ln_old);
       %fprintf('Delta: %f\n',delta_error);
       %fprintf('Percent: %f\n',percent_error);
    %end
   
    E_in = zeros(2,size(X,2));
    E_in_ln_class = zeros(2,1);
    for i=1:size(X,1)
        % Small linear calculation to make y=-1 into index 1 and y=1 into
        % index 2
        class_index = 0.5*Y(i)+1.5;
        obs_error = (Y(i)*X(i,:)) / (1 + exp(Y(i) * X(i,:) * w(t,:)' ));
        [row, col] = find(isnan(obs_error));
        if ~(isempty(row))
            %fprintf('Found NaN at row %d column %d\n', row, col)
            weight = w(1,:)';
            break
        end
        E_in(class_index,:) = E_in(class_index,:) + obs_error;
        %t1 = toc;
        %fprintf('Time calculating err for obs %d:', i)
        %disp(t1)
    end
    grad_E_in = -((E_in(1,:)./size(find(Y==-1),1)) + (E_in(2,:)./size(find(Y==1),1)));
    % With regularization
    % grad Eaug = grad Ein + (2 * lambda * w)/N
    grad_E_aug = grad_E_in + ((2 * lambda * w(t,:))./size(Y,1));
    %w(t+1,:) = w(t,:) - alfa * grad_E_in;
    w(t+1,:) = w(t,:) - alfa * grad_E_aug;
    %E_in_hist = vertcat(E_in_hist, grad_E_in);
    
    % Classification error
   y_out = classify_data(X, w(t+1,:)');
   if not(any(y_out - Y))
       %fprintf('Iteracao %d\n',t);
       init_i = init_i - 1;
       %fprintf('Got correct classes\n',t);
       if not(init_i)
           %fprintf('Breaking\n',t);
           break
       end
   end
    
    % My REAL logistic error
    %E_in_ln_old = E_in_ln;
    E_aug_old = E_aug;
    for i=1:size(X,1)
        class_index = 0.5*Y(i)+1.5;
        err = (1 + exp(-1 * Y(i) * X(i,:) * w(t+1,:)'));
        ln_error = log(err);
        E_in_ln_class(class_index,:) = E_in_ln_class(class_index,:) + ln_error;
        %t2 = toc;
        %fprintf('Time calculating real err for obs %d', i)
        %disp(t2)
    end
    E_in_ln = ((E_in_ln_class(1,:)./size(find(Y==-1),1)) + (E_in_ln_class(2,:)./size(find(Y==1),1)));
    % With regularization
    % Eaug = Ein + (lambda * w^2)/N
    E_aug = E_in_ln + ((lambda * w(t,:) * w(t,:)')./size(Y,1));
    %E_in_hist = vertcat(E_in_hist, E_in_ln);
    %delta_error = E_in_ln_old-E_in_ln;
    %percent_error = delta_error/E_in_ln_old;
    E_in_hist = vertcat(E_in_hist, E_aug);
    delta_error = E_aug_old-E_aug;
    percent_error = delta_error/E_aug_old;
    
    if (abs(percent_error) < threshold && delta_error > 0)
        %fprintf('Iteracao %d\n',t);
        %fprintf('Error: %f\n',E_in_ln);
        %fprintf('Error old: %f\n',E_in_ln_old);
        %fprintf('Delta: %f\n',delta_error);
        %fprintf('Percent: %f\n',percent_error);
        break
    end
    %t3 = toc;
    %fprintf('Time calculating err for iteration %d', t)
    %disp(t3)
end
iteraction_final = t;
% Last calculated weight
[err, index] = min(E_in_hist);
%t=1:size(E_in_hist,1);
%plot(t, E_in_hist);
%fprintf('Error: %f\n',err);
weight = w(index,:)';
iteraction_w= index;
