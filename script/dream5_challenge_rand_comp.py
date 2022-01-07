import os, sys
import numpy as np
import pandas as pd
import seaborn as sns
from scipy.stats import ttest_rel,ttest_ind

file_name='../result/dream5_challenge/score_rand.txt'
scores=pd.read_csv(file_name,sep='\t',index_col=0)
scores.iloc[:,1:]=scores.iloc[:,:-1].values
scores.iloc[:,0]=scores.index
scores.index=np.arange(scores.shape[0])

func=lambda x: '_#' not in x['Filename'] and\
      ('net1' in x['Filename'] or 'Network1' in x['Filename'])
scores2=scores[scores.apply(func,axis=1)]
print(scores2.loc[:,['Filename','Method','Submission','PR score, #1']].\
      sort_values('Submission').to_string())

func=lambda x: '_#' in x['Filename'] and\
      ('net1' in x['Filename'] or 'Network1' in x['Filename'])
scores=scores[scores.apply(func,axis=1)]
##methods=[k for k in scores['Method'].unique()]
methods=['raw','idirect','nd','gs']
##submissions=[k for k in scores['Submission'].unique()]
submissions=['MI1','MI3','MI2','Correlation1','Correlation3','Other1',
    'Regression1','Meta1','Other2']
meth_mapping={'raw':'Original','idirect':'iDIRECT','nd':'ND',
              'gs':'GS','gs_author':'GS'}
sub_mapping={'MI1':'CLR','MI3':'ARACNE','MI2':'MI','Correlation1':'Pearson',
    'Correlation3':'Spearman','Other1':'GENIE3','Regression1':'TIGRESS',
    'Meta1':'Inferelator','Other2':'ANOVerence'}

data=[]
for sub in submissions:
    if sub in sub_mapping:
        for meth in methods:
            part=scores[(scores['Method']==meth)&(scores['Submission']==sub)]
            part_ref=scores2[(scores2['Method']==meth)&(scores2['Submission']==sub)]
            tmp=part['PR score, #1'].values
            tmp=tmp-np.mean(tmp)+part_ref['PR score, #1'].values[0]
            tmpp=[]
            for meth2 in methods:
                part2=scores[(scores['Method']==meth2)&(scores['Submission']==sub)]
                part2_ref=scores2[(scores2['Method']==meth2)&(scores2['Submission']==sub)]
                tmp2=part2['PR score, #1'].values
                tmp2=tmp2-np.mean(tmp2)+part2_ref['PR score, #1'].values[0]
##                t,p=ttest_rel(tmp,tmp2)
                t,p=ttest_ind(tmp,tmp2)
                tmpp.append(p)
            data.append([meth_mapping[meth],sub_mapping[sub],sub,
                part_ref['PR score, #1'].values[0],np.std(tmp)]+tmpp)
df=pd.DataFrame(data,columns=['Method','Submission','Name','Score','STD']+\
    ['P-Value vs. {}'.format(meth_mapping[k]) for k in methods])
print(df.to_string())
