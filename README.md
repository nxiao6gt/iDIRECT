# iDIRECT - Inference of Direct and Indirect Relationships with Effective Copula-based Transitivity
Networks are vital tools for understanding and modeling interactions in complex 
systems in science and engineering, and direct and indirect interactions are 
pervasive in all types of networks. However, quantitatively disentangling direct 
and indirect relationships in networks remains a formidable task. Here, we 
present a framework, called iDIRECT (Inference of Direct and Indirect 
Relationships with Effective Copula-based Transitivity), for quantitatively 
inferring direct dependencies in association networks. Using copula-based 
transitivity, iDIRECT eliminates/ameliorates several challenging mathematical 
problems, including ill-conditioning, selflooping, and interaction strength 
overflow.

With simulation data as benchmark examples, iDIRECT showed high prediction 
accuracies. Application of iDIRECT to reconstruct gene regulatory networks in 
*Escherichia coli* also revealed considerably higher prediction power than the 
bestperforming approaches in the DREAM5 (Dialogue on Reverse Engineering 
Assessment and Methods project, #5) Network Inference Challenge. In addition, 
applying iDIRECT to highly diverse grassland soil microbial communities in 
response to climate warming showed that the iDIRECT-processed networks were 
significantly different from the original networks, with considerably fewer 
nodes, links, and connectivity, but higher relative modularity. Further analysis 
revealed that the iDIRECT-processed network was more complex under warming than 
the control and more robust to both random and target species removal (*P* < 
0.001).

As a general approach, iDIRECT has great advantages for network inference, and 
it should be widely applicable to infer direct relationships in association 
networks across diverse disciplines in science and engineering.

The full manuscript is available at <https://doi.org/10.1073/pnas.2109995119>. 
Please email <naijia.xiao@ou.edu> for questions regarding the program.

## Module Usage
The main functions for iDIRECT is included in the script `idirect.pyc`, with 
auxiliary functions in the scripts `file_handler.pyc` and `net_handler.pyc`. A 
demonstration script `demo.py` is included as a minimal example.

The modules can be imported by
```
import idirect as idir
import file_handler as fh
import net_handler as nh
```

For debugging purpose, the program starting time is recorded
```
from time import time
t0 = time()
```

The observed total association network is read from the file `result/demo.txt` 
as a list of weighted edges
```
G,n = fh.read_file_weighted_edges("result/demo.txt", t0)
```
The content of the file `result/demo.txt` is shown below
```
N1	N2	0.7
N2	N3	0.7
N1	N3	0.5
```
The observed total association network G is saved as a dictionary of 
dictionaries
```
>>> G
{'N1': {'N2': 0.7, 'N3': 0.5}, 'N2': {'N1': 0.7, 'N3': 0.7}, 'N3': {'N2': 0.7, 'N1': 0.5}}
```

Then iDIRECT is called to calculate the direct association network
```
S,err = idir.direct_association(G, t0=t0)
```
The direct association network S is also saved as a dictionary of dictionaries
```
>>> S
{'N1': {'N2': 0.6963451220087373, 'N3': 0.055394034573921835}, 'N2': {'N1': 0.6963451220087373, 'N3': 0.6963451220087373}, 'N3': {'N2': 0.6963451220087373, 'N1': 0.055394034573921835}}
```

The direct association network is merged with the total association network and 
the edges are extracted as a list of tuples containing the source, target, and 
weight of each edge
```
S2 = nh.merge(G, S)
St = fh.save_sorted_turple(S2, in_file="result/demo.txt")
```
The purpose is to retain the same number of edges as the original observed total 
network as required by the DREAM5 network inference challenge. For this demo 
example, it has no effect
```
>>> S2
{'N1': {'N2': 0.6963451220087373, 'N3': 0.055394034573921835}, 'N2': {'N1': 0.6963451220087373, 'N3': 0.6963451220087373}, 'N3': {'N2': 0.6963451220087373, 'N1': 0.055394034573921835}}
>>> St
[('N1', 'N2', 0.6963451220087373), ('N2', 'N3', 0.6963451220087373), ('N1', 'N3', 0.055394034573921835)]
```

Finally, the direct association network is saved in the file 
`result/demo_res.txt`
```
fh.save_file_weighted_edges(St, "result/demo_res.txt")
```
The content of the output file `result/demo_res.txt` is shown below
```
N1	N2	0.696345122
N2	N3	0.696345122
N1	N3	0.055394035
```

## Questions and Answers

### All my results are "nan". What happened? ###

A: This might be caused by one of your edges being 1. Please scale all your edges by a number smaller than 1.

### I received an error stating "ImportError: bad magic number in 'idirect': b'\x16\r\r\n'" when running iDIRECT. What happened? ###

A: The default `.pyc` files are compiled from Python 3.8.6. If your Python version
is different, please replace the default `.pyc` files with the corresponding
files from `versions/x.x/`, where `x.x` is your Python version number. For
example, if your Python version is 3.9.5, please copy `.pyc` files from
`versions/3.9/`. If your Python version is not available, please email
<naijia.xiao@ou.edu> to request an update.

### Does iDIRECT only deal positively correlated edges? What if I have negatively correlated edges? ###
A: Yes, it is recommended to use the absolute values before feeding them to iDIRECT. Then one can use the signs in the original matrix to determine the signs in the iDIRECT output.

A deeper cause of this behavior is that I chose to implement iDIRECT for unsigned values only. This is because it is difficult to implement iDIRECT for signed values. Suppose two nodes (A and B) are connected through C and D. If I implement iDIRECT with signed values, and suppose the association of path A-C-B is 0.9 and the association of path A-D-B is -0.9. This is highly unlikely in reality, but it almost certainly happens in practice. The resulting nonlinear S- and T-solvers in iDIRECT will perform poorly in this case. By implementing iDIRECT for unsigned values only, I do not need to deal with this unrealistic but difficult case.

### I have a large network to run and it is taking too long to finish. Are there any ways to reduce the running time? ###
A: For simple networks with few links, one can provide all links and run iDIRECT as in the demo example `demo.py`. For complex networks with many nodes, keeping all the links is both unnecessary and impractical, because one is not interested in the links with association strength below a certain cutoff threshold and the computation takes too much time. To address this problem, when calling the `direct_association` function from iDIRECT package, one can use the optional argument `th` to ignore links with low association strength. The rationale is that the link between two nodes is most probably caused by random association when their association strength is below a cutoff threshold, and the corresponding direct association strength should be zero. For example, to ignore links with total association strength < 0.6, use
```
S,err = idir.direct_association(G, th=0.6)
```
Then links with a total association strength < 0.6 will never be in the direct association network `S`. To ignore links whose association strength is not in the top 500, use
```
S,err = idir.direct_association(G, th=500)
```
Then links with a total association strength below the top 500 will never be in the direct association network `S`.

### If one of the direct association strength is a very small number, should I keep it as a direct edge or remove it? ###
A: In iDIRECT, direct links are interpreted as those with direct association strengths significantly (P < 0.05) different from background noises. Those background noises are estimated by computing the differences between the observed indirect association strengths and the iDIRECT-predicted indirect association strengths of random links below the RMT-determined cutoff. 

For example, consider a dataset with 100 OTUs. The total number of pairwise associations is 4,950. Suppose 500 of them are above the RMT cutoff and count as potential links. Let the corresponding total and direct association strength be $w_i$ and $v_i$ (i=1,2,...,500), respectively. Using $w_i$ and $v_i$ (i=1,2,...,500), I can calculate the indirect association strength for the remaining 4,450 association pairs. Let the corresponding total and indirect association strength be $w_i$ and $u_i$ (i=501,502,...,4950), respectively. The difference $v_i = |w_i \ominus u_i|$ (i=501,502,...,4950) can be used to estimate the background noise, where $\ominus$ is the inverse operator defined in Eq. (B2) in the supplement (page 21, above line 419). Then we can use the 5% quantile of $v_i$ (i=501,502,...,4950) as a cutoff, $v_{{th}}$. The top 500 links with $v_i < v_{{th}}$ are discarded, since their direct association strength is much smaller than the background noise. Because $v_{{th}}$ is usually smaller, one may even use $w_i$ instead of $v_i$ (i=501,502,...,4950) when determining $v_{{th}}$ to save computation time.

## Result Reproduction
Scripts used to generate the results in the manuscript are located in the 
`script` folder. Main results used by the scripts are located in the `result` 
folder. Due to the size limitation, other intermediate results are saved in a 
zipped data folder `iDIRECT_out` downloadable at 
<http://ieg4.rccc.ou.edu/publication/iDIRECT/iDIRECT_out.zip>. To use it, please download and 
decompress it to the same parent folder as the `iDIRECT` project folder. The 
overall folder layout should be
```
├─ iDIRECT
|  ├─ result
|  ├─ script
|  └─ ...
└─ iDIRECT_out
```

### Simulated networks ###
Simulated networks for assessing the performance of various network inference
methods, including iDIRECT, Network Deconvolution (ND), Global Silencing (GS),
and Partial Correlation (PC).

##### Figure 2. Performance of iDIRECT on simulated networks
The relevant script files are located in the `iDIRECT/script` folder. Their 
locations and functions are summarized below.

| File | Note |
| ---- | ---- |
| `complex_simulated_data.py` | Network simulation, iDIRECT and PC (partial correlation) solutions generation |
| `complex_simulated_ndgs.m` | ND (network deconvolution) and GS (global silencing) solutions generation |
| `complex_simulated_curve.py` | PR (precision-recall) curves calculation |
| `complex_simulated_aupr.py` | AUPR (area under precision-recall curves) calculation |

Some of the result files are saved in the `result/complex_simulated` folder. All 
the other result files are saved in the downloadable data folder `iDIRECT_out`. 
Their locations and functions are summarized below.

| Path | Note |
| ---- | ---- |
| `complex_simulated/raw` | Original networks containing indirect relationships |
| `complex_simulated/true` | Corresponding true links |
| `complex_simulated/idirect(nd,gs,pc)` | iDIRECT (ND/GS/PC) solutions |
| `complex_simulated/curves` | PR and ROC curves |
| `complex_simulated/PR_ROC_stats.txt` | AUPR and AUROC results |

##### Fig. S13. Area Under Precision-Recall curves (AUPR) for different network types
The procedure follows that of the Figure 2. Modifications on scripts 
`script/complex_simulated_data.py`, `script/complex_simulated_curve.py`, and 
`script/complex_simulated_aupr.py` are made to allow multiple network sizes. The 
plot is generated using `script/complex_simulated_aupr_plot.py`.

### DREAM5 challenge ###
Reconstruction of an *in silico* gene regulatory network and the genome-scale 
transcriptional regulatory network in *E. coli* from the DREAM5 Network 
Inference Challenge (<https://www.synapse.org/#!Synapse:syn2820440/wiki/>). The 
corresponding gene expression data for the *in silico* network was simulated 
using GeneNetWeaver (GNW) version 3.0 (<http://gnw.sourceforge.net/>). The 
*E. coli* gene regulatory network was reconstructed from chip-based gene 
expression data, respectively. 

The challenge organizers provided the scripts used to evaluate the performance
of submitted networks.
| Folder | Note |
| ------ | ---- |
| `script/matlab` | MATLAB scripts used to evaluate submitted networks |
| `script/INPUT` | Input folder containing gold standards and predicted edges |
| `script/OUTPUT` | Output folder storing network scores |

The scripts for ND and GS are also saved in the `script` folder.
| File/Folder | Note |
| ----------- | ---- |
| `script/ND.m` | Main function from ND for symmetric matrices |
| `script/ND_regulatory.txt` | Main function from ND for asymmetric matrices |
| `script/SILENCING.m` | Main function from GS |
| `script/ND_author` | Scripts provided by ND authors |
| `script/GS_author` | Scripts provided by GS authors including a wrapper script to run GS |

##### Figure 3. Regulatory networks from DREAM5 network inference challenge
The scripts used to generated iDIRECT, ND, and GS solutions are located in the
`script` folder. The locations and functions of them are summarized below.

| File | Note |
| ---- | ---- |
| `script/dream5_challenge_direct.py` | iDIRECT solution for each submission |
| `script/dream5_challenge_ndgs.m` | ND and GS solutions for each submission |
| `script/dream5_challenge_score.m` | Network score evaluation |
| `script/dream5_challenge_figtab.py` | Summary of the results |

The network scores and the precision-recall curves are saved in the 
`result/dream5_challenge` folder.

| File | Note |
| ---- | ---- |
| `result/dream5_challenge/score_all_sub.txt` | Network scores for different methods and submissions |
| `result/dream5_challenge/score_sub_part.txt` | Summary of the key network scores |
| `result/dream5_challenge/PR_curve_Other2.txt` | Precision-Recall curves for the best performer in *E. coli* network |

The reordered edges are saved in the `dream5_challenge` folders from the 
downloadable data folder `iDIRECT_out`.

| Folder | Note |
| ------ | ---- |
| `iDIRECT_out/dream5_challenge/raw` | Original edge list for each submission |
| `iDIRECT_out/dream5_challenge/trans` | Transformed edges for each submission |
| `iDIRECT_out/dream5_challenge/idirect(nd,gs_author)` | iDIRECT(or ND, or GS)-processed submissions |

##### Fig. S2. Improvement of community network score when only a subset of submissions were included
A subset of submissions are included to create partial community networks. These 
networks are scored using the scripts provided by DREAM5 challenge organizers. 
The locations and functions of relevant scripts are summarized below. 

| File | Note |
| ---- | ---- |
| `script/dream5_challenge_assem.py` | Community networks from random combination |
| `script/dream5_challenge_assem_score.m` | Network score evaluation |
| `script/dream5_challenge_assem_plot.m` | Display the results |

The randomized assembly networks are saved in folders from the downloadable data 
folder `iDIRECT_out`. A summary of all network scores is saved in 
`result/dream5_challenge/score_all_sub.txt`.
 
| Folder | Note |
| ------ | ---- |
| `iDIRECT_out/dream5_challenge/raw/Assembly` | Community networks from original submissions |
| `iDIRECT_out/dream5_challenge/idirect(nd,gs_author)/Assembly` | Community networks from iDIRECT(or ND, or GS)-processed submissions |

##### Fig. S3. Significance of the difference between the scores of the in silico network
Random networks are generated using random weight exchanges. Then they are 
scored using the scripts provided by DREAM5 challenge organizers. The locations 
and functions of relevant scripts are summarized below. 

| File | Note |
| ---- | ---- |
| `script/dream5_challenge_rand.py` | Random networks from random weight exchanges |
| `script/dream5_challenge_rand_score.m` | Random network score evaluation |
| `script/dream5_challenge_rand_comp.m` | Evaluation of the significance of the differences |

The randomized networks are saved in folders from the downloadable data folder 
`iDIRECT_out`. A summary of all network scores is saved in 
`result/dream5_challenge/score_rand.txt`.
 
| Folder | Note |
| ------ | ---- |
| `iDIRECT_out/dream5_challenge/rand/raw` | Random networks from original submissions |
| `iDIRECT_out/dream5_challenge/rand/idirect` | Random networks from iDIRECT-processed submissions |
| `iDIRECT_out/dream5_challenge/rand/nd` | Random networks from ND-processed submissions |
| `iDIRECT_out/dream5_challenge/rand/gs_author` | Random networks from GS-processed submissions |

### Soil microbial network ###
Molecular Ecological Networks (MENs) of soil microbial communities in response
to *in situ* experimental warming, as discussed in subsection
*Application to microbial community networks in response to warming* of the
**Results** section in the main text.

##### Figure 4. Soil microbial networks in response to experimental warming
The raw OTU tables and CLR-transformed (Centred Log-Ratio) OTU tables can be 
found in the `result/seasonal_warming` folder. Their functions are summarized 
below. The MENs are constructed using the Molecular Ecological Network Analysis 
Pipeline at <http://ieg4.rccc.ou.edu/MENA/>, which is publicly accessible.

| File | Note |
| ---- | ---- |
| `16S_OK5Y_warming.txt` | OTU table under warming treatment |
| `16S_OK5Y_control.txt` | OTU table under control treatment |
| `clr_16S_OK5Y_warming.txt` | CLR-transformed OTU table under warming treatment |
| `clr_16S_OK5Y_control.txt` | CLR-transformed OTU table under control treatment |

The resulting node and edge list files are saved in the 
`result/seasonal_warming` folder. Files with names containing '_new' contains 
information that are used for GePhi visualization (<https://gephi.org/>). 

| File | Note |
| ---- | ---- |
| `16S_OK5Y_warming 0.71 node(edge)_attribute.txt` | Nodal (or edge) attributes for the original network under warming treatment |
| `16S_OK5Y_warming 0.61 node(edge)_attribute.txt` | Nodal (or edge) attributes for the iDIRECT-processed network under warming treatment |
| `16S_OK5Y_control 0.71 node(edge)_attribute.txt` | Nodal (or edge) attributes for the original network under control treatment |
| `16S_OK5Y_control 0.61 node(edge)_attribute.txt` | Nodal (or edge) attributes for the iDIRECT-processed network under control treatment |

The proportions of simulated species extinction triggered by random species
removal and targeted species removal are collected in the
`result/seasonal_warming/knockout_vulner/simuresult` folder.
| File | Note |
| ---- | ---- |
| `simuresult_random_deletion.csv` | Simulated species extinction triggered by random species removal |
| `simuresult_target_deletion.csv` | Simulated species extinction triggered by targeted species removal |

##### Fig. S6. Degree distribution for microbial molecular ecological networks
The nodal properties can be found in the node list files in the 
`result/seasonal_warming` folder. The relevant column is "node.degree".

| File | Note |
| ---- | ---- |
| `16S_OK5Y_warming 0.71 node_attribute_new.txt` | Nodal attributes for the original network under warming treatment |
| `16S_OK5Y_warming 0.61 node_attribute_new.txt` | Nodal attributes for the iDIRECT-processed network under warming treatment |
| `16S_OK5Y_control 0.71 node_attribute_new.txt` | Nodal attributes for the original network under control treatment |
| `16S_OK5Y_control 0.61 node_attribute_new.txt` | Nodal attributes for the iDIRECT-processed network under control treatment |

##### Fig. S7. Module-level higher-order organizations of iDIRECT-processed networks
The plot was generated with MENAP (<http://ieg4.rccc.ou.edu/MENA/>), and the
accompanying files containing module separation results can be found in the
`result/seasonal_warming` folder.

| Folder | Note |
| ------ | ---- |
| `16S_OK5Y_warming ME_results 0.71` | Module separation for the original network under warming treatment |
| `16S_OK5Y_warming ME_results 0.61` | Module separation for the iDIRECT-processed network under warming treatment |
| `16S_OK5Y_control ME_results 0.71` | Module separation for the original network under control treatment |
| `16S_OK5Y_control ME_results 0.61` | Module separation for the iDIRECT-processed network under control treatment |

##### Fig. S8. Comparison of OTU topological roles under warming and control
The nodal properties can be found in the node list files in the
`result/seasonal_warming` folder. The relevant columns are "Zi", "Pi", and "Role".

| File | Note |
| ---- | ---- |
| `16S_OK5Y_warming 0.71 node_attribute_new.txt` | Nodal attributes for the original network under warming treatment |
| `16S_OK5Y_warming 0.61 node_attribute_new.txt` | Nodal attributes for the iDIRECT-processed network under warming treatment |
| `16S_OK5Y_control 0.71 node_attribute_new.txt` | Nodal attributes for the original network under control treatment |
| `16S_OK5Y_control 0.61 node_attribute_new.txt` | Nodal attributes for the iDIRECT-processed network under control treatment |

##### Fig. S9. Comparison of correlations between keystone OTUs abundance and soil, plant and ecosystem functioning variables
The raw OTU tables, CLR-transformed (Central Log-Ratio) OTU tables, the soil,
plant and ecosystem functioning variables, and the keystone OTUs can be found in 
the `result/seasonal_warming` folder. The script used to perform the calculation 
is `script/seasonal_env_keystone.py`.

| File | Note |
| ---- | ---- |
| `16S_OK5Y_warming.txt` | OTU table under warming treatment |
| `16S_OK5Y_control.txt` | OTU table under control treatment |
| `clr_16S_OK5Y_warming.txt` | CLR-transformed OTU table under warming treatment |
| `clr_16S_OK5Y_control.txt` | CLR-transformed OTU table under control treatment |
| `OK5Y_warming_EnvFac.txt` | Soil, plant, and ecosystem functioning variables under warming treatment |
| `OK5Y_control_EnvFac.txt` | Soil, plant, and ecosystem functioning variables under control treatment |
| `Keystone_OTUs.txt` | Keystone OTUs |

##### Fig. S10. Comparison of correlations between OTU significance and network properties
The OTU significance results and the nodal properties can be found in the
`result/seasonal_warming` folder. The script used to perform the calculation is
`script/seasonal_env_keystone.py`.

| File | Note |
| ---- | ---- |
| `16S_OK5Y_warming GS_1565125339.txt` | Gene significance results for networks under warming treatment |
| `16S_OK5Y_control GS_1565124793.txt` | Gene significance results for networks under control treatment |
| `16S_OK5Y_warming 0.71 node_attribute_new.txt` | Nodal attributes for the original network under warming treatment |
| `16S_OK5Y_warming 0.61 node_attribute_new.txt` | Nodal attributes for the iDIRECT-processed network under warming treatment |
| `16S_OK5Y_control 0.71 node_attribute_new.txt` | Nodal attributes for the original network under control treatment |
| `16S_OK5Y_control 0.61 node_attribute_new.txt` | Nodal attributes for the iDIRECT-processed network under control treatment |

##### Fig. S11. Robustness analysis of original and iDIRECT-processed networks
The script to run the robustness analysis is `script/seasonal_net_knockout.R`.
The input files can be found in the `result` folder and downloadable data folder
`iDIRECT_out`
| Folder | Note |
| ------ | ---- |
| `result/seasonal_warming/knockout_vulner/` | Simulated species extinction triggered by random species removal |
| `iDIRECT_out/seasonal_warming/knockout_vulner/` | Simulated species extinction triggered by targeted species removal |

The proportions of simulated species extinction triggered by random species
removal and targeted species removal are collected in the
`result/seasonal_warming/knockout_vulner/simuresult` folder.
| File | Note |
| ---- | ---- |
| `simuresult_random_deletion.csv` | Simulated species extinction triggered by random species removal |
| `simuresult_target_deletion.csv` | Simulated species extinction triggered by targeted species removal |

##### Table S2, S3, and S5. Topological properties of iDIRECT-processed and original networks
The results are saved in the `result/seasonal_warming` folder. The global
properties are saved in files `16S_OK5Y_*** *** global.prop.rep`.
| File/Folder | Note |
| ----------- | ---- |
| `16S_OK5Y_warming 0.71 global.prop.rep` | Topological properties for the original network under warming treatment |
| `16S_OK5Y_warming 0.61 global.prop.rep` | Topological properties for the iDIRECT-processed network under warming treatment |
| `16S_OK5Y_control 0.71 global.prop.rep` | Topological properties for the original network under control treatment |
| `16S_OK5Y_control 0.61 global.prop.rep` | Topological properties for the iDIRECT-processed network under control treatment |

The corresponding global properties of 100 random networks are saved as tab-
separated text files `summary.out` in the folders
`result/seasonal_warming/16S_OK5Y_*** random_network ***`.
| File/Folder | Note |
| ----------- | ---- |
| `16S_OK5Y_warming random_network 0.71` | Randomized original network under warming treatment |
| `16S_OK5Y_warming random_network 0.61` | Randomized iDIRECT-processed network under warming treatment |
| `16S_OK5Y_control random_network 0.71` | Randomized original network under control treatment |
| `16S_OK5Y_control random_network 0.61` | Randomized iDIRECT-processed network under control treatment |

##### Table S6. Module preservation between warming and control networks
The module separation was run with MENAP (<http://ieg4.rccc.ou.edu/MENA/>). The
results can be found in `result/seasonal_warming/16S_OK5Y_*** ME_results ***`.
| Folder | Note |
| ------ | ---- |
| `16S_OK5Y_warming ME_results 0.71` | Original network under warming treatment |
| `16S_OK5Y_warming ME_results 0.61` | iDIRECT-processed network under warming treatment |
| `16S_OK5Y_control ME_results 0.71` | Original network under control treatment |
| `16S_OK5Y_control ME_results 0.61` | iDIRECT-processed network under control treatment |

### Ill-conditioning matrix ###
The conditioning number of the total association matrix increases significantly
as the size of the network increases and the number of samples is fixed, as
discussed in Appendex A.2.

##### Fig. S1(a) Ill-conditioning of the association matrix
The eigenvalues of the corresponding matrices are stored in JSON as a text file
in `result/example_condit/ex_math_conditioning.txt`. The full matrices with
different size and association measures can be found as separate files in
the `example_condit` folder in the downloadable data folder `iDIRECT_out`.