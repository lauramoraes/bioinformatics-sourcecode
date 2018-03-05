function classification = second_round(train_group, mode, attr_label, save_folder)
% Temporary function to check 2nd round of classifications
% Parameters:
% train_set: training set (divided by classes)
% first_list: list with class division
% mode: classifier mode. Options: linear_regression,
% linear_regression_modified. Default: linear_regression_modified

if ~exist('mode','var')
    mode = 'logistic_regression';
end

% Set separated list
separated_list = {};
separated_list{1} = [1];
separated_list{2} = [2];

plot_index = 2;
% Should break when no precision is found anymore. 100 times just to
% guarantee this while loop won't go forever
for j=0:100
    
    % Load in separated variables - keep original values
    %[X_init, original_class, repeated_index, balanced_class] = get_data_from_list(separated_list,train_group, true);
    [X_init, original_class] = get_data_from_list(separated_list,train_group);
    
    [classification, X, Y] = generate_classification([1], X_init, 'logistic_regression');
    
    % Join attr names to make fig name
    fig_attr = strjoin(attr_label, '_');
    % Set axis label
    attr_plot = horzcat(attr_label, 'Output');
    % Plot
    division_plot = plot_division(X, classification.w, plot_index, attr_plot);
    % Concat name and save figure
    fig_name = strcat(save_folder, '/', fig_attr, '_', int2str(j));
    saveas(division_plot, fig_name, 'fig');
    saveas(division_plot, fig_name, 'png');
    close(division_plot);
    
    % New fig
    error_plot = figure('Visible','off');
    % Set axis
    t = 1:size(classification.error_hist, 1);
    all_error = [abs(classification.error_hist) sum(abs(classification.error_hist),2)];
    plot(t, all_error);
    % Set axis label
    attr_error = horzcat('Bias', attr_label, 'Total');
    legend(attr_error)
    % Concat name and save figure
    fig_name = strcat(save_folder, '/error_', fig_attr, '_', int2str(j));
    saveas(error_plot, fig_name, 'fig');
    saveas(error_plot, fig_name, 'png');
    close(error_plot);
    
    % Get results (train)
    fmt = sprintf('Confusion matrix after %d division(s).', j);
    disp(fmt);
    disp(classification.confusion_matrix);
    
    % If found 100% accuracy
    if classification.accuracy == 100
        fmt = sprintf('Found 100%% accuracy after %d division(s).',  j);
        disp(fmt);
        % Finish classification            
        break;
    end
    
    % If one of the classes has precision 100%, remove these elements
    index = find(classification.precision == 100);
    if ~(isempty(index))
        
        % Just classify the data from one class
        Y_out = classify_data(X{index}, classification.w);
        
        % Remove the ones that are correct from original_class
        original_class{index} = original_class{index}(Y{index} ~= Y_out, :);

        %if balanced_class == index
        %    repeated_index = repeated_index(Y{index} ~= Y_out, :);
        %else
        X_init{index} = X_init{index}(Y{index} ~= Y_out, :);
        %end
        % Remove the ones that are correct from X_init (original values)
        %X_init{balanced_class} = X_init{balanced_class}(unique(repeated_index), :);    
        
        % Get values for train_group
        train_group = {};
        train_group{1} = X_init{1};
        train_group{2} = X_init{2};
        
    else
        % Finish classification
        fmt = sprintf('Couldn''t find 100%% precision. Stopping after %d division(s).', j);
        disp(fmt);
        break;
    end
end