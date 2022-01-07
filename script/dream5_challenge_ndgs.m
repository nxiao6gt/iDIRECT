close all; clc;
%clear all; format long;
% determine the data location.
current_dir = pwd;
raw_dir = '../../iDIRECT_out/dream5_challenge/raw/';
nd_dir = '../../iDIRECT_out/dream5_challenge/nd/';
gs_dir = '../../iDIRECT_out/dream5_challenge/gs/';
% raw_dir = '../../iDIRECT_out/dream5_challenge/rand/raw/';
% nd_dir = '../../iDIRECT_out/dream5_challenge/rand/nd/';
% gs_dir = '../../iDIRECT_out/dream5_challenge/rand/gs/';
method = 'ndgs';
%==========================================================================
% read all the raw data from the directory. Use the codes provided by ND
%   and GS to calcualte the direct association matrix and save them.
dirs = dir(raw_dir);
for i = 1:numel(dirs)
    if ~strcmp(dirs(i).name, '.') && ~strcmp(dirs(i).name, '..') &&...
       (~exist('keyword','var') || ~isempty(strfind(dirs(i).name,keyword)))
        files = dir([raw_dir, dirs(i).name]);
        for j = 1:numel(files)
            file = files(j);
            if strfind(file.name, 'DREAM5_NetworkInference_')
                fprintf(1, ['Working on file: ',file.name,'\n']);
                new_file = strrep(file.name, 'NetworkInference_', '');
                new_file = strrep(new_file, 'Network', 'net');
                % read the raw data as weighted edges.
                fh = fopen([raw_dir, dirs(i).name, '/', file.name], 'r');
                edges = zeros(3,1e5);
                k = 0;
                tline = fgetl(fh);
                while ischar(tline)
                    k = k+1;
                    items = strsplit(tline);
                    source = str2double(items{1}(2:end))-1;
                    target = str2double(items{2}(2:end))-1;
                    edges(:,k) = [source; target; str2double(items{3})];
                    tline = fgetl(fh);
                end
                edges = edges(:,1:k);
                fclose(fh);
                % determine number of genes and tfs.
                if strfind(file.name, 'Network1')
                    ntf = 195;
                    ngene = 1643;
                elseif strfind(file.name, 'Network2')
                    ntf = 99;
                    ngene = 2810;
                elseif strfind(file.name, 'Network3')
                    ntf = 334;
                    ngene = 4511;
                elseif strfind(file.name, 'Network4')
                    ntf = 333;
                    ngene = 5950;
                end
                % transform into total association matrix.
                G = eye(ntf,ngene);
                for k = 1:size(edges,2)
                    G(edges(1,k)+1, edges(2,k)+1) = edges(3,k);
                    %G(edges(2,k)+1, edges(1,k)+1) = edges(3,k);
                end
                G = (G - min(min(G)))/(max(max(G)) - min(min(G)));
                if ~exist('method','var') || ~isempty(strfind(method,'nd'))
                    % use code from ND to calculate direct association.
                    S = ND_regulatory(G);
                    direct = edges;
                    for k = 1:size(direct,2)
                        %direct(3,k) = (S(direct(1,k)+1, direct(2,k)+1) +...
                        %               S(direct(2,k)+1, direct(1,k)+1))/2;
                        direct(3,k) = S(direct(1,k)+1, direct(2,k)+1);
                    end
                    % modify and reorder the edges.
                    [weight, index] = sort(direct(3,:), 'descend');
                    direct = [direct(1,index)+1; direct(2,index)+1; weight];
                    % save the edges from ND.
                    if ~exist([nd_dir, dirs(i).name], 'dir')
                        mkdir([nd_dir, dirs(i).name]);
                    end
                    fh = fopen([nd_dir, dirs(i).name, '/', new_file], 'w');
                    fprintf(fh, 'G%d\tG%d\t%.9f\n', direct);
                    fclose(fh);
                end
                % modify total association matrix.
                for ki = 1:ntf
                    for kj = 1:ntf
                        if ~G(ki,kj)
                            G(ki,kj) = G(kj,ki);
                        end
                    end
                end
                for ki = 1:ngene
                    G(ki,ki) = 1;
                end
                if ~exist('method','var') || ~isempty(strfind(method,'gs'))
                    % use code from GS to calculate direct association.
                    S = SILENCING(G);
                    direct = edges;
                    for k = 1:size(direct,2)
                        %direct(3,k) = (S(direct(1,k)+1, direct(2,k)+1) +...
                        %               S(direct(2,k)+1, direct(1,k)+1))/2;
                        direct(3,k) = S(direct(1,k)+1, direct(2,k)+1);
                    end
                    % modify and reorder the edges.
                    [weight, index] = sort(direct(3,:), 'descend');
                    direct = [direct(1,index)+1; direct(2,index)+1; weight];
                    % save the edges from GS.
                    if ~exist([nd_dir, dirs(i).name], 'dir')
                        mkdir([gs_dir, dirs(i).name]);
                    end
                    fh = fopen([gs_dir, dirs(i).name, '/', new_file], 'w');
                    fprintf(fh, 'G%d\tG%d\t%.9f\n', direct);
                    fclose(fh);
                end
            end
        end
    end
end