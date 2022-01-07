function WriteG(FileName, G, n)

N = size(G,1);
for i = 1:N
    G(i,i) = 0;
end
T = size(find(sum(transpose(G))),2);
L = size(find(G),1);
List(L,3) = 0;

c = 1;
for i = 1:T
    for j = 1:N
        if G(i,j)
            List(c,:) = [i j G(i,j)];
            c = c + 1;
        end
    end
end

List = sortrows(List, -3);

File = fopen(FileName, 'w');
for i = 1:n
    Line = ['G' num2str(List(i,1)) '\t' 'G' num2str(List(i,2)) '\t' num2str(List(i,3)) '\n'];
    fprintf(File, Line);
end

