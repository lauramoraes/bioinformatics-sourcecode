function [first_list, all_lists] = get_accuracy_csv(dataset_path, first_list_path, result_path, mode, balance, percent_per_class, min_w)
%% Script to separate linfomas in two lists and, train each list as being a
%% target for the linear regression and plot error
% Parameters:
% dataset_path: folder in which train_set is saved
% first_list_path: folder in which first_list is saved
% result_path: where to save results
% mode: classifier mode
% balance: balance data by adding elements in classes with less population.
% Default: false

%Load data
fname=fullfile(dataset_path);
load(fname);
% Load first list
fname=fullfile(first_list_path);
load(fname);

% Define default values
if ~exist('percent_per_class', 'var')
    percent_per_class = [];
end
if ~exist('min_w', 'var')
    min_w = false;
end

% Balance variable if set and linear regression mode
if (exist('mode','var') && (strcmp(mode, 'linear_regression') || strcmp(mode, 'logistic_regression') || strcmp(mode, 'lasso_regression')) && (exist('balance', 'var') && balance == true))
    balance = true;
elseif (exist('mode','var') && (~strcmp(mode, 'linear_regression') && ~strcmp(mode, 'logistic_regression') && ~strcmp(mode, 'lasso_regression')) && (exist('balance', 'var') && balance == true))
    disp('Balance only available for linear regression. Setting balance to false.')
    balance = false;
else
    balance = false;
end

%Define number of iterations (first classifier)
n = size(first_list,1);

all_lists = [];
list_100 = [];
train_set = train_set;
%tic;
parfor i=1:n
    % Display message every 100 lists
%     if ~rem(i,1)
%         verbose = sprintf('List %d/%d',i,n);
%         disp(verbose)
%         t1 = toc;
%         fprintf('Time for list %d/%d', i ,n)
%         disp(t1)
%     end
   %%%%%%%%%%%%%%%%%%%%%
   %% ALG4-REGRESSION %%
   %%%%%%%%%%%%%%%%%%%%%
   % Generate classification struct
   %tic
   classification = generate_classification(first_list(i,:), train_set, mode, balance, min_w);
   %t1 = toc;   
   %fprintf('Time')
   %disp(t1)
   % Skip when using just one class
   if classification.max_accuracy == 0
       continue;
   end
   % Separate division with 100% precision
   if classification.max_accuracy == 100
       list_100 = vertcat(list_100, classification);
   end
   all_lists = vertcat(all_lists, classification);
end

%t1 = toc;
%fprintf('Time for list %d/%d', i ,n)
%disp(t1)

% Sort classification by col position. Default: 1 (in this case, error)
fname=fullfile(strcat(result_path, '/results.csv'));
%%%%%%%%%%%%%%%
%% ALG4-SORT %%
%%%%%%%%%%%%%%%

all_lists = sort_classification(all_lists, percent_per_class);
save(strcat(result_path, '/all_lists.mat'), 'all_lists');

first_list = [];
fid = fopen(fname,'w');
for i=1:size(all_lists,1)
    % Get list data
    first_list_temp = all_lists(i).first_list;
    max_size_list = floor(size(train_set, 2)/2);
    zero_matrix = zeros(size(first_list_temp,1),size(zeros(1,max_size_list),2)-size(first_list_temp,2));
    first_list_temp = [first_list_temp, zero_matrix];
    %Construct first_list array
    first_list = vertcat(first_list, first_list_temp);
    % Use all_lists struct to save it to CSV file
    fprintf(fid,'%.4f;', all_lists(i).max_accuracy);
    fprintf(fid,'%.4f;%.4f;%.4f;%.4f;%.4f;;', all_lists(i).accuracy, all_lists(i).precision(1), all_lists(i).precision(2), all_lists(i).recall(1), all_lists(i).recall(2));
    fmt_firstlist = repmat('%d;', 1, length(all_lists(i).first_list));
    fprintf(fid, strcat(fmt_firstlist,';'), all_lists(i).first_list);
    fmt_secondlist = repmat('%d;', 1, length(all_lists(i).second_list));
    fprintf(fid, fmt_secondlist, all_lists(i).second_list);
    %fprintf(fid, strcat('\nErro por classe:;;;;;;;', fmt_firstlist,';'),
    %all_lists(i).wrong_classified(all_lists(i).first_list));
    if any(percent_per_class)
        fprintf(fid, '\nHighest percent:;%.4f;%.4f;%.4f', all_lists(i).highest_percent1, all_lists(i).highest_percent2, all_lists(i).highest_percent);
    end
    fprintf(fid, '\nAttr Quant:;%d;', all_lists(i).attr_lenght);
    if isfield(all_lists(i), 'separability')
        if all_lists(i).separability == 1
            fprintf(fid, ';Separability:;%.2f;', all_lists(i).separability);
        else
            fprintf(fid, ';Separability:;%.5f;', all_lists(i).separability);
        end
    end
    if isfield(all_lists(i), 'error_hist')
        if min(all_lists(i).error_hist) == 0
            fprintf(fid, ';Min error:;%.2f;', min(all_lists(i).error_hist));
        else
            fprintf(fid, ';Min error:;%.4f;', min(all_lists(i).error_hist));
        end
    end
    if isfield(all_lists(i), 'iteraction_w')
       fprintf(fid, ';It w:;%d;;It f:;%d', all_lists(i).iteraction_w, all_lists(i).iteraction_final);
    end
    if isfield(all_lists(i), 'lambda')
       fprintf(fid, ';Lambda:;%.4f', all_lists(i).lambda);
    end
    %fprintf(fid, fmt_secondlist, all_lists(i).wrong_classified(all_lists(i).second_list));
    %fmt = repmat('%.3f;', 1, length(all_lists(i).w_norm));
    fmt = repmat('%.3f;', 1, length(all_lists(i).w));
    fprintf(fid, strcat('\nPesos:;', fmt,'\n\n'), all_lists(i).w);
    %fmt = repmat('%.3f;', 1, length(all_lists(i).w));
    %fprintf(fid, strcat('\nPesos:;', fmt,'\n\n'), all_lists(i).w);
end
save(first_list_path, 'first_list','-mat');
fclose(fid);
