function [classification, confusion, classification_plot] = new_classification(separated_list, train_set, original_lists)
%% Given the separated list, separate data into 2 sets, train mode and check 
%% result performance

    [X,Y]=get_data_from_list(separated_list,train_set);
    [X,Y] = load_data(X, false, true, true);

    % Train linear model
    w = logistic_regression(X,Y);

    % Get results (train)
    Y_out = classify_data(X, w);
    confusion_matrix = confusionmat(Y, Y_out);
    total_percent = (confusion_matrix(1,1)+confusion_matrix(2,2))/sum(confusion_matrix(:))*100;
    for i=1:2
        recall(i) = confusion_matrix(i,i)/sum(confusion_matrix(i,:))*100;
        precision(i) = confusion_matrix(i,i)/sum(confusion_matrix(:,i))*100;
    end

    % Final data
    classification.listA = original_lists{1};
    classification.listB = original_lists{2};
    classification.w = w;
    classification.accuracy = total_percent;
    classification.precision = precision;
    confusion = '';
    classification_plot = '';

