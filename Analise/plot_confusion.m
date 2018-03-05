function confusion_plot = plot_confusion(target, output, label)
%% Function that scales target and output to 0 and 1 and print confusion
%% matrix
% Parameters:
% target: target matrix with values {-1,1}
% output: output matrix with values {-1,1}
% label: confusion matrix for which data?

% Scale values between 0 and 1
target = (target+1).*0.5;
output = (output+1).*0.5;

confusion_plot = plotconfusion(target',output',label);