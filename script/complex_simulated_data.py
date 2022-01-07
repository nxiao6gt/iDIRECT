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
sys.path.insert(0,parent_dir)
import idirect as idir
import net_handler as nh
import file_handler as fh
import net_simulator as ns
if len(sys.argv)>1:
    n0 = int(sys.argv[1])
else: n0 = 0
#===============================================================================
# configuration for comparing performance of different methods applied to
#   datasets obtained from network simulator.
def configuration():
    return {
        "nn": 1, # number of simulations to run.
        # "nn": 10, # number of simulations to run.
        "tol": 1e-4, # error tolerance in direct association algorithm.
        "iMax": 100, # maximum iteration count in direct association algorithm.
        "beta": 0.5, # scaling factor in other methods.
        "alpha": 0.2, # preferred network density in other methods.
        "gamma": 10, # number of random rewiring in cluster network.
        "shape": (2.5,0.7,0.9), # average degree and weight range.
        "hidden": [0], # ratio of nodes hidden in the table.
        "nodes": [500], # node number of the network.
        # "nodes": [100], # node number of the network.
        "samples": [100], # the number of samples.
        # "samples": [10,20,30,50,70,100,150,200], # the number of samples.
        "method": ['barbar', 'cleanup'],
        "network": ['band', 'clust', 'real'], # network type to consider.
        "out_dir": out_dir, # DIRECTORY for OUTPUT files.
        "dir_map": {"barbar": "idirect", "cleanup": "pc"},
    }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# calculate Pearson's correlation coefficients.
def corr(X):
    G, node = dict(), sorted(X.keys())
    for i in node:
        G[i] = dict()
        for j in node:
            if i<j: G[i][j] = np.corrcoef(X[i],X[j])[0,1]
            #if i<j: G[i][j] = abs(np.corrcoef(X[i],X[j])[0,1])
            elif i>j: G[i][j] = G[j][i]
    return G
# hide a fraction of the nodes.
def hide_node(G, a, hidden_keys=[]):
    if len(hidden_keys)==0:
        hidden_keys = random.sample(G.keys(), int(len(G)*a))
    Gc = dict()
    for i in G.keys():
        if i not in hidden_keys:
            Gc[i] = {j:G[i][j] for j in G[i].keys() if j not in hidden_keys}
    return Gc, hidden_keys
################################################################################
# generate simulated data using network simulator, and compare the performance
#   of different methods based on their PR and ROC curves.
config = configuration()
nn,beta,shape,nodes,samples,network,hidden = (config[k]\
    for k in ("nn","beta","shape","nodes","samples","network","hidden"))
if len(samples)==1:
    names = lambda x: os.path.join(config["out_dir"],\
            "{:s}/edges_topo={:s}_hid={:.2f}_node={:d}_#{:d}.txt".format(*x[:-2],x[-1]))
else:
    names = lambda x: os.path.join(config["out_dir"],\
            "{:s}/edges_topo={:s}_hid={:.2f}_node={:d}_samp={:d}_#{:d}.txt".format(*x))
for ii,n,nsamp,inet,ihid in product(range(n0,nn+n0), nodes, samples, network, hidden):
    t0 = time() # record the starting time.
    print('='*64) # undirected network of given topology type.
    G = ns.topology(int(n/(1-ihid)),shape[0],inet,shape[1:])
    Gd = ns.directed(G) # assign direction for each edge.
    X = ns.abund(Gd, n=nsamp, t0=t0) # relative abundance for each node.
    # hide a portion of the nodes.
    G, hidden_keys = hide_node(G, ihid)
    Gt = fh.save_sorted_turple(G)
    #if ihid!=0 or ii==0: # save the edges to a file.
    file = names(["true", inet, ihid, n, nsamp, ii])
    fh.save_file_weighted_edges(Gt, file, t0=t0)
    # calculate Pearson's correlation coefficients.
    Go = corr(X)
    Go, hidden_keys = hide_node(Go, ihid, hidden_keys) # hide nodes.
    Gt = fh.save_sorted_turple(Go)
    #if ihid!=0 or ii==0: # save the edges to a file.
    file = names(["raw", inet, ihid, n, nsamp, ii])
    fh.save_file_weighted_edges(Gt, file, t0=t0)
    print('- '*32+'\n  Testing different methods:')
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # record the results obtained from different methods.
    data = fh.save_sorted_turple(Go)
    th = abs(data[int(len(data)*config["alpha"])][2])
    for imet in config["method"]: # iterate on methods.
        print("prepare", time()-t0) # prepare dictionaries.
        keys = Go.keys() # nodes in the network.
        if imet in ['geo_pc','deconv','silence','cleanup']: # signed values.
            Gg = {i:{j:Go[i][j] for j in Go[i].keys()} for i in keys}
        else: # unsigned values, primarily for iDIRECT.
            Gg = {i:{j:abs(Go[i][j]) for j in Go[i].keys()} for i in keys}
        print("direct", time()-t0) # calculate the direct influences.
        if imet=='cleanup': # for cleanup, use beta=1.
            S=idir.direct_association(Gg,th,t0=t0,dt=10,method=imet,beta=1)[0]
        else: # other methods use provided beta.
            S=idir.direct_association(Gg,th,t0=t0,dt=10,method=imet,beta=beta)[0]
        print("merge", time()-t0) # merge the results with unchanged edges.
        S = nh.merge(Gg, S)
        print("save", time()-t0) # save direct network into a file.
        St = fh.save_sorted_turple(S)
        # save the edges to a file.
        #if ihid!=0 or ii==0:
        file = names([config["dir_map"][imet], inet, ihid, n, nsamp, ii])
        fh.save_file_weighted_edges(St, file, t0=t0)
        print("total", time()-t0) # record the total elapsed time.
