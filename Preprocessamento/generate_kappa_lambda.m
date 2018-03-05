function kappa_lambda = generate_kappa_lambda(category, quantity)
%% Function to generate simulated data for kappa lambda values
% Parameters:
% category: normal or patologic. If normal, values will vary between 0.5 e
% 3.5. If not, values can be between 0 and 0.5 or 3.5 to 20 (they can
% actually be bigger then 20 in real life, but for this dataset max value 
% will be 20).
% quantity: quantity of numbers to generate.

if strcmp(category, 'Normal')
    % Generate normal distribution
    kappa_lambda = 0.5 + (3.5-0.5).*rand(quantity,1);
else
    % Generate patologic distribution
    % Inferior range
    kappa_lambda_temp(:, 1) = 0.500001.*rand(quantity,1);
    % Superior range
    kappa_lambda_temp(:, 2) = 3.5000001 + (20-3.5).*rand(quantity,1);
    % Inferior or superior (1 or 2)
    inf_or_sup = round(rand(quantity,1)) + 1;
    for i=1:quantity
        kappa_lambda(i, 1) = kappa_lambda_temp(i, inf_or_sup(i));
        %kappa_lambda(i, 1) = kappa_lambda_temp(i, 2);
    end
end