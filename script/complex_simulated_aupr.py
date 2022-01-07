import os, sys, inspect, random
import numpy as np
import matplotlib.pyplot as plt
from time import time
from itertools import product
from scipy import stats, optimize
from datetime import timedelta as td
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# load the network analyzers from the parent folder.
current_file = inspect.getfile(inspect.currentframe())
current_dir = os.path.dirname(os.path.abspath(current_file))
parent_dir = os.path.dirname(current_dir)
out_dir = os.path.join(parent_dir+"_out","complex_simulated")
#===============================================================================
# configuration for comparing performance of different methods applied to
#   datasets obtained from network simulator.
def configuration():
    return {
        "nn": 1, # number of simulations to run.
        # "nn": 10, # number of simulations to run. 
        "hidden": [0], # ratio of nodes hidden in the table.
        "nodes": [500], # node number of the network.
        # "nodes": [100], # node number of the network.
        "samples": [100], # the number of samples.
        # "samples": [20,30,50,70,100,150,200], # the number of samples.
        "method": ['idirect', 'nd', 'gs', 'pc'],
        "network": ['band', 'clust', 'real'], # network type to consider.
        "out_dir": out_dir, # DIRECTORY for OUTPUT files.
    }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# calculate Pearson's correlation coefficients.
def read_reference(file):
    ref = {}
    with open(file, "r") as fh:
        for i,row in enumerate(fh):
            items = row.rstrip().split("\t")
            if len(items)!=3: print(items)
            ref["->".join(sorted(items[:2]))] = float(items[2])
    return ref
# read the solution in a file.
def read_solution(file):
    sol = []
    with open(file, "r") as fh:
        for i,row in enumerate(fh):
            items = row.rstrip().split("\t")
            if len(items)!=3: print(items)
            sol.append(("->".join(sorted(items[:2])), float(items[2])))
    return sorted(sol, key=lambda x: x[1], reverse=True)
# record the statistics of the solution.
def compare_solution(sol, ref):
    n_true = len(ref)
    n_total = len(sol)
    n_false = n_total - n_true
    values = []
    for key,weight in sol:
        values.append(key in ref)
    values = np.cumsum(np.array(values))
    nums = np.arange(1, n_total+1)
    precision = np.hstack((1, values/nums, 0))
    recall = np.hstack((0, values/n_true, 1))
    FPR = np.hstack((0, (nums - values)/n_false, 1))
    aupr = np.sum(recall[1:]*precision[:-1] - recall[:-1]*precision[1:])/2
    auroc = np.sum(FPR[1:]*recall[:-1] - FPR[:-1]*recall[1:])/2 + 1/2
    return aupr, auroc
################################################################################
# generate simulated data using network simulator, and compare the performance
#   of different methods based on their PR and ROC curves.
config = configuration()
nn,nodes,samples,network,hidden = (config[k] for k in ("nn","nodes","samples","network","hidden"))
if len(samples)==1:
    names = lambda x: os.path.join(config["out_dir"],\
            "{:s}/edges_topo={:s}_hid={:.2f}_node={:d}_#{:d}.txt".format(*x[:-2],x[-1]))
else:
    names = lambda x: os.path.join(config["out_dir"],\
            "{:s}/edges_topo={:s}_hid={:.2f}_node={:d}_samp={:d}_#{:d}.txt".format(*x))
results = {}
for ii,n,nsamp,inet,ihid in product(range(nn), nodes, samples, network, hidden):
    t0 = time() # record the starting time.
    ref = read_reference(names(("true", inet, ihid, n, nsamp, ii)))
    print(", ".join([str(ii), str(n), str(nsamp), inet, str(ihid)]))
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # record the results obtained from different methods.
    for imet in config["method"]: # iterate on methods.
        sol = read_solution(names((imet, inet, ihid, n, nsamp, ii)))
        aupr, auroc = compare_solution(sol, ref)
        if inet in results:
            if ihid in results[inet]:
                if n in results[inet][ihid]:
                    if nsamp in results[inet][ihid][n]:
                        if ii in results[inet][ihid][n][nsamp]:
                            if imet in results[inet][ihid][n][nsamp][ii]:
                                results[inet][ihid][n][nsamp][ii][imet] += [(aupr, auroc)]
                            else: results[inet][ihid][n][nsamp][ii][imet] = [(aupr, auroc)]
                        else: results[inet][ihid][n][nsamp][ii] = {imet: [(aupr, auroc)]}
                    else: results[inet][ihid][n][nsamp] = {ii: {imet: [(aupr, auroc)]}}
                else: results[inet][ihid][n] = {nsamp: {ii: {imet: [(aupr, auroc)]}}}
            else: results[inet][ihid] = {n: {nsamp: {ii: {imet: [(aupr, auroc)]}}}}
        else: results[inet] = {ihid: {n: {nsamp: {ii: {imet: [(aupr, auroc)]}}}}}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
file_name = os.path.join(config["out_dir"], "PR_ROC_stats.txt")
with open(file_name, "w") as fh:
    for inet in sorted(results.keys()):
        for ihid in sorted(results[inet].keys()):
            for n in sorted(results[inet][ihid].keys()):
                for nsamp in sorted(results[inet][ihid][n].keys()):
                    for ii in sorted(results[inet][ihid][n][nsamp].keys()):
                        for imet in sorted(results[inet][ihid][n][nsamp][ii].keys()):
                            stats = np.array(results[inet][ihid][n][nsamp][ii][imet])
                            stats=np.vstack((np.mean(stats,axis=0),np.std(stats,axis=0),stats))
                            fh.write("\t".join([inet, str(ihid), str(n), str(nsamp), str(ii), imet, "aupr"]+\
                                ["{:.8f}".format(k).rstrip('0').rstrip('.') for k in stats[:,0]])+"\n")
                            fh.write("\t".join([inet, str(ihid), str(n), str(nsamp), str(ii), imet, "auroc"]+\
                                ["{:.8f}".format(k).rstrip('0').rstrip('.') for k in stats[:,1]])+"\n")

plt.show()
