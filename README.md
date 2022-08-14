# MiMut: mutant identification in *Mimulus lewisii* complex

## Table of contents

1. [Introduction of MiMut](https://github.com/qslin/MiMut/blob/main/README.md#introduction-of-MiMut)
2. [The primary workflow of MiMut](https://github.com/qslin/MiMut/blob/main/README.md#the-primary-workflow-of-mimut)
3. [The secondary workflow of MiMut using SL9 and LF10 inbred lines](https://github.com/qslin/MiMut/blob/main/README.md#the-secondary-workflow-of-mimut-eg-using-sl9-and-lf10-inbred-lines)
4. [User guide step by step](https://github.com/qslin/MiMut/blob/main/README.md#user-guide-step-by-step)

## Introduction of MiMut

MiMut was designed for easy identification of *Mimulus* mutants. 

## The primary workflow of MiMut

![Figure_1](https://github.com/qslin/MiMut/blob/main/figures/Figure1.png?raw=true)

## The secondary workflow of MiMut (e.g. using SL9 and LF10 inbred lines)

![Figure_2](https://github.com/qslin/MiMut/blob/main/figures/Figure2.png?raw=true)

![Figure_3](https://github.com/qslin/MiMut/blob/main/figures/Figure3.png?raw=true)

## User guide step by step

### For the primary workflow

1. Install Miniconda3 following the [instructions](https://docs.conda.io/projects/conda/en/latest/user-guide/install/linux.html)
2. Download MiMut to your server:
`git clone git@github.com:qslin/MiMut.git`
3. Create MiMut environment:
`conda env create -f MiMut/MiMut.yaml`
4. Activate the environment:
`conda activate MiMut`
5. Prepare genome(s) and annotation files (including CDS sequences, protein sequences, and a GTF file). If you don't have them locally, please download from [Mimubase](http://mimubase.org/FTP/Genomes/). The SL9 genome is available in the MiMut package. Creating a new folder for each species is recommended. For example: 
```
mkdir MvBL
cd MvBL
wget http://mimubase.org/FTP/Genomes/MvBLg_v2.0/MvBLg_v2.0.fa
http://mimubase.org/FTP/Genomes/MvBLg_v2.0/MvBLg_v2.0.coding.fa
http://mimubase.org/FTP/Genomes/MvBLg_v2.0/MvBLg_v2.0.gtf
http://mimubase.org/FTP/Genomes/MvBLg_v2.0/MvBLg_v2.0.protein.fa
cd ..
```
6. Create a folder for your project:
`mkdir project_name`
7. Enter the folder:
`cd project_name`
8. Create a file (e.g. reads.txt) to store the absolute paths of raw reads. One pair per line. Forward and reverse seperated by a space. For example:
```
/home/CAM/user/rawdata/Example_H2N3KDMXX_L1_1.clean.fq.gz /home/CAM/user/rawdata/Example_H2N3KDMXX_L1_2.clean.fq.gz
```
9. Execute MiMut (please replace the paths to where your files were stored):
`sh path/to/MiMut/MiMut.sh -r path/to/reference/genome -g path/to/reference/annotation -c path/to/reference/cds -p path/to/reference/proteins -l path/to/mutant/library -f file/of/raw/read/paths`
> For example, you have cloned `MiMut` to your home directory `~` and also created `MvBL` folder in home directory. The command would be: 
> `sh ~/MiMut/MiMut.sh -r ~/MvBL/MvBLg_v2.0.fa -g ~/MvBL/MvBLg_v2.0.gtf -c ~/MvBL/MvBLg_v2.0.coding.fa -p ~/MvBL/MvBLg_v2.0.protein.fa -l ~/MiMut/MvBL_lib.txt -f reads.txt`
10. For more options, execute the command below and read the manual:
`sh ~/MiMut/MiMut.sh`

### For the secondary workflow

Step 1-8 are the same as the primary workflow. 

9. Execute MiMut (please replace the paths to where your files were stored):
`sh path/to/MiMut/MiMut.sh -r path/to/reference/genome -g path/to/reference/annotation -c path/to/reference/cds -p path/to/reference/proteins -l path/to/mutant/library -f file/of/raw/read/paths -b path/to/the/second/genome`
> Here we use LF10 and SL9 as examples. Supposing you have cloned `MiMut` to your home directory `~` and also created `LF10` folder in home directory, The command will be:
> `sh ~/MiMut/MiMut.sh -r ~/LF10/LF10g_v2.0.fa -g ~/LF10/LF10g_v2.0.gtf -c ~/LF10/LF10g_v2.0.coding.fa -p ~/LF10/LF10g_v2.0.protein.fa -l ~/MiMut/LF10_lib.txt -f reads.txt -b ~/MiMut/genomes/SL9g_v2.0.fa`
> In this workflow, reads will be mapped to both LF10 and SL9 genomes, which doubles the time of running programs. So increasing threads is recommended when possible. By default, MiMut requires 8 threads. Change the number of threads using `-t`. For example:
> `sh ~/MiMut/MiMut.sh -r ~/LF10/LF10g_v2.0.fa -g ~/LF10/LF10g_v2.0.gtf -c ~/LF10/LF10g_v2.0.coding.fa -p ~/LF10/LF10g_v2.0.protein.fa -l ~/MiMut/LF10_lib.txt -f reads.txt -b ~/MiMut/genomes/SL9g_v2.0.fa -t 16`


