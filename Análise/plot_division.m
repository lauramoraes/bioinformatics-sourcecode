function division_plot = plot_division(X, w, plot_index, label)
%% Function to plot the hyperplane classifier looking at dimension
%% plot_index
% X: separated data to plot
% w: weight vector from linear regression
% plot_index: dimension to observe the hyperplane

% Data to fit
[Y_out, Y_hat] = classify_data(X{1}, w);
Y_fit{1} = Y_hat;
[Y_out, Y_hat] = classify_data(X{2}, w);
Y_fit{2} = Y_hat;

% Data to plot
plot_data{1} = horzcat(X{1}(:, plot_index), Y_fit{1});
plot_data{2} = horzcat(X{2}(:, plot_index), Y_fit{2});

% Plot data
%space_plot = plot_space(plot_data, 2, [1, 2, 3], 3, {'CD19', 'KL', 'Output'});
division_plot = plot_space(plot_data, 2, [1, 2], 2, {label{[1,2]}});
hold on;   

% Calculate min and max points to plot hyperplane
min_matrix = [];
max_matrix = [];
input_min_matrix = [];
input_max_matrix = [];
[min_matrix(1), input_min_matrix(1)] = min(X{1}(:,plot_index));
[min_matrix(2), input_min_matrix(2)] = min(X{2}(:,plot_index));
[p1, input1] = min(min_matrix);
[max_matrix(1), input_max_matrix(1)] = max(X{1}(:,plot_index));
[max_matrix(2), input_max_matrix(2)] = max(X{2}(:,plot_index));
[p2, input2] = max(max_matrix);
x1 = X{input1}(input_min_matrix(input1), :);
x2 = X{input2}(input_max_matrix(input2), :);
y1 = x1*w;
y2 = x2*w;

% Plot fitted line
%line([x1(plot_index) x2(plot_index)], [y1 y2]);
% Plot hyperplane division
line([x1(plot_index) x2(plot_index)], [0.5 0.5], 'Color', 'g', 'LineWidth', 2);