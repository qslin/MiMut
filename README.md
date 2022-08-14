# MiMut: mutant identification in *Mimulus lewisii* complex

## Table of contents

1. [Introduction of MiMut](https://github.com/qslin/MiMut/blob/main/README.md#introduction-of-MiMut)
2. [The primary workflow of MiMut](https://github.com/qslin/MiMut/blob/main/README.md#the-primary-workflow-of-mimut)
3. [The secondary workflow of MiMut using SL9 and LF10 inbred lines](https://github.com/qslin/MiMut/blob/main/README.md#the-secondary-workflow-of-mimut-using-sl9-and-lf10-inbred-lines)
4. [User guide step by step](https://github.com/qslin/MiMut/blob/main/README.md#user-guide-step-by-step)

## Introduction of MiMut

## The primary workflow of MiMut

![Figure_1](https://github.com/qslin/MiMut/blob/main/figures/Figure1.png?raw=true)

## The secondary workflow of MiMut (e.g. using SL9 and LF10 inbred lines)

![Figure_2](https://github.com/qslin/MiMut/blob/main/figures/Figure2.png?raw=true)

![Figure_3](https://github.com/qslin/MiMut/blob/main/figures/Figure3.png?raw=true)

## User guide step by step

1. Install Miniconda3 
2. conda env create -f MiMut.yaml
3. conda activate MiMut
4. Go to your home directory:
`cd ~`
5. Create a folder for your project:
`mkdir project_name`
6. Enter the folder:
`cd project_name`
7. Create a file (e.g. reads.txt) to store the absolute paths of raw reads. One pair per line. Forward and reverse seperated by a space. For example:
```
/labs/Yuan/DNA/flayed5_2017_BJ/Flayed_H2N3KDMXX_L1_1.clean.fq.gz /labs/Yuan/DNA/flayed5_2017_BJ/Flayed_H2N3KDMXX_L1_2.clean.fq.gz
```
8. execute the command below. Replace the paths to where your files were reserved:
`sh ~/MiMut/MiMut.sh -r path/to/reference/genome -g path/to/reference/annotation -l path/to/mutant/library -f file/of/raw/read/paths`
For example: 
`sh ~/MiMut/MiMut.sh -r ~/resource/LF10/LF10g_v2.0.fa -g ~/resource/LF10/LF10g_v2.0.gtf -l ~/MiMut/LF10_lib.txt -f reads.txt`
9. For more options, execute the command below and read the manual:
`sh ~/MiMut/MiMut.sh`


