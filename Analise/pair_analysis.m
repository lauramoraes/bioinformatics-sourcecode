function pair_analysis(data, separated_list, dimensions, fig_name, dimensions_labels, disorders_labels)
%% Function to plot data in a pair of dimensions
% Parameters:
% data: data to be plotted
% separated_list: how to separate data into two lists
% dimensions: in which 2 dimensions data should be plotted
% folder: where to save plots

% Separate dimensions
for i=1:length(data)
    data_plotted{i} = data{i}(:,dimensions);
end
% Separate label
dimensions_label = dimensions_labels(dimensions);

% Separate data in list and save plot
% space_plot = plot_space(data_plotted, length(data), [1, 2], 2, dimensions_label);
% legend(disorders_labels);
% saveas(space_plot, fig_name, 'fig');
% saveas(space_plot, fig_name, 'png');
get_data_from_list(separated_list, data_plotted, false, fig_name, dimensions_label, disorders_labels);