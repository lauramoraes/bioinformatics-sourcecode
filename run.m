p = genpath('.');
addpath(p);
original_dataset_path = '../data/seb_cell_2015_07_23_norm_lpl+mzl_no_extras.mat';
borders_matrix_path = 'Datasets/Dataset/borders_matrix.mat';
load(original_dataset_path);
marc = 1:max(size(marc_label));
borders_in_sample(original_dataset_path,marc,marc_label, borders_matrix_path);
get_trees(original_dataset_path, 0.1, marc);
mkdir('/results/borders')
movefile('Datasets/Dataset/confusion*', '/results/borders');
movefile('Datasets/Dataset/logist*', '/results/borders');
movefile('Datasets/Dataset/markers*', '/results/borders');
mkdir('/results/rounds')
movefile('Resultados/*', '/results/rounds');
mkdir('/results/nodes')
movefile('Resultados Node/*', '/results/nodes');
