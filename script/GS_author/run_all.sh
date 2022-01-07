#!/bin/bash
for i in `seq 1 36`; do
    sbatch run_all.bsh $i;
done
