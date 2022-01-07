function net2=change_network_format(net)

% this function changes a network from a matric to a matrix of three
% colomns first colomn is the parents second is children and third is the
% weight

[n_tf,n]=size(net);

temp=(net>0)*1.0;
num_e=sum(sum(temp));

net_vec=net(1:end);
[~,I]=sort(net_vec,'descend');
edge_ind_sorted=zeros(2,length(I)); % it has two rows, sorted by weights

for i=1:length(I)
    [x,y]=index_to_pair(I(i),n_tf);
    edge_ind_sorted(1,i)=x;
    edge_ind_sorted(2,i)=y;
end


net2=zeros(num_e,3);
net2(:,1)=edge_ind_sorted(1,1:num_e);
net2(:,2)=edge_ind_sorted(2,1:num_e);
for i=1:num_e
    net2(i,3)=net(edge_ind_sorted(1,i),edge_ind_sorted(2,i));
end

