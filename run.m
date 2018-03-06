%% Running for new dataset
p = genpath('.');
addpath(p);
original_dataset_path = '../data/seb_cell_2015_07_23_norm_lpl+mzl_no_extras.mat';
borders_matrix_path = 'Datasets/Dataset/borders_matrix.mat';
load(original_dataset_path);
marc = 1:max(size(marc_label));
borders_in_sample(original_dataset_path,marc,marc_label, borders_matrix_path);
get_trees(original_dataset_path, 0.4, marc);
mkdir('/results/new')
mkdir('/results/new/borders')
movefile('Datasets/Dataset/confusion*', '/results/new/borders');
movefile('Datasets/Dataset/logist*', '/results/new/borders');
movefile('Datasets/Dataset/markers*', '/results/new/borders');
mkdir('/results/new/results')
movefile('Resultados/*', '/results/new/results');
mkdir('/results/new/nodes')
movefile('Resultados Node/*', '/results/new/nodes');

%% Running for in sample
original_dataset_path = '../data/seb_cell_2015_07_23_norm_lpl+mzl_in_sample.mat';
borders_matrix_path = 'Datasets/Dataset/borders_matrix.mat';
load(original_dataset_path);
marc = 1:max(size(marc_label));
borders_in_sample(original_dataset_path,marc,marc_label, borders_matrix_path);
get_trees(original_dataset_path, 0.4, marc);
mkdir('/results/in_sample')
mkdir('/results/in_sample/borders')
movefile('Datasets/Dataset/confusion*', '/results/in_sample/borders');
movefile('Datasets/Dataset/logist*', '/results/in_sample/borders');
movefile('Datasets/Dataset/markers*', '/results/in_sample/borders');
mkdir('/results/in_sample/results')
movefile('Resultados/*', '/results/in_sample/results');
mkdir('/results/in_sample/nodes')
movefile('Resultados Node/*', '/results/in_sample/nodes');

