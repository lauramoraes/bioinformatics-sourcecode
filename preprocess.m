function preprocess(simulate, normal, mode, balance)
%% Script to preprocess and prepare variables that will be used in the main
% program
% Parameters:
% simulate: yes or no, use simulated or real data. Default: no
% normal: if real data, include Normal category or not. Default: yes
% mode: which classifier to use. Options: linear_regression,
% linear_modified, linear_discriminant, linear_SVM, quadratic_discriminant,
% quadritic_SVM. Default: linear_modified
% balance: balance data by adding elements in classes with less population.
% Default: false
base_dataset_path = 'Datasets/Dataset';

if ~exist('simulate', 'var') || (exist('simulate', 'var') && (strcmp(simulate, 'no')))
    disorders_struct = load('Dataset/Seb_main_Marzo13_New.mat');
    disorders_struct = rmfield(disorders_struct, 'MZL_semUso');
%     disorders_struct = load(strcat(base_dataset_path, '/Seb_main_Marzo13.mat'));

    %if ~exist('normal', 'var') || (exist('normal', 'var') && (strcmp(normal, 'no')))
    if (exist('normal', 'var') && (strcmp(normal, 'no')))
        disorders_struct = rmfield(disorders_struct, 'Normal');
    else
        normal_struct = disorders_struct.Normal;
        disorders_struct = rmfield(disorders_struct, 'Normal');
        disorders_struct.Normal = normal_struct;
    end
    
     %disorders_struct = rmfield(disorders_struct, 'CD10Pos');
     %disorders_struct = rmfield(disorders_struct, 'CD10Neg');
     %disorders_struct = rmfield(disorders_struct, 'MZL');
     %disorders_struct = rmfield(disorders_struct, 'LPL');
     %disorders_struct = rmfield(disorders_struct, 'MCL');
     %disorders_struct = rmfield(disorders_struct, 'FL');
     %disorders_struct = rmfield(disorders_struct, 'CLL');
     %disorders_struct = rmfield(disorders_struct, 'BL');
    
    disorders_struct
    [disorders, train_set, test_set] = transform_data(disorders_struct,  1);

    %marc = [ 1 2 3 4 5 6 7 8 9 11 12 13 14 15 16 17 18 19 20 21 22 23 24 26 27 28];
    marc_label = {'CD10', 'CD103', 'CD11', 'CD19', 'CD20', 'CD200',	'CD22', 'CD23', 'CD27',	'CD3',	'CD31',	'CD38',	'CD39', 'CD43' , 'CD45', 'CD49', 'CD5',	'CD56+IgK',	'CD62',	'CD79b',	'CD8+IgL',	'CD81','CD95',	'CXCR5', 'FSC-A', 'HLADR',	'smIgM', 'LAIR1', 'SSC-A', 'Kappa-Lambda'};

    % Extracting markers + simulated Kappa/Lambda
    marc = [ 1 2 3 4 5 6 7 8 9 11 12 13 14 15 16 17 18 19 20 21 22 23 24 26 27 28 30];
    marc_label = {marc_label{marc}};
    %disp('Using markers:')
    %disp(marc_label)
    disorders = extract_features(marc, disorders);
    train_set = extract_features(marc, train_set);
    test_set = extract_features(marc, test_set);
    %marc = [ 4 5 11 14 16 17 20 ];
    %marc = [27];
    %marc = [ 4 5 11 14 16 ];

    save(strcat(base_dataset_path, '/seb_cell_lpl_mzl.mat'), 'disorders', 'train_set', 'test_set', 'marc_label', '-mat');
    dataset_path = strcat(base_dataset_path, '/seb_cell_lpl_mzl.mat');
else
    dataset_path = strcat(base_dataset_path, '/disorder_data.mat');
    fname=fullfile(dataset_path);
    load(fname);
end

% first_list = create_lists_no_restriction(length(disorders));
% save(strcat(base_dataset_path, '/first_list.mat'), 'first_list','-mat');

if ~exist('mode', 'var')
    mode = 'linear_regression_modified';
end
if ~exist('balance', 'var')
    balance = false;
end

% get_accuracy_csv(dataset_path, strcat(base_dataset_path, '/first_list.mat'), base_dataset_path, mode, balance);