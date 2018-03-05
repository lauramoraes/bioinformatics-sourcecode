function plot_scatter(classes, weight, attributes)

for i=1:length(classes)
    x = sum(bsxfun(@times, classes{i}(:,attributes{1}), weight{1}'), 2)
    y = sum(bsxfun(@times, classes{i}(:,attributes{2}), weight{2}'), 2)
    
    scatter(x,y)
    hold on;
    pause
end