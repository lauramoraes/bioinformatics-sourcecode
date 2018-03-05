function [ target_val, single, multiple ] = get_confusion_mat(target, output)
%% Get confusion matrix results considering single and multiple results

target_val = zeros(size(output,1), 1);
single = zeros(size(output,1), 1);
multiple = zeros(size(output,1), 1);

for i=1:size(output,1)
    tvalue = target{i,1};
    target_val(i) = tvalue;
    ovalue = output{i,1};
    if(ismember(tvalue, ovalue) == 1)
        multiple(i) = tvalue;
        if size(ovalue, 2) == 1
            single(i) = tvalue;
        else
            result = sprintf('%d',ovalue);
            single(i) = str2double(result);
        end
    else
        result = sprintf('%d',ovalue);
        single(i) = str2double(result);
        multiple(i) = str2double(result);
    end
end

