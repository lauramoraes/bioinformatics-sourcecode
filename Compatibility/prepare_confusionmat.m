function [target, output] = prepare_confusionmat(target_in, output_in)

classes = max(max(target_in, output_in));
rows = size(target_in,1);
target = zeros(classes, rows);
output = zeros(classes, rows);

for i=1:rows
    target(target_in(i),i) = 1;
    output(output_in(i),i) = 1;
end