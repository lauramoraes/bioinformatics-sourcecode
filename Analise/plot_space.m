function space_plot = plot_space(data, quantity, dimensions, plot_type, dimensions_label)
%% Plot all disorders in 3D, showing the dimensions set in dimension.
% If no dimensions are defined, the first 3 dimensions will be plotted.
% data: data to be plotted.
% quantity: quantity of elements in cell_array
% dimensions: dimensions to be plotted. Ex.: [dim1, dim2, dim3]
% plot_type: 2D or 3D plots. Values: 2 or 3

if ~exist('dimensions')
    dimensions = [1, 2, 3];
end
if ~exist('plot_type')
    plot_type = 3;
end
if ~exist('dimensions_label')
    for i=1:length(dimensions)
        dimensions_label{i} = sprintf('Dimensão %d', i)
    end
end

space_plot = figure('Visible','off');
colors=hsv(quantity);
grid on;
hold on;

% Special case to plot just 2D
if length(dimensions) == 2 | plot_type == 2
    for i=1:quantity
        plot(data{i}(:,dimensions(1)), data{i}(:,dimensions(2)), 'linestyle', 'none', 'marker', '+', 'color', colors(i,:));
    end
else
    for i=1:quantity
        plot3(data{i}(:,dimensions(1)), data{i}(:,dimensions(2)), data{i}(:,dimensions(3)), 'linestyle', 'none', 'marker', '+', 'color', colors(i,:));
    end
end
xlabel(dimensions_label{1});
ylabel(dimensions_label{2});

% Special case to plot just 2D
if ~(length(dimensions) == 2) & ~(plot_type == 2)
    zlabel(dimensions_label{3});
end
hold off;