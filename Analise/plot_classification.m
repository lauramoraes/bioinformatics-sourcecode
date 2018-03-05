function classification_plot = plot_classification(input, target, output, dimensions)
%% Plot comparison between classified output and real output
% Parameters:
% input: input data
% target: real output
% output: classified output
% dimensions: vector with dimensions to plot

classification_plot = figure;
scatter(input(:, dimensions(1)), input(:, dimensions(2)), 60, output);
hold on;
scatter(input(:, dimensions(1)), input(:, dimensions(2)), 60, target, '+');
grid on;