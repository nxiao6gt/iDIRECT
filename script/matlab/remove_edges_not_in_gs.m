function prediction_cleaned = remove_edges_not_in_gs(prediction,G)
%% prediction is the three column edge list
%% G is the gold graph with {1, -1} positive, negative

%% remove predictions that are not in the gold standard
prediction_cleaned = ones(size(prediction,1),3)*NaN;
regulators = unique(prediction(:,1));
targets = unique(prediction(:,1:2));
count = 0;
for k = 1:size(prediction,1)
	i = prediction(k,1);
	j = prediction(k,2);
	if (i <= size(G,1)) && (j <= size(G,2))
		%% in the range of the gold standard
		if G(i,j)
			%% actually in the gold standard
			count = count + 1;
			prediction_cleaned(count,:) = prediction(k,:);
		end
	end
end
%% prune the NaNs
idx = find(~isnan(prediction_cleaned(:,1)));
prediction_cleaned = prediction_cleaned(idx,:);
