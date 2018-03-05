function [ix] = find_equal_struct(struct_array_main, struct_array)

ix = [];

for ii = 1:size(struct_array,1)-1
    if isequal(struct_array_main, struct_array(ii))
        ix = vertcat(ix, ii);
    end
end