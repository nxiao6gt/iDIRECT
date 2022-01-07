function mat_nd=ND_regulatory(mat,varargin)

% network deconvolution algorithm for gene regulatory networks of DREAM5
% challenge.
% Usage: mat_nd=ND_regulatory(mat,beta,alpha,control_p)
% INPUT ARGUMENTS:
% mat           Input matrix, it is a n_tf by n matrix where first n_tf genes are TFs.
%               Elements of the input matrix are nonnegative.
% optional parameters:
% beta          Scaling parameter, the program maps the largest absolute eigenvalue
%               of the direct dependency matrix to beta. It should be
%               between 0 and 1. You should skip this scaling step if you know eigenvalues
%               of your matrix satisfy ND conditions.
% alpha         fraction of edges of the observed dependency matrix to be kept in
%               deconvolution process.
% control_p     If set to one, it perturbs input networks slightly to have
%               stable results in case of non-diagonalizable matrices.
%               If zero, it checks some sufficient condition and then add a small perturbation
%               (this may be slower). Default is zero.

%
% OUTPUT ARGUMENTS:

% mat_nd        Output deconvolved matrix (direct dependency matrix). Its components
%               represent direct edge weights of observed interactions.
%               Choosing top direct interactions (a cut-off) depends on the application and
%               is not implemented in this code.

% In this implementation, input matrices are made symmetric.


% LICENSE: MIT-KELLIS LAB


% REFERENCES:
%    For more details, see the following paper:
%    Network Deconvolution as a General Method to Distinguish
%    Direct Dependencies over Networks
%    By: Soheil Feizi, Daniel Marbach,  Muriel MÃ©dard and Manolis Kellis
%    Nature Biotechnology
%


nVarargs = length(varargin);

if nVarargs==0
    % default parameters
    beta = 0.5;
    alpha = 0.1;
    control_p=0;
elseif nVarargs==1
    beta = varargin{1};
    if beta>=1 | beta<=0
        disp('error: beta should be in (0,1)');
    end
    alpha = 0.1;
    control_p=0;
elseif nVarargs==2
    control_p=0;
    beta = varargin{1};
    alpha = varargin{2};
    if beta>=1 | beta<=0
        disp('error: beta should be in (0,1)');
    end
    if alpha>1 | alpha<=0
        disp('error: alpha should be in (0,1]');
    end
elseif nVarargs==3
    
    beta = varargin{1};
    alpha = varargin{2};
    control_p = varargin{3};
    if beta>=1 | beta<=0
        disp('error: beta should be in (0,1)');
    end
    if alpha>1 | alpha<=0
        disp('error: alpha should be in (0,1]');
    end
else
    disp('error:too many input arguments')
end

%***********************************
% pre-processing the inut matrix
% linearly mapping the input matrix to be between 0 and 1
% to skip/add the linear re-scaling step, comment/uncomment the following step
% 
% if min(min(mat)) ~= max(max(mat))
%     mat = (mat-min(min(mat)))./(max(max(mat))-min(min(mat)));
% else
%     disp('the input matrix is a constant matrix')
% end

%**********************
% removing self-loops

[n_tf,n]=size(mat);
for i=1:n_tf
    mat(i,i)=0;
end

%**********************
% making the TF-TF network symmetric
% note some algorithms only output one-directional edges
% the other direction is added in that case

tf_net=mat(1:n_tf,1:n_tf);
[xx,yy]=find(tf_net~=tf_net');

tf_net_final=tf_net;
for i=1:length(xx)
    
    if tf_net(xx(i),yy(i))~=0 & tf_net(yy(i),xx(i))~=0
        tf_net_final(xx(i),yy(i))= (tf_net(xx(i),yy(i))+tf_net(yy(i),xx(i)))/2;
        tf_net_final(yy(i),xx(i))=tf_net_final(xx(i),yy(i));
    elseif tf_net(xx(i),yy(i))==0
        tf_net_final(xx(i),yy(i))= tf_net(yy(i),xx(i));
        tf_net_final(yy(i),xx(i))=tf_net_final(xx(i),yy(i));
    elseif tf_net(yy(i),xx(i))==0
        tf_net_final(xx(i),yy(i))= tf_net(xx(i),yy(i));
        tf_net_final(yy(i),xx(i))=tf_net_final(xx(i),yy(i));
    end
end

mat(1:n_tf,1:n_tf)=tf_net_final;

%**********************
% setting network density to alpha

y=quantile(mat(:),1-alpha);
mat_th=mat.*(mat>=y);

mat_th(1:n_tf,1:n_tf)=(mat_th(1:n_tf,1:n_tf)+mat_th(1:n_tf,1:n_tf)')/2;
temp_net=(mat_th>0)*1.0;
temp_net_remain=(mat_th==0)*1.0;
mat_th_remain=mat.*temp_net_remain;
m11=max(max(mat_th_remain));

%**********************
% check if matrix is diagonalizable

if control_p~=1
    % padding zero to make it a square matrix
    mat1=[mat_th;zeros(n-n_tf,n)];
    mat1=full(mat1);
    % decomposition step
    [U,D] = eig(mat1);
    if rcond(U)<10^-10
        control_p=1;
    end
end
%**********************
% if matrix is not diagonalizable,
% add random perturbation to make it diagonalizable
if control_p==1
    r_p=0.001;
    rng(1);% fixing rand seed
    rand_tf=r_p*rand(n_tf);
    rand_tf=(rand_tf+rand_tf')/2;
    for i=1:n_tf
        rand_tf(i,i)=0;
    end
    
    rand_target=r_p*rand(n_tf,n-n_tf);
    mat_rand=[rand_tf,rand_target];
    mat_th=mat_th+mat_rand;
    
    %******
    % padding zero to make it a square matrix
    mat1=[mat_th;zeros(n-n_tf,n)];
    mat1=full(mat1);
    %******
    % decomposition step
    [U,D] = eig(mat1);
end

%******
% scaling based on eigenvalues

lam_n=abs(min(min(diag(D)),0));
lam_p=abs(max(max(diag(D)),0));
%
m1=lam_p*(1-beta)/beta;
m2=lam_n*(1+beta)/beta;
scale_eigen=max(m1,m2);
% applying network deconvolution filter
for i=1:n
    D(i,i)=(D(i,i))/(scale_eigen+D(i,i));
end

net_new=U*D*inv(U);
%**********************
% adding remaining edges

net_new2=net_new(1:n_tf,:);
m2=min(min(net_new2));
net_new3=(net_new2+max(m11-m2,0)).*temp_net;
mat_nd=net_new3+mat_th_remain;



