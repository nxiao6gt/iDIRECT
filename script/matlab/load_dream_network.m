function X = load_dream_network(file)
% this function strips-off the "G" characters from the gene identifiers

disp( ['Loading ' file] )
tic

d = importdata(file,'\t');

confidence = d.data;

A = d.textdata;	%% G1	G2
N = size(A,1);

%% strip off the first character (G), convert to double
B = char(A);
C = B';
D = C(2:end,:);
E = D';
F = str2num(E);
G = [ F(1:N) F(N+1:2*N) ];

%% append confidence to last col
X = [ G confidence ];

toc

