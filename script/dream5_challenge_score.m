clear all; close all;
clc; format long;
% determine the data location.
current_dir = pwd;
root_dir = strrep(current_dir, 'script', '');
data_dir = @(x) [strrep(root_dir,'iDIRECT','iDIRECT_out'), 'dream5_challenge/', x];
input_dir = [current_dir, '/INPUT/predictions/myteam'];
script_dir = [current_dir, '/matlab'];
%   Old, new, and current golden-standard files.
gs_old = [root_dir, 'result/dream5_challenge/DREAM5_net3_golden_std_old.tsv'];
gs_new = [root_dir, 'result/dream5_challenge/DREAM5_net3_golden_std_new.tsv'];
gs_weak = [root_dir, 'result/dream5_challenge/DREAM5_net3_golden_std_new_weak.tsv'];
gs_file = [current_dir, '/INPUT/gold_standard_edges_only/',...
    'DREAM5_NetworkInference_Edges_Network3.tsv'];
methods = {'raw', 'idirect', 'nd', 'gs', 'gs_author', 'pc'};
%==========================================================================
% read all the raw data from the directory. Use the codes provided by ND
%   and GS to calcualte the direct association matrix and save them.
ki=0;
results = cell(5,numel(methods)*36);
dirs = dir(data_dir('raw'));
for i = 1:numel(dirs)
    if ~strcmp(dirs(i).name, '.') && ~strcmp(dirs(i).name, '..')
        sub = dirs(i).name;
        for j = 1:numel(methods)
            met = methods{j};
            cd(root_dir);
            for k = [1,3,4]
                if strcmp(met,'idirect') || strcmp(met,'pc')
                    data_file = [data_dir(met),'/',sub,'/DREAM5_',sub,...
                        '_net',num2str(k),'_MI2.txt'];
                elseif strcmp(met,'nd') || numel(strfind(met,'gs'))>0
                    data_file = [data_dir(met),'/',sub,'/DREAM5_',sub,...
                        '_net',num2str(k),'.txt'];
                elseif strcmp(met,'raw')
                    data_file = [data_dir(met),'/',sub,'/DREAM5_Network',...
                        'Inference_',sub,'_Network',num2str(k),'.txt'];
                end
                input_file = [input_dir,'/DREAM5_NetworkInference_',...
                    'myteam_Network',num2str(k),'.txt'];
                copyfile(data_file, input_file);
            end
            % use old golden standard to evluate the submission.
            cd(script_dir);
            copyfile(gs_old, gs_file);
            go_all;
            tmp = -log10([P_AUPR, P_AUROC]);
            res_old = [AUPR,AUROC,tmp,(tmp(1:3)+tmp(4:6))/2,sum(tmp)/6];
            % use new golden standard to evluate the submission.
            copyfile(gs_new, gs_file);
            go_all;
            tmp = -log10([P_AUPR, P_AUROC]);
            res_new = [AUPR,AUROC,tmp,(tmp(1:3)+tmp(4:6))/2,sum(tmp)/6];
            % use new golden standard to evluate the submission.
            copyfile(gs_weak, gs_file);
            go_all;
            tmp = -log10([P_AUPR, P_AUROC]);
            res_weak = [AUPR,AUROC,tmp,(tmp(1:3)+tmp(4:6))/2,sum(tmp)/6];
            copyfile(gs_old, gs_file);
            %   Store the results.
            ki = ki + 1;
            results(:,ki) = {sub, met, res_old, res_new, res_weak};
            disp(data_file);
            disp(input_file);
        end
    end
end
%   Display the final solution.
fprintf(1,['Submission/ Method/ GS/ AUPR, #1/ AUPR, #3/ AUPR, #4/ AUROC,',...
    ' #1/ AUROC, #3/ AUROC, #4/ PR score, #1/ PR score, #3/ PR score, #4/',...
    ' ROC score, #1/ ROC score, #3/ ROC score, #4/ Score, #1/ Score, #3/',...
    ' Score, #4/ Final score\n']);
for i = 1:size(results, 2)
   fprintf(1,'%s\t%s\told_gs\t',results{1,i},results{2,i});
   fprintf(1,'%.8f\t',results{3,i});
   fprintf(1,'\n');
   fprintf(1,'%s\t%s\tnew_gs\t',results{1,i},results{2,i});
   fprintf(1,'%.8f\t',results{4,i});
   fprintf(1,'\n');
   fprintf(1,'%s\t%s\tweak_gs\t',results{1,i},results{2,i});
   fprintf(1,'%.8f\t',results{5,i});
   fprintf(1,'\n');
end