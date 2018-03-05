function check_weight(test_set, weight)
%% Function to show step by step of weight sum
% Parameters:
% test_set: set to be analyzed
% weight: weight to use

n_elements = size(test_set,1);
%norm_elements = 10*(test_set - model.sigma(1:n_elements,:))./(model.mu(1:n_elements,:)-model.sigma(1:n_elements,:));
norm_elements = test_set;
%weight = model.model;

y_hat = zeros(1, n_elements);
y_out = zeros(1, n_elements);

for w=1:length(weight)
    fprintf('PARAMETER %d\n', w)
    for element=1:n_elements
        fprintf('Element %d\n', element)
        %fprintf('Norm: %f\n', norm_elements(element,w-1));
        %partial = norm_elements(element,w-1) * weight(w);
        fprintf('Norm: %f\n', norm_elements(element,w));
        partial = norm_elements(element,w) * weight(w);
        disp(partial)
        y_hat(element) = y_hat(element) + partial;
    end
    fprintf('SUM PARAMETER %d\n', w)
    for element=1:n_elements
        fprintf('Element %d', element)
        disp(y_hat(element))
    end
    pause
end

fprintf('RESULT\n')
for element=1:n_elements
    fprintf('Element %d', element)
    y_hat(element) = y_hat(element) + weight(1);
    disp(y_hat(element))
    y_out(element) = (exp(y_hat(element)) / (1 + exp(y_hat(element))));
    disp(y_out(element))
end
