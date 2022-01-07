function SilenceAll(varargin)

Networks = [1,3,4];
Organisms{1} = 'In Silico';
Organisms{2} = 'S. cerevisiae';
Organisms{3} = 'E. coli';

Methods = directory_list('../../result/dream5_challenge/raw');
N = size(Methods,2);
n = 100000;

disp('Methods for Silencing:')
disp(Methods)
disp(char(10))

if numel(varargin)==1
    iter = varargin{1};
else
    iter = 1:N;
end

for i = iter
    for j = 1:3
        disp([char(10) 'Silencing G from Method ' num2str(i) ...
            ' (out of ' num2str(N) '): ' Methods{i} ...
            '; Organism: ' Organisms{j} char(10)])
   
        Input = ['../../result/dream5_challenge/raw/' Methods{i} ...
            '/DREAM5_NetworkInference_' Methods{i} ...
            '_Network' num2str(Networks(j)) '.txt'];
        [G] = ReadG(Input, Networks(j));
        disp(['Read G from file' char(10)])
        
        [S] = SILENCING(G);
        disp(['Silenced G.' char(10) 'Writing G and S to file...'])
        
        Output = ['../../result/dream5_challenge/gs_author/' Methods{i} ...
            '/DREAM5_' Methods{i} '_net' num2str(Networks(j)) '.txt'];
        WriteG(Output, S, n);
        disp('Done');
    end
end