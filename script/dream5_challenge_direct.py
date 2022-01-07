import os, sys, inspect
import numpy as np
from time import time
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# load the network analyzers from the parent folder.
current_file = inspect.getfile(inspect.currentframe())
current_dir = os.path.dirname(os.path.abspath(current_file))
parent_dir = os.path.dirname(current_dir)
out_dir = os.path.join(parent_dir.replace("iDIRECT","iDIRECT_out"),"dream5_challenge")
# out_dir = os.path.join(parent_dir.replace("iDIRECT","iDIRECT_out"),"dream5_challenge/rand")
sys.path.insert(0,parent_dir)
import idirect as idir
import net_handler as nh
import file_handler as fh
import net_simulator as ns

def transform_direct(keyword="", n_cores="1", method="barbar"):
    t0 = time()
    if "net1" in keyword: threshold = 5000
    elif "net3" in keyword: threshold = 3000
    elif "net4" in keyword: threshold = 1000
    print(" Keyword: "+keyword)
    print(" Core number: "+n_cores)
    print(" iDIRECT option: "+method)
    print(" Cutoff threshold: "+str(threshold))
    indir = os.path.join(out_dir,'trans')
    if method in ["appro", "block"]: # iDIRECT.
        outdir = os.path.join(out_dir,'idirect')
    elif method=="barbar": # brutal force version of iDIRECT.
        outdir = os.path.join(out_dir,'idirect')
    elif method=="cleanup": # partial correlation.
        outdir = os.path.join(out_dir,'pc')
    files = fh.find_input_file_names(keyword, indir)
    for file in files:
        print("Input file: "+file)
        G,n = fh.read_file_weighted_edges(file, t0, scale=0.99, opt="asym")
        para = {"dt":10, "n_cores":int(n_cores), "method":method, "opt":"asym"}
        S,err = idir.direct_association(G, th=threshold, t0=t0, **para)
        S2 = nh.merge(G, S, opt="asym")
        St = fh.save_sorted_turple(S2, in_file=file, opt="asym")
        out_file = fh.name_output_file(file, indir, outdir)
        print("Output file: "+out_file)
        fh.save_file_weighted_edges(St, out_file, t0)

if len(sys.argv)>1:
    transform_direct(*sys.argv[1:])
else: transform_direct("_net1")
