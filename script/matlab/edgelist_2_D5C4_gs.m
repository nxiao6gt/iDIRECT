function [gold_complete G] = edgelist_2_D5C4_gs(gold_positives)

regulators = unique(gold_positives(:,1));
targets = unique(gold_positives(:,1:2));

%% lookup matrix for positive edges
A = edgelist2sparse(gold_positives(:,1:2));

%% build gold standard matrix for positives (1) AND negatives (-1)
G = zeros(length(regulators),length(targets));
for k = 1:length(regulators)
	i = regulators(k);
	for l = 1:length(targets)
		j = targets(l);
		if A(i,j) 
			G(i,j) = 1;		%% Positive
		elseif i~=j			%% no self edges
			G(i,j) = -1;	%% Negative
		end
	end
end

%% complete gold standard edge list (positives and negatives)
edge_count = sum(sum(G~=0));
[I J] = find(G>0);	%% positives
[K L] = find(G<0);	%% negatives
gold_complete = [ I J ones(length(I),1) ; K L zeros(length(K),1) ];
