function final_output = clean_multiple_output(output)
%% Clean output when more than one answer is possible
% Parameters:
% target: original classes (int)
% output: given answer (string, can be multiple classes in one answer)

final_output = {};
% For each output 
for i=1:length(output)
    output_clean = regexp(output(i),'\d+','match');
    
    % TEMP: desabilitando resultado das bordas enquanto não escolhe-se um
    % ponto de corte melhor
    %clean_output = str2num(output_clean{1,1}{1,1});

    % Remove repeated characters
    clean_output = unique(output_clean{1,1});
    clean_output = cellfun(@str2num,clean_output);
    
    final_output = vertcat(final_output, clean_output);
end 