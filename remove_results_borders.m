cd 'Datasets/Dataset'
try
    delete('logist*', 'confusion_mat*', 'markers*')
catch err
    disp('Nothing removed in Resultados')
end
cd ..
cd ..
