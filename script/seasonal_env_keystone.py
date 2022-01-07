import os
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from scipy.stats import pearsonr,spearmanr

env_map={"NO3":"NO$_3^-$","NH4":"NH$_4^+$","TN":"TN","TC":"TOC","pH":"pH","moisture":"Moisture",
         "temperature_annual":"Temperature","FlC3":"C$_3$ Biomass","FlC4":"C$_4$ Biomass",
         "FlTotl":"Total Biomass","plant_richness":"Plant Richness","ER_annualmean":"ER",
         "GPP_annualmean":"GPP","NEE_annualmean":"NEE","Autotrophic":"R$_a$",
         "Heterotrophic":"R$_h$","total_soil_respiration":"R$_t$"}
# topo_map={"node.degree":"Degree","Zi":"Zi","Pi":"Pi"}
topo_map={'Degree':'Degree','Average neighbor degree':'Neigh. Degree',
          'Z-score (greedy modularity)':'Z$_i$','P-score (greedy modularity)':'P$_i$'}

data_dir='../result/seasonal_warming'
func=lambda x: os.path.join(data_dir,x)
control_otu=pd.read_csv(func('16S_OK5Y_control.txt'),sep='\t',index_col=0)
warming_otu=pd.read_csv(func('16S_OK5Y_warming.txt'),sep='\t',index_col=0)
##control_otu=pd.read_csv(func('clr_16S_OK5Y_control.txt'),sep='\t',index_col=0)
##warming_otu=pd.read_csv(func('clr_16S_OK5Y_warming.txt'),sep='\t',index_col=0)
control_env=pd.read_csv(func('OK5Y_control_EnvFac.txt'),sep='\t',index_col=0)
warming_env=pd.read_csv(func('OK5Y_warming_EnvFac.txt'),sep='\t',index_col=0)
keystones=pd.read_csv(func('Keystone_OTUs.txt'),sep='\t',index_col=0)

##control_node_dir=pd.read_csv(func('16S_OK5Y_control 0.61 node_attribute_new.txt'),sep='\t',index_col=0)
##warming_node_dir=pd.read_csv(func('16S_OK5Y_warming 0.61 node_attribute_new.txt'),sep='\t',index_col=0)
##control_node=pd.read_csv(func('16S_OK5Y_control 0.71 node_attribute_new.txt'),sep='\t',index_col=0)
##warming_node=pd.read_csv(func('16S_OK5Y_warming 0.71 node_attribute_new.txt'),sep='\t',index_col=0)
control_node_dir=pd.read_csv(func('16S_OK5Y_control 0.61 node_attribute.txt'),sep='\t',index_col=0)
warming_node_dir=pd.read_csv(func('16S_OK5Y_warming 0.61 node_attribute.txt'),sep='\t',index_col=0)
control_node=pd.read_csv(func('16S_OK5Y_control 0.71 node_attribute.txt'),sep='\t',index_col=0)
warming_node=pd.read_csv(func('16S_OK5Y_warming 0.71 node_attribute.txt'),sep='\t',index_col=0)
control_gs=pd.read_csv(func('16S_OK5Y_control GS_1565124793.txt'),sep='\t',index_col=0)
warming_gs=pd.read_csv(func('16S_OK5Y_warming GS_1565125339.txt'),sep='\t',index_col=0)

options=keystones.columns[-4:]
ind=control_env.columns.get_loc('total_soil_respiration')
envs=control_env.columns[:ind+1]
control_gs=control_gs[envs]
warming_gs=warming_gs[envs]
# ind=control_node_dir.columns.get_loc('Role')
# topos=[k for i,k in enumerate(control_node_dir.columns) if i<ind and k in topo_map]
##topos=[k for i,k in enumerate(control_node_dir.columns)]
##topo_map={k:(k[:10]+'...' if len(k)>=12 else k) for k in topos}
topos=[k for i,k in enumerate(control_node_dir.columns) if k in topo_map]
control_node_dir=control_node_dir[topos]
warming_node_dir=warming_node_dir[topos]
control_node=control_node[topos]
warming_node=warming_node[topos]

