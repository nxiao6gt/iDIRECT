import os
import numpy as np

data_dir = "../../iDIRECT_out/dream5_challenge"
out_dir = "../result/dream5_challenge"
gs_dir = "../result/dream5_challenge"
methods = ["raw", "idirect", "nd", "gs", "gs_author"]
gold_std = ["old", "new", "new_weak"]
#cutoffs = [10, 30, 100, 300, 1000, 3000, 0.99, 0.98, 0.97, 0.96, 0.95]
cutoffs = [10, 20, 50, 100, 200, 500, 1000, 2000, 3000]
name_map = [
    ("CLR","MI1"), ("ARACNE","MI3"), ("MI","MI2"), ("Pearson","Correlation2"),\
    ("Spearman","Correlation3"), ("GENIE3","Other1"), ("TIGRESS","Regression1"),\
    ("Inferelator","Meta1"), ("ANOVerence","Other2"), ("Community","Community")]

records = {}
aliases = [k[1] for k in name_map]
file_name = os.path.join(out_dir, "score_all_sub.txt")
with open(file_name, "r") as fh:
    for i,row in enumerate(fh):
        items = row.rstrip().split("\t")
        if items[0] in aliases and len(items)==19:
            sub, met, gs = items[:3]
            scores = items[9], items[10], items[11], items[18]
            if sub in records:
                if met in records[sub]:
                    if gs in records[sub][met]:
                        print("Duplicates:", sub, met, gs, scores,\
                              records[sub][met][gs])
                    else: records[sub][met][gs] = scores
                else: records[sub][met] = {gs: scores}
            else: records[sub] = {met: {gs: scores}}

file_name = os.path.join(out_dir, "score_sub_part.txt")
with open(file_name, "w") as fh:
    for name,alias in name_map:
        for met in sorted(records[alias].keys()):
            scores = records[alias][met]["old_gs"]
            fh.write("\t".join((name, met)+scores)+"\n")

m=5000
strong_gs_file=gs_names('new')
weakp_gs_file=gs_names('new_weak+')
weak_gs_file=gs_names('new_weak')
gs_files=[strong_gs_file, weakp_gs_file, weak_gs_file]

subs=['Other2']
#subs=['Other2','Other1','Community']
for sub in subs:
    raw_file=data_dir+'/raw/'+sub+'/DREAM5_NetworkInference_'+sub+'_Network3.txt'
    idirect_file=data_dir+'/idirect/'+sub+'/DREAM5_'+sub+'_net3_MI2.txt'
    nd_file=data_dir+'/nd/'+sub+'/DREAM5_'+sub+'_net3.txt'
    gs_file=data_dir+'/gs_author/'+sub+'/DREAM5_'+sub+'_net3.txt'
    files=[raw_file, idirect_file, nd_file, gs_file]

    data=np.zeros((len(gs_files), m, len(files)*2))
    for i,gs_file in enumerate(gs_files):
        gs = {}
        with open(gs_file) as fh:
            for row in fh:
                items=row.strip().split()
                gs['->'.join(sorted(items[:2]))]=items[2]
        gs_len=len(gs)
        for k,file in enumerate(files):
            count=0
            with open(file) as fh:
                for j,row in enumerate(fh):
                    if j>=m: break
                    items=row.strip().split()
                    count+='->'.join(sorted(items[:2])) in gs
                    data[i,j,2*k]=count/gs_len
                    data[i,j,2*k+1]=count/(j+1)

    out_fh = open(os.path.join(out_dir, "PR_curve_"+sub+".txt"), "w")
    for i in range(data.shape[1]):
        for j in range(data.shape[0]):
            out_fh.write('\t'.join(['{:g}'.format(k) for k in data[j,i,:]])+'\t')
        out_fh.write('\n')
