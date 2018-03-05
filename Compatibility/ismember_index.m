function idx = ismember_index(input_array, containing_array)
if size(input_array,2) > 1
    idx = 0;
else
    [p, idx] = ismember(input_array, containing_array);
end