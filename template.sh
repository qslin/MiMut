#!/bin/bash
#SBATCH --job-name=MiMut
#SBATCH -c 8
#SBATCH -n 1
#SBATCH -N 1
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-type=END
#SBATCH --mem=20G
#SBATCH --mail-user=qiaoshan.lin@uconn.edu
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err

sh ~/MiMut/MiMut.sh -r ~/LF10/LF10g_v2.0.fa -g ~/LF10/LF10g_v2.0.gtf -c ~/LF10/LF10g_v2.0.codingseq.fa -p ~/LF10/LF10g_v2.0.protein.fa -l ~/MiMut/LF10_lib.txt -f reads.txt

