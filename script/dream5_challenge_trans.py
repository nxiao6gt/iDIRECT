import os, inspect
import numpy as np
import matplotlib.pyplot as plt
from scipy import signal, interpolate
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# load the network analyzers from the parent folder.
current_file = inspect.getfile(inspect.currentframe())
current_dir = os.path.dirname(os.path.abspath(current_file))
parent_dir = os.path.dirname(current_dir)
out_dir = os.path.join(parent_dir.replace("iDIRECT","iDIRECT_out"),"result/dream5_challenge")

def all_networks():
    return ["1", "3", "4"]

def all_submissions():
    return [
        "Bayesian1","Bayesian2","Bayesian3","Bayesian4","Bayesian5","Bayesian6",
        "Community","Correlation1","Correlation2","Correlation3",
        "Meta1","Meta2","Meta3","Meta4","Meta5","MI1","MI2","MI3","MI4","MI5",
        "Other1","Other2","Other3","Other4","Other5","Other6","Other7","Other8",
        "Regression1","Regression2","Regression3","Regression4",
        "Regression5","Regression6","Regression7","Regression8",
    ]

def all_references():
    return [
        #"MI1", "MI2", "MI3", 
        "MI2",
    ]

def find_raw_path(submission, network):
    root = os.path.join(out_dir,"raw")
    file = "DREAM5_NetworkInference_"+submission+"_Network"+network+".txt"
    path = root+'/'+submission+'/'+file
    return path

def find_ref_path(reference, network):
    root = out_dir
    file = "dream5_corr_ref_net"+network+"_"+reference+".txt"
    path = root+'/'+file
    return path

def find_res_path(submission, network, reference):
    root = os.path.join(out_dir,"trans")
    file = "DREAM5_"+submission+"_net"+network+"_"+reference+".txt"
    path = root+'/'+submission+'/'+file
    return path

def sample_points(xin, yin, m=500, th=0.1):
    mid = sum(yin <= th)
    x = np.linspace(1, xin[mid], m)
    x1, y1, count = np.ones(m), np.zeros(m), 0
    for i in range(mid):
        if xin[i]<=x[count]:
            x1[count], y1[count] = xin[i], yin[i]
            count += 1
        if count==m: break

    y = np.linspace(yin[mid], 1, m)
    x2, y2, count = np.zeros(m), np.ones(m), 0
    for i in range(mid, len(yin)):
        if yin[i]>=y[count]:
            x2[count], y2[count] = xin[i], yin[i]
            count += 1

    x = np.hstack((x1, x2))
    y = np.hstack((y1, y2))
    return x, y

networks = all_networks()
references = all_references()
submissions = all_submissions()

record = {}
for net in networks:
    print('Network #'+net)
    reference = {}
    for ref in references:
        ref_file = find_ref_path(ref, net)
        x, y = [], []
        with open(ref_file, 'r') as fh:
            for i,row in enumerate(fh):
                row = row.replace('\n', '').split('\t')
                x.append(float(row[0]))
                y.append(float(row[1]))
        reference[ref] = (x, y)
        
    record[net] = {}
    for sub in submissions:
        print(' Submission '+sub)
        raw_file = find_raw_path(sub, net)
        weight, edges = [], []
        with open(raw_file, 'r') as fh:
            for i,row in enumerate(fh):
                row = row.replace('\n', '').split('\t')
                w = float(row[2])
                if i==0: max_w = w;
                weight.append(w/max_w)
                edges.append(row[:2])

        weight, n = np.array(weight), len(weight)
        reweighted = np.zeros(weight.shape)
        count, w = 0, weight[0]
        for i in range(n):
            if weight[i]<w:
                scale = (w-weight[i])/(i-count)
                reweighted[count:i] = w - np.arange(i-count)*scale
                count, w = i, weight[i]
        
        prob = np.arange(n)/n
        x, y = sample_points(reweighted, prob)
        interp = interpolate.interp1d(x, y)
        #prob_new = interp(reweighted)
        try: prob_new = interp(weight)
        except ValueError: prob_new = prob
        
        record[net][sub] = {}
        for ref in references:
            print('  Reference '+ref)
            xr, yr = reference[ref]
            interp_inv = interpolate.interp1d(yr, xr)
            weight_new = interp_inv(prob_new)
            record[net][sub][ref] = (weight_new, prob_new)
            
            res_file = find_res_path(sub, net, ref)
            with open(res_file, 'w') as fh:
                for w,edge in zip(weight_new, edges):
                    fh.write('\t'.join(edge + ['{:.8f}'.format(w)])+'\n')
