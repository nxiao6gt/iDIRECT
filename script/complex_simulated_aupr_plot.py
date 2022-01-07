import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

file_name='../result/complex_simulated/PR_ROC_stats.txt'
names=['Type','#1','Runs','Size','#2','Method','Index','Value','V2','V3']
df=pd.read_csv(file_name,sep='\t',header=None,names=names)

fig=plt.figure(figsize=(15,5))
for i,ii in enumerate(df['Type'].unique()):
    ax=fig.add_subplot(1,3,i+1)
    part=df[(df['Type']==ii)&(df['Index']=='aupr')].sort_values('Method')
    best=pd.DataFrame(columns=part.columns)
    for col in part['Size'].unique():
        for j in part['#2'].unique():
            tmppp=part[(part['#2']==j)&(part['Size']==col)]
            best=best.append(tmppp)
    mapping={'gs':'GS','idirect':'iDIRECT','nd':'ND','pc':'PC'}
    best['Method']=best.apply(lambda x: mapping[x['Method']],axis=1)
    sns.barplot(data=best,x='Size',y='Value',hue='Method',dodge=True,alpha=0.9)
    ax.set_title('AUPR for {} Networks'.format(ii.capitalize()))
plt.tight_layout()
plt.show()
