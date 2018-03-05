function distance = std_distance(X0, X, Y)
        
    if size(X,2) > 1
        disp('This distance is only defined for elements with one attribute');
        distance = [];
        return
    end
    
    [classes, count] = unique(Y);
    
    % Check if number of elements in each class is bigger than one.
    % Otherwise, std is 0 and distance doesn't work. It's just one, use
    % distance to the class centroid.
    if ~isempty(find(count == 1))
        distance_name = 'centroid';
    else
        distance_name = 'std';
    end
    
    for i=1:length(classes)
        class_index = find(Y == classes(i));
        class_mean = mean(X(class_index,:));
        class_std = std(X(class_index,:));
        if strcmp(distance_name, 'std')
            distance(class_index,:) = abs((X0 - class_mean))./class_std;
        elseif strcmp(distance_name, 'centroid')
            distance(class_index,:) = abs((X0 - class_mean));
        else
            disp('No distance defined.');
            distance = [];
            return
        end
    end
        
end