import os, sys
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from matplotlib import cm

file_name='../result/dream5_challenge/score_all_sub.txt'
scores=pd.read_csv(file_name,sep='\t',index_col=0)
scores.iloc[:,1:]=scores.iloc[:,:-1].values
scores.iloc[:,0]=scores.index
scores.index=np.arange(scores.shape[0])

func=lambda x: 'Assembly' in x['Submission']
assembly=scores[scores.apply(func,axis=1)]
others=scores[~scores.apply(func,axis=1)]
methods=[k for k in assembly['Method'].unique() if k!='gs']
nsamples=[1,3,5,7,9,1e5]
meth_mapping={'raw':'Original','idirect':'iDIRECT','nd':'ND','gs':'GS','gs_author':'GS'}

data=[]
for n in nsamples:
    for meth in methods:
        if n==1:
            index=(others['GS']=='old_gs')&(others['Submission']!='Community')
            part=others[index&(others['Method']==meth)]
        elif n==1e5:
            index=others['Submission']=='Community'
            part=others[index&(others['Method']==meth)]
        else:
            func2=lambda x: 'Assembly{}'.format(n) in x['Submission']
            index=assembly.apply(func2,axis=1)
            part=assembly[index&(assembly['Method']==meth)]
        tmp=part['PR score, #1']
        data.append([n,meth]+list(tmp.quantile(np.linspace(0,1,5))))
        print(part,tmp)
df=pd.DataFrame(data,columns=['n','Method','Min','25\%','Median','75\%','Max'])

fig=plt.figure(figsize=(10,5))
ax=fig.add_subplot(111)
cmap=sns.color_palette()
for i,meth in enumerate(methods):
    for j,n in enumerate(nsamples):
        x=j+(i+1)/(len(methods)+1)-0.5
        dx=0.7/(len(methods)+1)
        color=cmap[i]
        part=df[(df['Method']==meth)&(df['n']==n)]
        if n==1e5:
            ax.bar(x,part['Median'],dx,
                color=color,edgecolor='k',alpha=0.7,label=meth_mapping[meth])
        else:
            ax.plot([x,x],[part['Min'],part['Max']],
                '--',color=color,linewidth=0.7)
            ax.plot([x-dx*0.4,x+dx*0.4],[part['Min'],part['Min']],'-',color=color)
            ax.plot([x-dx*0.4,x+dx*0.4],[part['Max'],part['Max']],'-',color=color)
            ax.bar(x,part['75\%']-part['25\%'],dx,part['25\%'],
                color=color,edgecolor='k',alpha=0.7)
            ax.plot([x-dx*0.5,x+dx*0.5],[part['Median'],part['Median']],
                '-',color=np.array(color)*0.7,linewidth=2)
ax.set_xlabel('Number of Integrated Networks')
ax.set_ylabel('PR score')
ax.set_xticks(np.arange(len(nsamples)))
ax.set_xticklabels([(str(k) if k<1e5 else 'All') for k in nsamples])
plt.legend()
plt.tight_layout()
plt.show()




