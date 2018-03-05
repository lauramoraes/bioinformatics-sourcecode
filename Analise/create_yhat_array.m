function yhat_array = create_yhat_array(classifications)
%% Get y_hat from classification struct array and transform it into a single array
% Parameters:
% classification: classification struct array

yhat_array = [];
for i=1:size(classifications,1)
    yhat_array = horzcat(yhat_array, classifications(i).y_hat);
end
    