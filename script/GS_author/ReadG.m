function [G, List] = ReadG(FileName, index)
clear G List;

if index == 1
    N = 1643; T = 195;
end
if index == 3
    N = 4511; T = 334;
end
if index == 4
    N = 5950; T = 333;
end

File = fopen(FileName);

i = 1;
List(T * N - T, 3) = 0;
Line = 'char';
while ischar(Line)
    Line = fgetl(File);
    c = 1;
    while c < size(Line,2)
        if strcmp(Line(c), 'G')
            Line(c) = [];
        end
        c = c + 1;
    end
    if ischar(Line)
        List(i,:) = str2num(Line);
        i = i + 1;
    end
end

L = size(List,1);
G(N,N) = 0;
for i = 1:L
    if List(i,1) && List(i,2)
        G(List(i,1), List(i,2)) = List(i,3);
    end
end
for i = 1:N
    G(i,i) = 1;
end

% IN SOME CASES G HAS NEGATIVE ENTERIES. WE RESCALE G SO ITS BETWEEN ZERO
% AND ONE.
Gmax = max(max(G));
Gmin = min(min(G));
G = (G - Gmin) / (Gmax - Gmin);

% WE MAKE THE G MATRIX SYMMETRIC (FOR THE ROWS ASSOCIATED WITH TFS)
for i = 1:T
    for j = 1:T
        if ~G(i,j)
            G(i,j) = G(j,i);
        end
    end
end
fclose('all');

