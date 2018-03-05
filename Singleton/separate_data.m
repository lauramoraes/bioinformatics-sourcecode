function [node, train_set_ldata, train_set_rdata] = separate_data(node, X, classification, train_set_init, original_class, original_index, X_init, total)


ldata = cell(size(total,2),1);
original_ldata = [];
rdata = cell(size(total,2),1);
original_rdata = [];
train_set_ldata = cell(size(total,2),1);
train_set_rdata = cell(size(total,2),1);
node.under_cut = 1;

%%%%%%%%%%%%%%%%%%
%% ALG3-NOTPURE %%
%%%%%%%%%%%%%%%%%%
% Separate the ones that are correct and incorrect into ldata and rdata
for index=1:2
    % Just classify the data from one class
    Y_out = classify_data(X{index}, classification.w);
    ldata_index = find(Y_out == -1);
    for i=1:size(ldata_index,1)
        ldata{original_class{index}(ldata_index(i))} = vertcat(ldata{original_class{index}(ldata_index(i))}, X_init{index}(ldata_index(i),:));
        original_ldata = vertcat(original_ldata, original_class{index}(ldata_index(i)));
        ts_class = original_index{index}(ldata_index(i), 1);
        ts_index = original_index{index}(ldata_index(i), 2);
        train_set_ldata{ts_class} = vertcat(train_set_ldata{ts_class}, train_set_init{ts_class}(ts_index,:));
    end
    
    rdata_index = find(Y_out == 1);
    for i=1:size(rdata_index,1)   
        rdata{original_class{index}(rdata_index(i))} = vertcat(rdata{original_class{index}(rdata_index(i))}, X_init{index}(rdata_index(i),:));
        original_rdata = vertcat(original_rdata, original_class{index}(rdata_index(i)));
        ts_class = original_index{index}(rdata_index(i), 1);
        ts_index = original_index{index}(rdata_index(i), 2);
        train_set_rdata{ts_class} = vertcat(train_set_rdata{ts_class}, train_set_init{ts_class}(ts_index,:));
    end
end

% Pretty print for unknown class
if isempty(node.key)
    node.key = '??';
end

% Available classes in each children
node.llist = original_ldata;
node.rlist = original_rdata;
end

