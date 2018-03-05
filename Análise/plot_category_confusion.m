function [h1, h2, acc1, acc2] = plot_category_confusion(target, output)
%% Plot confusion matrix considering multiple results

final_output = clean_multiple_output(output);
[categories, target_all, output_all, target_compressed, output_compressed, target_all_number, output_all_number, target_compressed_number, output_compressed_number] = prepare_confusionmat_category(target, final_output);
categories{end+1} = '';



h1 = figure;
plotconfusion(target_all, output_all);
set(gca,'xticklabel',categories);
set(gca,'yticklabel',categories);

h2 = figure;
index_to_remove = all(output_compressed==0,2);
output_compressed(index_to_remove,:) = [];
target_compressed(index_to_remove,:) = [];
categories(index_to_remove,:) = [];
plotconfusion(target_compressed, output_compressed);
set(gca,'xticklabel',categories);
set(gca,'yticklabel',categories);

cm_all = confusionmat(target_all_number, output_all_number);
cm_compressed = confusionmat(target_compressed_number, output_compressed_number);

acc1 = trace(cm_all)/sum(sum(cm_all))*100;
accuracy = sprintf('Accuracy for UNIQUE classification: %0.1f', acc1);
disp(accuracy);

acc2 = trace(cm_compressed)/sum(sum(cm_compressed))*100;
accuracy = sprintf('Accuracy for MULTIPLE classification: %0.1f', acc2);
disp(accuracy);

end