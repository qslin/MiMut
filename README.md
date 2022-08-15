# MiMut: mutant identification in *Mimulus lewisii* complex

## Table of contents

1. [Introduction of MiMut](https://github.com/qslin/MiMut#introduction-of-MiMut)
2. [The primary workflow of MiMut](https://github.com/qslin/MiMut#the-primary-workflow-of-mimut)
3. [The secondary workflow of MiMut (e.g. using SL9 and LF10 inbred lines)](https://github.com/qslin/MiMut#the-secondary-workflow-of-mimut-eg-using-sl9-and-lf10-inbred-lines)
4. [User guide step by step](https://github.com/qslin/MiMut#user-guide-step-by-step)
5. [Frequently asked questions](https://github.com/qslin/MiMut#frequently-asked-questions)

## Introduction of MiMut

MiMut was designed for easy identification of *Mimulus* mutants. 

## The primary workflow of MiMut

![Figure_1](https://github.com/qslin/MiMut/blob/main/figures/Figure1.png?raw=true)

## The secondary workflow of MiMut (e.g. using SL9 and LF10 inbred lines)

![Figure_2](https://github.com/qslin/MiMut/blob/main/figures/Figure2.png?raw=true)

## User guide step by step

### For the primary workflow

1. Install Miniconda3 following the [instructions](https://docs.conda.io/projects/conda/en/latest/user-guide/install/linux.html)
2. Download MiMut to your server:
`git clone https://github.com/qslin/MiMut.git`
3. Create MiMut environment:
`conda env create -f MiMut/MiMut.yaml`
4. Activate the environment:
`conda activate MiMut`
5. Prepare genome(s) and annotation files (including CDS sequences, protein sequences, and a GTF file). 
If you don't have them locally, please download from [Mimubase](http://mimubase.org/FTP/Genomes/). Creating a new folder for each species is recommended. For example: 
```
mkdir MvBL
cd MvBL
wget http://mimubase.org/FTP/Genomes/MvBLg_v2.0/MvBLg_v2.0.fa
wget http://mimubase.org/FTP/Genomes/MvBLg_v2.0/MvBLg_v2.0.coding.fa
wget http://mimubase.org/FTP/Genomes/MvBLg_v2.0/MvBLg_v2.0.gtf
wget http://mimubase.org/FTP/Genomes/MvBLg_v2.0/MvBLg_v2.0.protein.fa
cd ..
```
6. Set up the mutant library. Currently there are two mutant libraries curated in MiMut: `LF10_lib.txt` and `MvBL_lib.txt`. These are the latest collection of homozygous SNPs detected from mutants of *Mimulus lewisii* inbred line LF10 and *Mimulus verbenaceus* inbred line MvBL respectively. To use the libraries, please provide their paths such as `~/MiMut/LF10_lib.txt`

If you are re-analyzing an old sample, please make sure to remove the sample from the library before running MiMut. For example: you are going to re-analyze an old sample called *bagua*. First, check if *bagua* is in the library: `cat MiMut/LF10_lib.txt`. All mutants in the library will be printed: 
```
mutant_snps/Trumpet1/snp3.vcf
mutant_snps/boo3/snp3.vcf
mutant_snps/bagua/snp3.vcf
mutant_snps/flayed1/snp3.vcf
mutant_snps/flayed2/snp3.vcf
mutant_snps/flayed5/snp3.vcf
mutant_snps/flayed6/snp3.vcf
mutant_snps/flayed7/snp3.vcf
mutant_snps/Ml14181/snp3.vcf
mutant_snps/MlYL/snp3.vcf
mutant_snps/NT2/snp3.vcf
mutant_snps/PIN1/snp3.vcf
mutant_snps/ROI2/snp3.vcf
mutant_snps/Wastonia/snp3.vcf
```
We need to remove *bagua* on the third line and create a new library for running MiMut:
```
grep -v 'bagua' MiMut/LF10_lib.txt > MiMut/LF10_lib_no_bagua.txt
``` 
Then use the new library `MiMut/LF10_lib_no_bagua.txt` in the MiMut command. 

If you want to add a new sample to the library, create a folder for the sample in `MiMut/mutant_snps`, put SNP files inside, and add the paths to the library file. For example, you have analyzed a new mutant named Mv233 by MiMut, saved the results in `~/Mv233/`, and would like to add it to the MvBL mutant library:
```
mkdir ~/MiMut/mutant_snps/Mv233
cp ~/Mv233/tmp/snp3.vcf ~/MiMut/mutant_snps/
echo mutant_snps/Mv233/snp3.vcf >> ~/MiMut/MvBL_lib.txt
```

7. Create a folder for your project: `mkdir project_name` Enter the folder: `cd project_name`
8. Create a file (e.g. reads.txt) to store the absolute paths of raw reads. One pair per line. Forward and reverse seperated by a space. For example:
```
/home/CAM/user/rawdata/Example_H2N3KDMXX_L1_1.clean.fq.gz /home/CAM/user/rawdata/Example_H2N3KDMXX_L1_2.clean.fq.gz
```
9. Execute MiMut (please replace the paths to where your files were stored):
```
sh path/to/MiMut/MiMut.sh -r path/to/reference/genome -g path/to/reference/annotation -c path/to/reference/cds -p path/to/reference/proteins -l path/to/mutant/library -f file/of/raw/read/paths
```
For example, you have cloned `MiMut` to your home directory `~` and also created `MvBL` folder in home directory. The command would be: 
```
sh ~/MiMut/MiMut.sh -r ~/MvBL/MvBLg_v2.0.fa -g ~/MvBL/MvBLg_v2.0.gtf -c ~/MvBL/MvBLg_v2.0.coding.fa -p ~/MvBL/MvBLg_v2.0.protein.fa -l ~/MiMut/MvBL_lib.txt -f reads.txt
```
For more options, execute `sh ~/MiMut/MiMut.sh` to read the full manual.

### For the secondary workflow

Step 1-8 are the same as the primary workflow. If you need the SL9 genome, it can be downloaded by `git clone https://github.com/qslin/SL9.git` Make sure to decompress it before using MiMut: `gzip -d SL9/SL9g_v2.0.fa.gz`

9. Execute MiMut (please replace the paths to where your files were stored):
```
sh path/to/MiMut/MiMut.sh -r path/to/reference/genome -g path/to/reference/annotation -c path/to/reference/cds -p path/to/reference/proteins -l path/to/mutant/library -f file/of/raw/read/paths -b path/to/the/second/genome
```
Here we use LF10 and SL9 as examples. Supposing you have cloned `MiMut` and `SL9` to your home directory `~` and also created `LF10` folder in home directory, The command will be:
```
sh ~/MiMut/MiMut.sh -r ~/LF10/LF10g_v2.0.fa -g ~/LF10/LF10g_v2.0.gtf -c ~/LF10/LF10g_v2.0.coding.fa -p ~/LF10/LF10g_v2.0.protein.fa -l ~/MiMut/LF10_lib.txt -f reads.txt -b ~/SL9/SL9g_v2.0.fa
```
In this workflow, reads will be mapped to both LF10 and SL9 genomes, which doubles the time of running programs. So increasing threads is recommended when possible. **By default, MiMut requires 8 threads.** Change the number of threads using `-t`. For example:
```
sh ~/MiMut/MiMut.sh -r ~/LF10/LF10g_v2.0.fa -g ~/LF10/LF10g_v2.0.gtf -c ~/LF10/LF10g_v2.0.coding.fa -p ~/LF10/LF10g_v2.0.protein.fa -l ~/MiMut/LF10_lib.txt -f reads.txt -b ~/SL9/SL9g_v2.0.fa -t 16
```
For more options, execute `sh ~/MiMut/MiMut.sh` to read the full manual.

### For UCONN Xanadu users

`sbatch` can be used to submit MiMut jobs. A reference shell script for job submission can be found [here](https://github.com/qslin/MiMut/blob/main/template.sh).

## Frequently asked questions

1. Why there is no SNP in the outputs?

If there no error message, it means no SNP candidate left after filtering. 





