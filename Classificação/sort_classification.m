function [all_classification, index] = sort_classification(all_classification, percent_per_class)
%% Function to sort classification objects by a parameter
% all_classification: list containing all classification struct
% percent_per_class: percentage of elements per class (to use as criteria for sorting)

if ~exist('percent_per_class', 'var')
    percent_per_class = [];
end

if ~exist('parameter_col', 'var')
    parameter_col = -1;
end

% Criteria chosen for sorting:
% 1. Precision error
% 2. Distribution of classes with highest percentage in different groups
% 3. Separate one class from all the others
% 4. Less attributes

%%%%%%%%%%%%%%%%
%% ALG5-CRIT2 %%
%%%%%%%%%%%%%%%%
% Criteria 2:

if any(percent_per_class)
    all_classification = arrayfun(@(x) setfield(x, 'highest_percent1', max(percent_per_class(x.first_list))), all_classification);
    all_classification = arrayfun(@(x) setfield(x, 'highest_percent2', max(percent_per_class(x.second_list))), all_classification);
    all_classification = arrayfun(@(x) setfield(x, 'highest_percent', max(percent_per_class(x.first_list))+ max(percent_per_class(x.second_list))), all_classification);
end

%%%%%%%%%%%%%%%%
%% ALG5-CRIT3 %%
%%%%%%%%%%%%%%%%
% Criteria 3:
all_classification = arrayfun(@(x) setfield(x, 'first_list_size', size(x.first_list,2)), all_classification);

%preferred_disorder = [4 6 1 10];
%all_classification = arrayfun(@(x) setfield(x, 'preferred_disorder', ismember_index(x.first_list, preferred_disorder)), all_classification);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ALG5-CRIT4 %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Criteria 4:
all_classification = arrayfun(@(x) setfield(x, 'attr_lenght', size(find(x.w ~= 0),1)), all_classification);
all_classification = arrayfun(@(x) setfield(x, 'separability_round', round(x.separability * 100)/100), all_classification);

%% Sort by error (FIRST COLUMN)
%all_classification

Afields = fieldnames(all_classification);

% TODO: define dinamically
%%%%%%%%%%%%%%%%
%% ALG5-CRIT1 %%
%%%%%%%%%%%%%%%%
% Sort criteria 1 in descending order
% parameter_col = find(strcmp(Afields, 'attr_lenght'));
parameter_col = -1*(find(strcmp(Afields, 'max_accuracy')));
parameter_col = horzcat(parameter_col, -1*(find(strcmp(Afields, 'separability_round'))));
% parameter_col = horzcat(parameter_col, -1*(find(strcmp(Afields, 'max_accuracy'))));
% parameter_col = horzcat(parameter_col, -1*(find(strcmp(Afields, 'accuracy'))));
%%%%%%%%%%%%%%%%
%% ALG5-CRIT2 %%
%%%%%%%%%%%%%%%%
% Sort criteria 2 in descending order
% if any(percent_per_class)
%     %parameter_col = horzcat(parameter_col, -1*(find(strcmp(Afields, 'highest_percent1'))));
%     %parameter_col = horzcat(parameter_col, -1*(find(strcmp(Afields, 'highest_percent2'))));
%     parameter_col = horzcat(parameter_col, -1*(find(strcmp(Afields, 'highest_percent'))));
% end
%%%%%%%%%%%%%%%%
%% ALG5-CRIT3 %%
%%%%%%%%%%%%%%%%
% Sort criteria 3 in ascending order
% parameter_col = horzcat(parameter_col, find(strcmp(Afields, 'first_list_size')));
%parameter_col = horzcat(parameter_col, -1*(find(strcmp(Afields, 'preferred_disorder'))));
%%%%%%%%%%%%%%%%
%% ALG5-CRIT4 %%
%%%%%%%%%%%%%%%%
% Sort criteria 4 in ascending order
parameter_col = horzcat(parameter_col, find(strcmp(Afields, 'attr_lenght')));

Acell = struct2cell(all_classification);
sz = size(Acell);
% Convert to a matrix
Acell = reshape(Acell, sz(1), []);      % Px(MxN)
% Make each field a column
Acell = Acell';                         % (MxN)xP
% Sort by first field "name" (max_accuracy)
[Acell, index] = sortrows(Acell, parameter_col);
% Put back into original cell array format
Acell = reshape(Acell', sz);
% Convert to Struct
all_classification = cell2struct(Acell, Afields, 1);