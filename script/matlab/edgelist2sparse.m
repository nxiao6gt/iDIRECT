function A = edgelist2sparse(E)

% lone nodes look like this:
% 1  NaN
% 2  NaN

% throw-out lone nodes
E = E(~isnan(E(:,2)),:);

I = E(:,1);
J = E(:,2);
B = sparse(I,J,1);

padding = max(size(B)) - size(B);

if sum(padding) == 0
  A = B;
else
  if padding(1) == 0
    padding(1) = max(size(B));
    A = [B zeros(padding)];
  elseif padding(2) == 0
    padding(2) = max(size(B));
    A = [B ; zeros(padding)];
  end
end


