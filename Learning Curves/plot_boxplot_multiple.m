function [ output_args ] = plot_boxplot(folder, name, range, use_log)
% Function to plot boxplot for learning curves
% Input: 
% folder: main folder containing results
% use_log: flag to indicate whether to use log or not in x axis
% name: name to add into plot
% range: range of values to use in plot

fname=fullfile(folder, '/accuracy_multiple.mat');
load(fname);

acc_mean = mean(accuracy_array);
acc_std = std(accuracy_array);

if ~exist('use_log','var')
    use_log = false;
end

h1 = figure;
boxplot(accuracy_array, range);
xlabel('Sample Size')
ylabel('Accuracy')
title('Learning Curve of Digits')
%ax = get(fig,'CurrentAxes');
%set(ax,'XScale','log')


h2 = figure;
errorbar(range,acc_mean,acc_std, '-x');
xlabel('Sample Size')
ylabel('Accuracy')
title('Learning Curve of Digits')
if use_log
    ax = get(h2,'CurrentAxes');
    set(ax,'XScale','log')
end
fig_name1 = strcat(folder, '/', name, '_boxplot_multiple');
fig_name2 = strcat(folder, '/', name, '_errorbar_multiple');
saveas(h1, fig_name1,'fig');
saveas(h1, fig_name1,'png');
saveas(h2, fig_name2,'fig');
saveas(h2, fig_name2,'png');

end

