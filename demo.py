from time import time
import idirect as idir
import net_handler as nh
import net_simulator as ns
import file_handler as fh
t0 = time()

G,n = fh.read_file_weighted_edges("result/demo.txt", t0)
S,err = idir.direct_association(G, t0=t0)
S2 = nh.merge(G, S)
St = fh.save_sorted_turple(S2, in_file="result/demo.txt")
fh.save_file_weighted_edges(St, "result/demo_res.txt", t0=t0)
