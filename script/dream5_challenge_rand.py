import os
import random
import numpy as np
import pandas as pd
n=100

gs_file='INPUT/gold_standard_complete/DREAM5_NetworkInference_GoldStandard_Network1.tsv'
submissions=['MI1','MI3','MI2','Correlation1','Correlation3','Other1',
    'Regression1','Meta1','Other2']
methods=['gs','gs_author','raw','nd','idirect','trans']

def filename(meth,sub):
    if meth=='raw':
        name='DREAM5_NetworkInference_{}_Network1.txt'.format(sub)
    elif meth in ['gs','gs_author','nd']:
        name='DREAM5_{}_net1.txt'.format(sub)
    elif meth in ['idirect','trans']:
        name='DREAM5_{}_net1_MI2.txt'.format(sub)
    fullname='../../iDIRECT_out/dream5_challenge/rand/{}/{}/{}'.format(meth,sub,name)
    return fullname

def randomize(edges):
    new=edges.copy()
    index=edges[edges['GS']].index
    rand_index=np.arange(len(index))
    np.random.shuffle(rand_index)
    new.loc[index,'Weight']=new.loc[index,'Weight'].values[rand_index]
    new.loc[index,'Trans']=new.loc[index,'Trans'].values[rand_index]
    
    index=edges[~edges['GS']].index
    rand_index=np.arange(len(index))
    np.random.shuffle(rand_index)
    new.loc[index,'Weight']=new.loc[index,'Weight'].values[rand_index]
    new.loc[index,'Trans']=new.loc[index,'Trans'].values[rand_index]
    return new

func=lambda x: '{}->{}'.format(*sorted([x['Source'],x['Target']]))
gs=pd.read_csv(gs_file,sep='\t',index_col=None,header=None)
gs.columns=['Source','Target','GS']
gs=gs[gs['GS']==1]
gs['ID']=gs.apply(func,axis=1)
gs_ids=set(gs['ID'])

for sub in submissions:
    file=filename('raw',sub)
    edges=pd.read_csv(file,sep='\t',index_col=None,header=None)
    edges.columns=['Source','Target','Weight']
    edges['ID']=edges.apply(func,axis=1)
    edges['GS']=edges.apply(lambda x: x['ID'] in gs_ids,axis=1)
    edges=edges.sort_values('ID')

    trans_file=filename('trans',sub)
    trans_edges=pd.read_csv(trans_file,sep='\t',index_col=None,header=None)
    trans_edges.columns=['Source','Target','Weight']
    trans_edges['ID']=trans_edges.apply(func,axis=1)
    trans_edges=trans_edges.sort_values('ID')

    edges['Trans']=trans_edges['Weight'].values
    edges=edges[['Source','Target','Weight','Trans','GS']]

    print(file)
    for i in range(n):
        randomized=randomize(edges)
        new=randomized[['Source','Target','Weight']].\
             sort_values('Weight',ascending=False)
        new.to_csv(file.replace('.txt','_#{}.txt'.format(i)),
            sep='\t',index=False,header=False,float_format='%.6g')
        
        new=randomized[['Source','Target','Trans']].\
             sort_values('Trans',ascending=False)
        new.columns=['Source','Target','Weight']
        new.to_csv(trans_file.replace('.txt','_#{}.txt'.format(i)),
            sep='\t',index=False,header=False,float_format='%.6g')
