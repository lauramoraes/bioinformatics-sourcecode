cd 'Resultados'
try
    delete 'confusion*'
%     rmdir('Round*','s')
    rmdir('1_*','s')
    rmdir('2_*','s')
    rmdir('3_*','s')
    rmdir('4_*','s')
    rmdir('5_*','s')
     rmdir('6_*','s')
     rmdir('7_*','s')
     rmdir('8_*','s')
     rmdir('9_*','s')
    rmdir('10_*','s')
catch err
    disp('Nothing removed in Resultados')
end
cd '../Resultados Node'
try
%     rmdir('Round*','s')
    rmdir('1_*','s')
    rmdir('2_*','s')
    rmdir('3_*','s')
    rmdir('4_*','s')
    rmdir('5_*','s')
     rmdir('6_*','s')
     rmdir('7_*','s')
     rmdir('8_*','s')
     rmdir('9_*','s')
    rmdir('10_*','s')
catch err
    disp('Nothing removed in Resultados Node')
end
cd '../Datasets'
try
%     rmdir('Round*','s')
    rmdir('1_*','s')
    rmdir('2_*','s')
    rmdir('3_*','s')
    rmdir('4_*','s')
    rmdir('5_*','s')
     rmdir('6_*','s')
     rmdir('7_*','s')
     rmdir('8_*','s')
     rmdir('9_*','s')
    rmdir('10_*','s')
catch err
    disp('Nothing removed in Datasets')
end
cd ..
