import os, sys
import numpy as np
import pandas as pd

n_run=20
n_assem=3

data_dir='../../iDIRECT_out/dream5_challenge/'

options=[k for k in os.listdir(data_dir) if os.path.isdir(data_dir+k)]
methods=[k for k in os.listdir(data_dir+'raw') if k[-1].isdigit()]
clusters=set([k[:-1] for k in methods])

def assem_networks():
    nets=[]
    for i in range(n_run):
        # choice=np.random.choice(methods,n_assem,p=weights,replace=False)
        choice=np.random.choice(methods,n_assem)
        nets.append([i]+list(choice))
    columns=['Run']+['Network{}'.format(i+1) for i in range(n_assem)]
    nets=pd.DataFrame(nets,columns=columns).set_index('Run')
    return nets


def find_res_path(sub, opt):
    if opt=="raw":
        file = "DREAM5_NetworkInference_"+sub+"_Network1.txt"
    elif opt in ["idirect", "trans"]:
        file = "DREAM5_"+sub+"_net1_MI2.txt"
    else: file = "DREAM5_"+sub+"_net1.txt"
    path = os.path.join(data_dir, opt, sub, file)
    return path

def find_assemble_path(n, opt):
    if opt=="raw":
        file = "DREAM5_NetworkInference_Assembly{}#{}_Network1.txt".format(n_assem,n)
    elif opt in ["idirect", "trans"]:
        file = "DREAM5_Assembly{}#{}_net1_MI2.txt".format(n_assem,n)
    else: file = "DREAM5_Assembly{}#{}_net1.txt".format(n_assem,n)
    path = os.path.join(data_dir, opt, 'Assembly', file)
    return path

def read_submission(submissions, opt, edge_type="rank"):
    rank = {"default": {}}
    for sub in submissions:
        # read each submisssion file.
        print(" Reading submission "+sub)
        res_file = find_res_path(sub, opt)
        with open(res_file, 'r') as fh:
            current_rank, value = 1, 1
            for i,row in enumerate(fh):
                row = row.replace('\n', '').split('\t')
                if len(row)==3:
                    # read each row.
                    # NOTE: Python sorting is different from DREAM5 default.
                    #key = "->".join(sorted(row[:2]))
                    key = "->".join(row[:2])
                    new_value = float(row[2])
                    if edge_type=="rank":
                        if new_value!=value:
                            current_rank = i+1
                            value = new_value
                    elif edge_type=="order":
                        current_rank = i+1
                    # the rank or weight of each edge.
                    if edge_type=="rank" or edge_type=="order":
                        if key not in rank:
                            rank[key] = {sub: current_rank}
                        elif sub not in rank[key]:
                            rank[key][sub] = current_rank
                        else: rank[key][sub] = (rank[key][sub] + current_rank)/2
                    elif edge_type=="weight":
                        rank[key] = {sub: new_value}
            # the default value for edges not listed in the file.
            current_rank = 100001
            if edge_type=="rank" or edge_type=="order":
                rank['default'][sub] = current_rank
            elif edge_type=="weight":
                rank['default'][sub] = 0
    return rank


nets=assem_networks()
for opt in options:
    for i,item in nets.iterrows():
        rank=read_submission(item.values,opt,edge_type="order")
        
        ave_rank = []
        print("  Retaining the top 100,000 edges")
        for key in rank.keys():
            tmp = []
            for sub in item.values:
                if sub in rank[key]:
                    tmp.append(rank[key][sub])
                else: tmp.append(rank['default'][sub])
            ave_rank.append((key, np.sum(tmp)))
        sorted_rank = sorted(ave_rank, key=lambda x: x[1])
        top_rank = sorted_rank[:100000]
        lowest_rank = 100001*len(item.values)
        
        assembled = find_assemble_path(i,opt)
        print("  Saving results into file:\n"+assembled)
        with open(assembled, 'w') as fh:
            for key,value in top_rank:
                keys = key.split('->')
                weight = 1 - value/lowest_rank
                fh.write('\t'.join(keys+['{:.8f}'.format(weight)])+'\n')

