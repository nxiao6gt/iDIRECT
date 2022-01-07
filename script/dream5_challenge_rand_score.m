clear all; close all;
clc; format long;
% determine the data location.
current_dir = pwd;
root_dir = strrep(current_dir, 'script', '');
data_dir = @(x) [strrep(root_dir,'iDIRECT','iDIRECT_out'),'dream5_challenge/rand/',x];
input_dir = [current_dir, '/INPUT/predictions/myteam'];
script_dir = [current_dir, '/matlab'];
methods = {'raw', 'idirect', 'nd', 'gs', 'gs_author'};
submissions = {'MI1','MI3','MI2','Correlation1','Correlation3','Other1',...
    'Regression1','Meta1','Other2'};
%==========================================================================
% read all the raw data from the directory. Use the codes provided by ND
%   and GS to calcualte the direct association matrix and save them.
ki=0;
results = cell(4,100);
for j = 1:numel(methods)
    met = methods{j};
    for sub = submissions
        files = dir([data_dir(met),'/',sub{1}]);
        for i = 1:numel(files)
            if ~strcmp(files(i).name, '.') && ~strcmp(files(i).name, '..')
                file = files(i).name;
                cd(root_dir);
                k = 1;
                input_file = [input_dir,'/DREAM5_NetworkInference_',...
                    'myteam_Network',num2str(k),'.txt'];
                data_file = [data_dir(met),'/',sub{1},'/',file];
                
                copyfile(data_file, input_file);
                % use old golden standard to evluate the submission.
                cd(script_dir);
                go_all;
                tmp = -log10([P_AUPR, P_AUROC]);
                res_old = [AUPR,AUROC,tmp,(tmp(1:3)+tmp(4:6))/2,sum(tmp)/6];
                %   Store the results.
                ki = ki + 1;
                results(:,ki) = {file, met, sub{1}, res_old};
                
                disp(data_file);
                disp(input_file);
            end
        end
    end
end

%   Display the final solution.
fprintf(1,['Filename\tMethod\tSubmission\tGS\tAUPR, #1\tAUPR, #3\tAUPR, #4\tAUROC,',...
    ' #1\tAUROC, #3\tAUROC, #4\tPR score, #1\tPR score, #3\tPR score, #4\t',...
    'ROC score, #1\tROC score, #3\tROC score, #4\tScore, #1\tScore, #3\t',...
    'Score, #4\tFinal score\n']);
for i = 1:size(results, 2)
   fprintf(1,'%s\t%s\t%s\told_gs\t',results{1,i},results{2,i},results{3,i});
   fprintf(1,'%.8f\t',results{4,i});
   fprintf(1,'\n');
end