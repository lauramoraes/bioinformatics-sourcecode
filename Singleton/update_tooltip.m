function weight_str = update_tooltip(empt,event_obj, x, y, classes, marc_label)

pos = get(event_obj, 'Position');
idx = find(x == pos(1));
idy = find(y == pos(2));
index = intersect(idx, idy);
if length(index) ~= 1
    weight_str = {['Couldn''t determine weight vector', '']};
end

if ~isempty(classes(index).weight)
    weight_str = cell(1, size(marc_label, 2));
    division = sprintf('%s x %s', mat2str(classes(index).listA), mat2str(classes(index).listB));
    for i=1:size(marc_label,2)
        label = sprintf('%s: ', marc_label{i});
        weight = sprintf('%.f', classes(index).weight(i));
        weight_str{i} = [label, weight];
    end
    weight_str = [['Division: ', division], weight_str];
else
    weight_str = {['Singleton', '']};
end
 