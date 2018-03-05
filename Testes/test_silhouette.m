function [sil_total, sil_stat] = test_silhouette(train_set, marc)

% Warning when creating folders
w = warning('off','all');

base_folder = 'Silhouette/';
disorders  = {'BL', 'CD10-', 'CD10+', 'CLL', 'FL', 'HCL', 'LPL', 'MCL', 'MZL', 'Normal'};
filename = 'silhouette.xls';
sil_total = zeros(size(train_set,2), size(train_set,2), size(train_set{1},2));
sil_stat = zeros(size(train_set,2),size(train_set,2), size(train_set{1},2));
sil_total_selected = zeros(size(train_set,2), size(train_set,2));
sil_stat_selected = zeros(size(train_set,2),size(train_set,2));
threshold = 0.65;


for i=1:size(train_set,2)
    for j=i+1:size(train_set,2)
        tic;
        folder = sprintf('%s x %s', disorders{i}, disorders{j});
        fprintf('Calculating silhouette for disorders %s\n', folder);
        save_folder = strcat(base_folder, folder, '/');
        mkdir(save_folder);
        separated_data{1} = train_set{i};
        separated_data{2} = train_set{j};
        [X, Y] = load_data(separated_data, false, false, false);
        for attr = 1:size(train_set{1},2)
            h = figure('Visible', 'off');
            [sil, h] = silhouette(X(:,attr), Y, 'std_distance', Y);
            %sil = silhouette(X(:,attr), Y);
            elements_c1 = size(separated_data{1},1);
            elements_c2 = size(separated_data{2},1);
            sil_c1 = 0.5*sum(sil(1:elements_c1))/elements_c1;
            sil_c2 = 0.5*sum(sil(elements_c1+1:end))/elements_c2;
            sil_stat_c1 = 0.5*sum(sil(1:elements_c1)>0)/elements_c1;
            sil_stat_c2 = 0.5*sum(sil(elements_c1+1:end)>0)/elements_c2;
            sil_total(i, j, attr) = sil_c1 + sil_c2;
            sil_stat(i, j, attr) = sil_stat_c1 + sil_stat_c2;
            title_str = sprintf('%s - Attribute %s', folder, marc{attr});
            title(title_str);
            saveas(h,strcat(save_folder, title_str),'fig');
            saveas(h,strcat(save_folder, title_str),'png');
            close all hidden;
        end
        % Write headers
        xlswrite(strcat(base_folder, filename), {'Attributes'}, folder, 'A1');
        xlswrite(strcat(base_folder, filename), {'Sil total/n elements'}, folder, 'B1');
        xlswrite(strcat(base_folder, filename), {'Sil pos/n elements'}, folder, 'C1');
        xlswrite(strcat(base_folder, filename), marc', folder, 'A2');
        % Write data
        A = reshape(sil_total(i,j,:),size(sil_total,3),1);
        B = reshape(sil_stat(i,j,:),size(sil_stat,3),1);
        xlswrite(strcat(base_folder, filename), A, folder, 'B2');
        xlswrite(strcat(base_folder, filename), B, folder, 'C2');
        
        % Select features
        marc_selected = find(B > threshold);
        %if ~isempty(marc_selected)
        %% Temporarily desativated until we define a standard deviation
        %% metric for Rn
        if false
            h = figure('Visible', 'off');
            % Calculate silhouette
            [sil, h] = silhouette(X(:,marc_selected), Y);
            %sil = silhouette(X(:,marc_selected), Y);
            sil_c1 = 0.5*sum(sil(1:elements_c1))/elements_c1;
            sil_c2 = 0.5*sum(sil(elements_c1+1:end))/elements_c2;
            sil_stat_c1 = 0.5*sum(sil(1:elements_c1)>0)/elements_c1;
            sil_stat_c2 = 0.5*sum(sil(elements_c1+1:end)>0)/elements_c2;
            sil_total_selected(i, j) = sil_c1 + sil_c2;
            sil_stat_selected(i, j) = sil_stat_c1 + sil_stat_c2;
            marcs_selected = marc(marc_selected);
            title_str = sprintf('%s - Attributes %s', folder, strjoin(marcs_selected, ', '));
            title(title_str);
            figname = strcat(save_folder, title_str); 
            if length(figname) > 100
                saveas(h,figname(1:100),'fig');
                saveas(h,figname(1:100),'png');
            else
                saveas(h,figname,'fig');
                saveas(h,figname,'png');
            end
        end
        t1 = toc;
        fprintf('Finished for comparison %s', folder)
        disp(t1);
        close all hidden;
    end
end

% Write headers
xlswrite(strcat(base_folder, filename), disorders', 'Resumo', 'A2');
xlswrite(strcat(base_folder, filename), disorders, 'Resumo', 'B1');
% Write data
xlswrite(strcat(base_folder, filename), sil_stat_selected, 'Resumo', 'B2');

% Write headers
xlswrite(strcat(base_folder, filename), disorders', 'Resumo2', 'A2');
xlswrite(strcat(base_folder, filename), disorders, 'Resumo2', 'B1');
% Write data
xlswrite(strcat(base_folder, filename), sil_total_selected, 'Resumo2', 'B2');