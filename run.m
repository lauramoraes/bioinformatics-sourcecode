original_dataset_path = 'Datasets/Dataset/seb_cell_2015_07_23_norm_lpl+mzl_no_extras.mat';
load(original_dataset_path);
marc = 1:max(size(marc_label));
borders_leave_one_out(original_dataset_path,marc,marc_label);