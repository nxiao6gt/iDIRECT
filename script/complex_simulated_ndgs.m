clear all; close all;
clc; format long;
% determine the data location.
current_dir = pwd;
raw_dir = '../../iDIRECT_out/complex_simulated/raw/';
nd_dir = '../../iDIRECT_out/complex_simulated/nd/';
gs_dir = '../../iDIRECT_out/complex_simulated/gs/';
out_file = '../result/complex_simulated/time_nd_gs.txt';
%==========================================================================
% read all the raw data from the directory. Use the codes provided by ND
%   and GS to calcualte the direct association matrix and save them.
out_fh = fopen(out_file,'a');
files = dir(raw_dir);
for i = 1:numel(files)
    file = files(i);
    if strfind(file.name, 'edges_')
        fprintf(out_fh, ['Working on file: ',file.name,'\n']);
        % read the raw data as weighted edges.
        fh = fopen([raw_dir, file.name], 'r');
        edges = fscanf(fh, '%d%d%f', [3 Inf]);
        fclose(fh);
        % transform into total association matrix.
        G = eye(max(max(edges)));
        for j = 1:size(edges,2)
            G(edges(1,j), edges(2,j)) = edges(3,j);
            G(edges(2,j), edges(1,j)) = edges(3,j);
        end
        if exist([nd_dir, file.name], 'file')~=2
            % use code from ND to calculate direct association.
            tic;
            S = ND(G);
            fprintf(out_fh, 'Elapsed time is %.6f seconds.\n', toc);
            direct = edges;
            for j = 1:size(direct,2)
                direct(3,j) = (S(direct(1,j), direct(2,j)) +...
                               S(direct(2,j), direct(1,j)))/2;
            end
            % modify and reorder the edges.
            [weight, index] = sort(direct(3,:), 'descend');
            direct = [direct(1,index); direct(2,index); weight];
            % save the edges from ND.
            fh = fopen([nd_dir, file.name], 'w');
            fprintf(fh, '%d\t%d\t%.9f\n', direct);
            fclose(fh);
        end
        if exist([gs_dir, file.name], 'file')~=2
            % use code from GS to calculate direct association.
            tic;
            S = SILENCING(G);
            fprintf(out_fh, 'Elapsed time is %.6f seconds.\n', toc);
            direct = edges;
            for j = 1:size(direct,2)
                direct(3,j) = (S(direct(1,j), direct(2,j)) +...
                               S(direct(2,j), direct(1,j)))/2;
            end
            % modify and reorder the edges.
            [weight, index] = sort(direct(3,:), 'descend');
            direct = [direct(1,index); direct(2,index); weight];
            % save the edges from GS.
            fh = fopen([gs_dir, file.name], 'w');
            fprintf(fh, '%d\t%d\t%.9f\n', direct);
            fclose(fh);
        end
    end
end
fclose(out_fh);