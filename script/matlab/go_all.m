% This script demonstrates how to score your own predictions.
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

NETWORKS = [1,3,4];
GOLDDIR = '../INPUT/gold_standard_edges_only/';
INDIR = '../INPUT/predictions/';
OUTDIR = '../OUTPUT/';

%% we require that the name of the team is provided as the name of the 
%% directory holding the prediction files
teams = directory_list(INDIR);
team = teams{1};
disp(['Evaluating predictions of team: ' team]);

%% for each Network
for ni = 1:length(NETWORKS)
%for ni = 1

	NETWORK = NETWORKS(ni);

	%% load gold standard
	goldfile = [ GOLDDIR 'DREAM5_NetworkInference_Edges_Network' num2str(NETWORK) '.tsv' ];
	gold_edges = load_dream_network(goldfile);

	%% load this team's predictions
	predictionfile = [ INDIR team '/DREAM5_NetworkInference_' team '_Network' num2str(NETWORK) '.txt' ];
	prediction = load_dream_network(predictionfile);

	%% load precomputed probability densities for various metrics
	pdffile_aupr  = ['../INPUT/probability_densities/Network' num2str(NETWORK)  '_AUPR.mat'];
	pdffile_auroc = ['../INPUT/probability_densities/Network' num2str(NETWORK) '_AUROC.mat'];
	pdf_aupr  = load(pdffile_aupr);
	pdf_auroc = load(pdffile_auroc);

	%% calculate performance metrics
	[tpr fpr prec rec l auroc aupr p_auroc p_aupr] = DREAM5_Challenge4_Evaluation(gold_edges, prediction, pdf_aupr, pdf_auroc);
	
	%% remember
	AUROC(ni) = auroc;
	AUPR(ni) = aupr;
	P_AUROC(ni) = p_auroc;
	P_AUPR(ni) = p_aupr;
	
end

%% scores
aupr_score  = -mean(log10(P_AUPR))
auroc_score = -mean(log10(P_AUROC))
overall_score = mean([aupr_score auroc_score])
-log10(P_AUPR)
-log10(P_AUROC)
[aupr_score, auroc_score, overall_score]

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% write results to text file
outfile = [ OUTDIR team '.txt' ];
fid = fopen(outfile, 'w');

fprintf(fid,'OVERALL_SCORE\t');
fprintf(fid,'AUPR_Score\t');
fprintf(fid,'AUROC_Score\n');
fprintf(fid,'%.3f\t%.3f\t%.3f\t\n\n',overall_score,aupr_score,auroc_score);

fprintf(fid, ['P_AUPR_Net' num2str(NETWORKS(1)) '\t']);
fprintf(fid, ['P_AUPR_Net' num2str(NETWORKS(2)) '\t']);
fprintf(fid, ['P_AUPR_Net' num2str(NETWORKS(3)) '\n']);
fprintf(fid,'%.3e\t%.3e\t%.3e\n\n',P_AUPR);

fprintf(fid, ['P_AUROC_Net' num2str(NETWORKS(1)) '\t']);
fprintf(fid, ['P_AUROC_Net' num2str(NETWORKS(2)) '\t']);
fprintf(fid, ['P_AUROC_Net' num2str(NETWORKS(3)) '\n']);
fprintf(fid,'%.3e\t%.3e\t%.3e\n\n',P_AUROC);

fprintf(fid, ['AUPR_Net' num2str(NETWORKS(1)) '\t']);
fprintf(fid, ['AUPR_Net' num2str(NETWORKS(2)) '\t']);
fprintf(fid, ['AUPR_Net' num2str(NETWORKS(3)) '\n']);
fprintf(fid,'%.3f\t%.3f\t%.3f\n\n',AUPR);

fprintf(fid, ['AUROC_Net' num2str(NETWORKS(1)) '\t']);
fprintf(fid, ['AUROC_Net' num2str(NETWORKS(2)) '\t']);
fprintf(fid, ['AUROC_Net' num2str(NETWORKS(3)) '\n']);
fprintf(fid,'%.3f\t%.3f\t%.3f\n',AUROC);

fclose(fid);

