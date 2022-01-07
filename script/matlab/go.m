% This script demonstrates how to call the function 
% DREAM5_Challenge4_Evaluation().
%
% Gustavo A. Stolovitzky, Ph.D.
% Adj. Assoc Prof of Biomed Informatics, Columbia Univ
% Mngr, Func Genomics & Sys Biology, IBM  Research
% P.O.Box 218 					Office :  (914) 945-1292
% Yorktown Heights, NY 10598 	Fax     :  (914) 945-4217
% http://www.research.ibm.com/people/g/gustavo
% http://domino.research.ibm.com/comm/research_projects.nsf/pages/fungen.index.html 
% gustavo@us.ibm.com
%
% Robert Prill, Ph.D.
% Postdoctoral Researcher
% Computational Biology Center, IBM Research
% P.O.Box 218
% Yorktown Heights, NY 10598 	
% Office :  914-945-1377
% https://researcher.ibm.com/researcher/view.php?person=us-rjprill
% rjprill@us.ibm.com

% clear all

%% gold standard edges only
goldfile = '../INPUT/gold_standard_edges_only/DREAM5_NetworkInference_Edges_Network1.tsv';

%% predicted edges
predictionfile = '../INPUT/predictions/myteam/DREAM5_NetworkInference_myteam_Network1.txt';

%% precomputed probability densities for various metrics
pdffile_aupr  = '../INPUT/probability_densities/Network1_AUPR.mat';
pdffile_auroc = '../INPUT/probability_densities/Network1_AUROC.mat';

%% load gold standard
gold_edges = load_dream_network(goldfile);

%% load predictions
prediction = load_dream_network(predictionfile);

%% load probability densities
pdf_aupr  = load(pdffile_aupr);
pdf_auroc = load(pdffile_auroc);

%% calculate performance metrics
[tpr fpr prec rec L auroc aupr p_auroc p_aupr] = DREAM5_Challenge4_Evaluation(gold_edges, prediction, pdf_aupr, pdf_auroc);

%% show plots
figure(1)
subplot(2,2,1)
plot(fpr,tpr)
title('ROC')
xlabel('FPR')
ylabel('TPR')
subplot(2,2,2)
plot(rec,prec)
title('P-R')
xlabel('Recall')
ylabel('Precision')

