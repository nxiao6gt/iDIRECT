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
        "network": ['band','clust','real'], # network type to consider.
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
    return precision, recall, FPR
# show the PR and ROC curves for each combination.
def plot_PR_ROC(fig, result):
    methods = sorted(result.keys())
    ax = fig.add_subplot(1,2,1)
    for met in methods:
        ax.plot(result[met][1], result[met][0])
    ax = fig.add_subplot(1,2,2)
    for met in methods:
        ax.plot(result[met][2], result[met][1])
    return
################################################################################
# generate simulated data using network simulator, and compare the performance
#   of different methods based on their PR and ROC curves.
config = configuration()
nodes,samples,network,hidden,nn = (config[k] for k in ("nodes","samples","network","hidden","nn"))
if len(samples)==1:
    names = lambda x: os.path.join(config["out_dir"],\
            "{:s}/edges_topo={:s}_hid={:.2f}_node={:d}_#{:d}.txt".format(*x[:-2],x[-1]))
else:
    names = lambda x: os.path.join(config["out_dir"],\
            "{:s}/edges_topo={:s}_hid={:.2f}_node={:d}_samp={:d}_#{:d}.txt".format(*x))
results = {}
for n,nsamp,inet,ihid,ii in product(nodes, samples, network, hidden, range(nn)):
    t0 = time() # record the starting time.
    ref = read_reference(names(("true", inet, ihid, n, nsamp, ii)))
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # record the results obtained from different methods.
    for imet in config["method"]: # iterate on methods.
        sol = read_solution(names((imet, inet, ihid, n, nsamp, ii)))
        precision, recall, FPR = compare_solution(sol, ref)
        if inet in results:
            if ihid in results[inet]:
                if n in results[inet][ihid]:
                    if nsamp in results[inet][ihid][n]:
                        if ii in results[inet][ihid][n][nsamp]:
                            results[inet][ihid][n][nsamp][ii][imet] = (precision, recall, FPR)
                        else: results[inet][ihid][n][nsamp][ii] = {imet: (precision, recall, FPR)}
                    else: results[inet][ihid][n][nsamp] = {ii: {imet: (precision, recall, FPR)}}
                else: results[inet][ihid][n] = {nsamp: {ii: {imet: (precision, recall, FPR)}}}
            else: results[inet][ihid] = {n: {nsamp: {ii: {imet: (precision, recall, FPR)}}}}
        else: results[inet] = {ihid: {n: {nsamp: {ii: {imet: (precision, recall, FPR)}}}}}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
file_name = os.path.join(config["out_dir"], "curves/PR_ROC_curves.txt")
# file_name = os.path.join(config["out_dir"], "curves/PR_ROC_curves2.txt")
'''with open(file_name, "w") as fh:
    for inet in sorted(results.keys()):
        for ihid in sorted(results[inet].keys()):
            for n in sorted(results[inet][ihid].keys()):
                #fig = plt.figure(figsize=(12,6))
                #plot_PR_ROC(fig, results[inet][ihid][n])
                for imet in sorted(results[inet][ihid][n].keys()):
                    prec, recall, FPR = results[inet][ihid][n][imet]
                    if len(prec)>1e4:
                        index = np.floor(np.arange(0,len(prec),int(len(prec)/1e4)))
                        prec = [prec[int(k)] for k in index]
                        recall = [recall[int(k)] for k in index]
                        FPR = [FPR[int(k)] for k in index]
                    fh.write("\t".join([inet, str(ihid), str(n), imet, "prec"]+\
                        ["{:.8f}".format(k).rstrip('0').rstrip('.') for k in prec])+"\n")
                    fh.write("\t".join([inet, str(ihid), str(n), imet, "recall"]+\
                        ["{:.8f}".format(k).rstrip('0').rstrip('.') for k in recall])+"\n")
                    fh.write("\t".join([inet, str(ihid), str(n), imet, "FPR"]+\
                        ["{:.8f}".format(k).rstrip('0').rstrip('.') for k in FPR])+"\n")'''
with open(file_name, "w") as fh:
    data,max_item=[],0
    for n in nodes:
        for nsamp in samples:
            for inet in network:
                for ihid in hidden:
                    for ii in range(nn):
                        for imet in config["method"]:
                            prec, recall, FPR = results[inet][ihid][n][nsamp][ii][imet]
                            if len(prec)>1e4:
                                index = np.floor(np.arange(0,len(prec),int(len(prec)/1e4)))
                                prec = [prec[int(k)] for k in index]
                                recall = [recall[int(k)] for k in index]
                                FPR = [FPR[int(k)] for k in index]
                            max_item=max(max_item,len(prec))
                            data.append([inet, str(ihid), str(n), str(nsamp), str(ii), imet, "prec"]+\
                                ["{:.8f}".format(k).rstrip('0').rstrip('.') for k in prec])
                            data.append([inet, str(ihid), str(n), str(nsamp), str(ii), imet, "recall"]+\
                                ["{:.8f}".format(k).rstrip('0').rstrip('.') for k in recall])
                            #data.append([inet, str(ihid), str(n), imet, "FPR"]+\
                            #    ["{:.8f}".format(k).rstrip('0').rstrip('.') for k in FPR])
    for i in range(max_item+5):
        row='\t'.join([(data[k][i] if i<len(data[k]) else '') for k in range(len(data))])+'\n'
        fh.write(row)