fig=plt.figure(figsize=(10,8))
gs=gridspec.GridSpec(2,2,width_ratios=[2.5,1])
rows=[]
for ii,opt in enumerate(options):
    ax=fig.add_subplot(gs[ii])
    otus=keystones[keystones[opt]=='Yes'].index
    if 'Control' in opt:
        table=control_otu.loc[otus,:].T
        table2=control_env.loc[:,envs]
    elif 'Warming' in opt:
        table=warming_otu.loc[otus,:].T
        table2=warming_env.loc[:,envs]
    #
    data,data2=[],[]
    for i in envs:
        data.append([])
        data2.append([])
        x=table2[i].values
        for j in otus:
            y=table[j].values
            ind=(~np.isnan(x))&(~np.isnan(y))
            r,p=pearsonr(x[ind],y[ind])
##            r,p=spearmanr(x[ind],y[ind])
            data[-1].append((r if p<=0.01 else np.nan))
            data2[-1].append(p)
    df=pd.DataFrame(data,index=[env_map[k] for k in envs],columns=otus)
    df2=pd.DataFrame(data2,index=[env_map[k] for k in envs],columns=otus)
##    sns.heatmap(data=df,vmin=-1,vmax=1,cmap='RdBu')
    sns.heatmap(data=df,cmap='RdBu')
    ax.set_facecolor((0.9,0.9,0.9))
    ax.set_title(opt)
    ax.set_xlabel('')
    plt.xticks(rotation=45,ha='right')
    total=df2.shape[0]*df2.shape[1]
    one_star=np.sum((df2<=0.05).values)
    two_star=np.sum((df2<=0.01).values)
    three_star=np.sum((df2<=0.001).values)
    rows.append([ii,opt,one_star,one_star/total,
        two_star,two_star/total,three_star,three_star/total])
df=pd.DataFrame(rows,columns=['#','Option','*','(%)','**','(%)','***','(%)'])
print(df)
plt.tight_layout()
plt.show()

fig=plt.figure(figsize=(6,4))
gs=gridspec.GridSpec(1,2)
rows=[]
for ii,opt in enumerate([options[0],options[2]]):
    ax=fig.add_subplot(gs[ii])
    if 'Control' in opt:
        if 'iDIRECT' in opt:
            table=control_node_dir
        elif 'Original' in opt:
            table=control_node
        table2=control_gs
    elif 'Warming' in opt:
        if 'iDIRECT' in opt:
            table=warming_node_dir
        elif 'Original' in opt:
            table=warming_node
        table2=warming_gs
    #
    data,data2=[],[]
    for i in envs:
        data.append([])
        data2.append([])
        for j in topos:
            x=table2.loc[table.index,i].values
            y=table[j].values
            ind=(~np.isnan(x))&(~np.isnan(y))
            r,p=pearsonr(x[ind],y[ind])
            data[-1].append((r if p<=0.01 else np.nan))
            data2[-1].append(p)
    df=pd.DataFrame(data,index=[env_map[k] for k in envs],columns=[topo_map[k] for k in topos])
    df2=pd.DataFrame(data2,index=[env_map[k] for k in envs],columns=[topo_map[k] for k in topos])
    sns.heatmap(data=df,cmap='RdBu')
    ax.set_facecolor((0.9,0.9,0.9))
    ax.set_title(opt)
    plt.xticks(rotation=30,ha='right')
    total=df2.shape[0]*df2.shape[1]
    one_star=np.sum((df2<=0.05).values)
    two_star=np.sum((df2<=0.01).values)
    three_star=np.sum((df2<=0.001).values)
    rows.append([ii,opt,one_star,one_star/total,
        two_star,two_star/total,three_star,three_star/total])
df=pd.DataFrame(rows,columns=['#','Option','*','(%)','**','(%)','***','(%)'])
print(df)
plt.tight_layout()
plt.show()
