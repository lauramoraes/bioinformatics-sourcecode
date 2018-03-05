function [separated_data, used_index, balanced_class] = balance_data(separated_data, mode)
%% If one class has more observations than the other, balance the number of
%% elements in each class by removing elements from the class that has more
%% or replicating elements in the class that have less.

% Parameters:
% separated_data: data cell, each index represents a class
% mode: 'add' to add data in the class that has less or 'remove' to remove
% data from the class that has more. Default: add

% Get individual sizes
size_class{1} = size(separated_data{1},1);
size_class{2} = size(separated_data{2},1);

% If they are the same, don't do anything
if size_class{1} == size_class{2}
    used_index = [];
    balanced_class = false;
    return
else
    % Else, get max (for add mode)
    size_max = max(size_class{1}, size_class{2});
    % Min (for remove mode)
    size_min = min(size_class{1}, size_class{2});
end

% Choose mode
if ~exist('mode','var')
    mode = 'add';
end

%warning = sprintf('Balancing data. Mode: %s',mode);
%disp(warning)

if strcmp(mode, 'add')
    for i=1:length(size_class)
        if ~(size_class{i} == size_max)
            balanced_class = i;
            % Create random index list to replicate elements
            index = randi(size_class{i},(size_max-size_class{i}),1);
            used_index = [[1:size_class{i}]'; index];
            for j=1:length(index)
                separated_data{i} = [separated_data{i}; separated_data{i}(index(j),:)];
            end
        end
    end
% Remove mode
else
    for i=1:length(size_class)
        if ~(size_class{i} == size_min)
            for j=1:(size_class{i}-size_min)
                % Create random index list to delete elements
                index = randi(size(separated_data{i},1),1,1);
                separated_data{i}(index,:) = [];
            end
        end
    end
end