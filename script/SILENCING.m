function [S] = SILENCING(G)
clear S;

% SILENCING CODE:
% 
% CITATION: 
%   Network link prediction by global silencing of indirect correlations
%   Baruch Barzel & Albert-Laszlo Barabasi
%   Nature Biotechnology 31, 720-725 (2013) doi:10.1038/nbt.2601
% 
% CODE DESCRIPTION:
% 
% Input: G is a square correlation matrix with diagonal Gii = 1.
% Output: S is the silenced direct dependency matrix. Sii = 0. 
% 
% DESCRIPTION OF THE ALGORITHM:
% 
% Step 1 - PREPROCESSING
% 
%   Checking the singularity of G. If G is singular its off-diagonal terms are
%   renormalized by a factor of Norm (Default: Norm = 0.5).
% 
% Step 2 - SILENCING
% 
%   S is obtained through the silencing transformation
% 
% %        S = Go * inv(G)
% 
%   where Go = G - I + D((G - I)*G).
%   We then obtain the eigenvalues of S (Ls) and test it for 
% 
% %        Max(abs(Ls)) < 1.
% 
%   If S does not follow this condition we renormalize the off-diagonal terms of G
%   until the condition is fulfilled.
%   Below we set the condition to 0.5 < Max(abs(Ls)) < 0.9
%   (Could be set to any valued between 0 and 1)
% 
% Step 3 - POSTPROCESSING
% 
%   Setting diagonal of S to Sii = 0.
%   Setting S to be all positives.
%   Setting maximum value of S to max(S) = 1.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% 
% STEP 1: %
%%%%%%%%%%% 

display(['-> ' 'Preprocessing. Checking singularity of G']);

N = size(G,1);
R = rank(G);
Go = G - eye(N);
Norm = 0.5; % This variable is set to 0.5 by default. May be any value 0 < Norm < 1.
R = N;
if R < N
    display(['---> ' 'G matrix is singular - renormalizing off-diagonal terms'])
    Go = Go * Norm;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% 
% STEP 2: %
%%%%%%%%%%% 

display(['-> ' 'Silencing. Shhh...'])

MaxValue = 2;
n = 1;
Maximum = 0.9;  % We set eigenvalues of S to between 0.5 and 0.9. May be set 
Minimum = 0.5;  % to any value between 0 and 1, and Maximum > Minimum
alpha = 1;      % alpha = the final normalizing factor Go ---> alpha * Go
while (MaxValue <= Minimum || MaxValue >= Maximum)
    G1 = Go + eye(N);

    display(['---> ' 'Preforming the transformation. Iteration number: ' num2str(n)])

    display(['---> ' 'Calculating the diagonal terms of D((G-I)G)'])
    D = Go * G1;
    for i = 1:N
        for j = i + 1:N
            D(i,j) = 0;
            D(j,i) = 0;
        end
    end
    MaxDiag = max(max(abs(D)));
    display(['---> ' 'Maximum of Digonal is Dmax = ' num2str(MaxDiag)])
    
    S = (Go + D) * inv(G1);
    
    display(['---> ' 'Obtaining spectrum of S.'])
    
    [Q Ls] = eig(S);
    Ls = diag(Ls);
    MaxValue = max(abs(Ls));
    
    display(['---> ' 'Maximum eigenvalue of S is Ls = ' num2str(MaxValue)])
    
    if (MaxValue > Minimum && MaxValue < Maximum) 
        display(['---> ' 'Silencing done. Off-diagonal terms of G were renormalized by alpha = ' num2str(alpha)])
    else
        % We renormalize off-diagonal terms. The greater is the difference
        % between MaxValue and the desired range, the smaller is Norm
        Norm = 1 / (sqrt(MaxValue / (0.5 * (Maximum + Minimum))));
        display(['---> ' 'Renormalizing G for next iteration. Norm = ' num2str(Norm)])
        Go = Go * Norm;
        alpha = alpha * Norm;
    end
    n = n + 1;
end
%diag(D)
alpha
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% 
% STEP 3: %
%%%%%%%%%%% 

display(['-> Postprocessing']);

for i = 1:N
    S(i,i) = 0;
end

%S = abs(S)/max(max(abs(S)));
Smax = max(max(S));
Smin = min(min(S));
S = (S - Smin) / (Smax - Smin);


