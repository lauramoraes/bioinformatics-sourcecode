function h = plot_tree( classification_tree, total )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

h = figure;
treeplot([classification_tree.parent]);
dcm_obj = datacursormode(h);
[x,y] = treelayout([classification_tree.parent]);
x = x';
y = y';
colors=hsv(10);

for i=1:size(x,1)
    
    fmt = sprintf('(%d)', i);
    text(x(i,1), y(i,1), fmt, 'VerticalAlignment','bottom','HorizontalAlignment','right');
    
    if classification_tree(i).accuracy ~= 100
        %text(x(i,1), y(i,1), mat2str(classification_tree(i).accuracy,4), 'VerticalAlignment','top','HorizontalAlignment','left');
        %text(x(i,1), y(i,1), mat2str(classification_tree(i).key), 'VerticalAlignment','bottom','HorizontalAlignment','left');
        fmt = sprintf('%s x %s', mat2str(classification_tree(i).listA), mat2str(classification_tree(i).listB));
        text(x(i,1), y(i,1), fmt, 'VerticalAlignment','top','HorizontalAlignment','left');
    end
    
    
    % Print lists in plot
    if ~isempty(classification_tree(i).llist)
        %text(x(i,1), y(i,1), mat2str(classification_tree(i).key),
        %'VerticalAlignment','bottom','HorizontalAlignment','left');
        llist = unique(classification_tree(i).llist)';
        rlist = unique(classification_tree(i).rlist)';
        if length(llist) > 1
            llist_elements = hist(classification_tree(i).llist, llist);
        else
            llist_elements = hist(classification_tree(i).llist, 1);
        end
        if length(rlist) > 1
            rlist_elements = hist(classification_tree(i).rlist, rlist);
        else
            rlist_elements = hist(classification_tree(i).rlist, 1);
        end
        fmt = sprintf('%s x %s', mat2str(llist), mat2str(rlist));
        text(x(i,1), y(i,1), fmt, 'VerticalAlignment','bottom','HorizontalAlignment','left');
        fmt = sprintf('%s x %s', mat2str(llist_elements), mat2str(rlist_elements));
        text(x(i,1), y(i,1), fmt, 'VerticalAlignment','top','HorizontalAlignment','left');
    end
    % Print quantity of elements (for singletons)
    if size(classification_tree(i).elements, 2) == 1
        text_color = (~round(colors(classification_tree(i).key,1)) & ~round(colors(classification_tree(i).key,2))) + zeros(1,3);
        text(x(i,1), y(i,1), mat2str(classification_tree(i).key), 'VerticalAlignment','bottom','HorizontalAlignment','left', 'BackgroundColor', colors(classification_tree(i).key,:), 'Color', text_color);
        %leaf = strcat(int2str(classification_tree(i).elements), '/', int2str(size(train_set{classification_tree(i).key},1)));
        leaf = strcat(int2str(classification_tree(i).elements), '/', int2str(total(classification_tree(i).key)));
        text(x(i,1), y(i,1), leaf, 'VerticalAlignment','top','HorizontalAlignment','right', 'BackgroundColor', colors(classification_tree(i).key,:), 'Color', text_color);
        % summary =
    end
    % Get singleton classification_tree with just one element
    %     if ~isempty(classification_tree(i).single_elements)
    %         data_single_elements = [data_single_elements; num2cell([i classification_tree(i).key classification_tree(i).single_elements])];
    %     end
end
end

