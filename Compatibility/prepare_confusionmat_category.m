function [classes, target1, output1, target2, output2, target1_cm, output1_cm, target2_cm, output2_cm] = prepare_confusionmat_category(target_in, output_in)

classes_int = vertcat(target_in, output_in);
classes = unique(cellfun(@(c_) num2str(c_), classes_int, 'UniformOutput', false), 'rows');
%assignin('base', 'classes_int', classes_int)
%assignin('base', 'classes', classes)
%classes = unique(classes_int, 'rows')
%pause

rows = size(target_in,1);
target1 = zeros(length(classes), rows);
output1 = zeros(length(classes), rows);
target2 = zeros(length(classes), rows);
output2 = zeros(length(classes), rows);

target1_cm = cell(rows, 1);
output1_cm = cell(rows, 1);
target2_cm = cell(rows, 1);
output2_cm = cell(rows, 1);

for i=1:rows
    index_in = strcmp(classes, num2str(target_in{i}));
    index_out = strcmp(classes, num2str(output_in{i}));
    % Set confusion matrix with exactly values
    target1(index_in, i) = 1;
    output1(index_out, i) = 1;
    
    % Calculate confusion matrix result (in addition to graphical CM)
    target1_cm{i, 1} = num2str(target_in{i});
    output1_cm{i, 1} = num2str(output_in{i});
    
    % Set confusion matrix with contains values
    comp_result = strfind(num2str(output_in{i}), num2str(target_in{i}));
    
    if ~isempty(comp_result) 
        target2(index_in, i) = 1;
        output2(index_in, i) = 1;
        
        target2_cm{i, 1} = num2str(target_in{i});
        output2_cm{i, 1} = num2str(target_in{i});
    else
        target2(index_in, i) = 1;
        output2(index_out, i) = 1;
        
        target2_cm{i, 1} = num2str(target_in{i});
        output2_cm{i, 1} = num2str(output_in{i});
    end
end