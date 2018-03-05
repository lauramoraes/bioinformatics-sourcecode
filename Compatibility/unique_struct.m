function [struct_array, ix] = unique_struct(struct_array)

isUnique = true(size(struct_array));
for ii = 1:size(struct_array,1)-1
    for jj = ii+1:size(struct_array,1)
        if isequal(struct_array(ii),struct_array(jj))
            isUnique(ii) = false;
            break;
        end
    end
end
struct_array(~isUnique) = [];
ix = find(isUnique);