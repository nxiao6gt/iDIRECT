% plotting ND performance results on DREAM5 regulatory networks
% 27-Feb 2014

clc
close all
%clear all


%********************
% reading setting from the user
%control_default=input(['Enter 0 or 1:\n',...
%'1: uses defaults and plots results (faster) \n',...
%'0: re-computes ND networks and plots results (slower) \n']);
control_default=1;

if (control_default~=0 && control_default~=1)
    disp('Error: incorrect inputs')
end


if control_default==0
    % 1: enables linear scaling, 0: disables linear scaling
    control_LS=1;
end


path_networks='networks/';
performance_before=zeros(3,10);
performance_after=zeros(3,10);


for control=[1,3,4]
    % control=1 corresponds to in silico network
    % control=3 corresponds to E. coli network
    % control=4 corresponds to S.cerevisiae network
    
    if control==1
        disp(['evalution of ND performance in silico network'])
    elseif control==3
        disp(['evalution of ND performance in E. coli network'])
    elseif control==4
        disp(['evalution of ND performance in S.cerevisiae network'])
    end
    
    %*************
    % load DREAM evalution scripts
    %goldfile = ['gold_standard_edges_only/DREAM5_NetworkInference_Edges_Network',num2str(control),'.tsv'];
    %pdffile_aupr  = ['probability_densities/Network',num2str(control),'_AUPR.mat'];
    %pdffile_auroc = ['probability_densities/Network',num2str(control),'_AUROC.mat'];
    %gold_edges = load_dream_network(goldfile);
    %pdf_aupr  = load(pdffile_aupr);
    %pdf_auroc = load(pdffile_auroc);
    
    %*************
    % loading input and output networks
    
    for control_net=[1:10]
        
        if control_net==1
            method_name='CLR';
        elseif control_net==2
            method_name='ARACNE';
        elseif control_net==3
            method_name='Relavance';
        elseif control_net==4
            method_name='Pearson';
        elseif control_net==5
            method_name='Spearman';
        elseif control_net==6
            method_name='GENIE3';
        elseif control_net==7
            method_name='TIGRESS';
        elseif control_net==8
            method_name='Inferelator1';
        elseif control_net==9
            method_name='ANOVerence';
        elseif control_net==10
            method_name='integrated';
        end
        
        %***********************
        % evalution of input network
        disp(['method name:',method_name])
        
        % input files are from DREAM5 challenge (see step 2).
        a=load([path_networks,'network_',num2str(control),'_',method_name,'.mat']);
        if control_net~=10
            input_network=a.input_network;
        else
            input_network=a.net_intg_inp;
        end
        
        %In DREAM challenge evaluation, only top 100K edges are considered.
        %prediction=change_network_format(threshold_mat(input_network,100000));
        %[tpr1 fpr1 prec1 rec1 L1 auroc1 aupr1 p_auroc1 p_aupr1] = DREAM5_Challenge4_Evaluation(gold_edges, prediction, pdf_aupr, pdf_auroc);
        %score_before_nd=(-log10(p_auroc1)-log10(p_aupr1))/2;
        
        %***********************
        
        if control_net~=10
            if control_default==1
                % loading ND networks (with control_LS=1)
                a=load([path_networks,'network_ND_',num2str(control),'_',method_name,'.mat']);
                output_network=a.output_network;
                
            elseif control_default==0
                % compute ND networks
                if control_LS==0
                    output_network=ND_regulatory(input_network);
                    
                elseif control_LS==1
                    input_network = (input_network-min(min(input_network)))./(max(max(input_network))-min(min(input_network)));
                    output_network=ND_regulatory(input_network);
                end
            end
        else
            % community network
            % the dream integration code is not in matlab format, I'll add its
            % matlab code in the future versions.
            a=load([path_networks,'network_ND_',num2str(control),'_',method_name,'.mat']);
            output_network=a.net_intg_out;
        end
        
        %***********************
        % evalution of output network
        
        %prediction=change_network_format(threshold_mat(output_network,100000));
        %[tpr1 fpr1 prec1 rec1 L1 auroc1 aupr1 p_auroc1 p_aupr1] = DREAM5_Challenge4_Evaluation(gold_edges, prediction, pdf_aupr, pdf_auroc);
        %score_after_nd=(-log10(p_auroc1)-log10(p_aupr1))/2;
        
        %if control==1
        %    performance_before(control,control_net)=score_before_nd;
        %    performance_after(control,control_net)=score_after_nd;
        %else
        %    performance_before(control-1,control_net)=score_before_nd;
        %    performance_after(control-1,control_net)=score_after_nd;
        %end
        
    end
end

%{
%*********************
% plotting the results before and after ND

% average results
tot_score=[mean(performance_before);mean(performance_after)];
% results in silico network
n1_score=[performance_before(1,:);performance_after(1,:)];
% results in E.coli network
n2_score=[performance_before(2,:);performance_after(2,:)];
% results in S.cerevisiae network
n3_score=[performance_before(3,:);performance_after(3,:)];


figure
subplot(411)
h=bar(tot_score');
legend('before ND','after ND')
set(h(1),'facecolor','b')
set(h(2),'facecolor','r')
ylabel({'Networks I,E,S','combined score'})

set(gca,'XTickLabel','CLR|ARACNE|MI|Pearson|Spearman|GENIE3|TIGRESS|Inferelator|ANOV|Community')

subplot(412)
h=bar(n1_score');
set(h(1),'facecolor','b')
set(h(2),'facecolor','r')
ylabel({'Network I', '(In silico)','score'})
set(gca,'XTickLabel','CLR|ARACNE|MI|Pearson|Spearman|GENIE3|TIGRESS|Inferelator|ANOV|Community')

subplot(413)
h=bar(n2_score');
set(h(1),'facecolor','b')
set(h(2),'facecolor','r')
ylabel({'Network E','(E.coli)','score'})
set(gca,'XTickLabel','CLR|ARACNE|MI|Pearson|Spearman|GENIE3|TIGRESS|Inferelator|ANOV|Community')

subplot(414)
h=bar(n3_score');
set(h(1),'facecolor','b')
set(h(2),'facecolor','r')
ylabel({'Network S','(S.cerevisiae)','score'})
set(gca,'XTickLabel','CLR|ARACNE|MI|Pearson|Spearman|GENIE3|TIGRESS|Inferelator|ANOV|Community')
%}


