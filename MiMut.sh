#!/bin/bash
#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

##### Functions

usage()
{
    echo "Program: MiMut"
    echo "Version: 1.0"
    echo "Usage:"
    echo "    sh /path/to/script/MiMut.sh [options] -r <ref.fa> -g <ref.gtf> -c <cds.fa> -p <protein.fa> -l <lib.txt> -f <reads.txt> "
    echo "Mandatory parameters:"
    echo "    -r | --reference	To provide the genome reference. "
    echo "    -g | --gtf	To provide the annotation file in GTF format for annotation of SNPs. "
    echo "    -c | --cds	To provide the CDS sequences in FASTA format for annotation of SNPs. "
    echo "    -p | --protein	To provide the protein sequences in FASTA format for annotation of SNPs. "
    echo "    -l | --library	To set the library for mutant SNPs comparing. Please reserve library files in the MiMut folder. A library file should contain SNP files in VCF format with absolute paths. "
    echo "    -f | --files	To provide raw reads. Save all paired reads files with their full paths to one txt file. One pair per line. Forward and reverse seperated by a space. "
    echo "Optional parameters:"
    echo "    -b | --bsa	To use the secondary workflow of MiMut, such as using SL9 and LF10 inbred lines. Provide the genome of the second line, e.g. SL9 genome. "
    echo "    -s | --step	To restart with a certain step(trim/align/call-SNPs/filter/annotate). The results from previous run will be overwritten. Example: -s align"
    echo "    -t | --thread	To set the number of threads. Default:8 "
    echo "    -h | --help	To see the usage. "
}

trim()
{
for n in "${!array[@]}"
do
	trimmomatic PE \
	-phred33 \
	-threads $thread \
	${array[$n]} \
	$n\_FP.fq.gz $n\_FU.fq.gz \
	$n\_RP.fq.gz $n\_RU.fq.gz \
	ILLUMINACLIP:$SCRIPT_DIR/adapters.fa:2:30:10:2:True \
	LEADING:20 \
	TRAILING:20 \
	SLIDINGWINDOW:4:20 \
	MINLEN:50
done
echo Finish reads trimming
}

align()
{
bamarray=()
for n in "${!array[@]}"
do
	bowtie2-build --quiet $ref ref
	bowtie2 --threads $thread --phred33 --no-discordant --no-unal -x ref -1 $n\_FP.fq.gz -2 $n\_RP.fq.gz -U $n\_FU.fq.gz,$n\_RU.fq.gz -S $n\_reads.sam
	samtools view -bST $ref -@ $thread $n\_reads.sam > $n\_reads.bam
	bamarray=("${bamarray[@]}" $n"_reads.bam")
done
samtools merge reads.bam ${bamarray[@]}
samtools sort -@ $thread -o reads.sort.bam -T samtmp -O bam reads.bam
rm *_reads.sam *_reads.bam reads.bam
bamtools filter -in reads.sort.bam -out reads.sort.filter1.bam -tag "XM:<3"
samtools depth -aa -q 20 -Q 20 reads.sort.filter1.bam > depth.txt
echo Finish reads alignment and filtering
}

call()
{
samtools stats -c 1,1000,1 reads.sort.filter1.bam > stats.txt
abn=`grep '^SN' stats.txt |cut -f2-|grep '^bases mapped (cigar)'|cut -f2`
avg=`grep '^COV' stats.txt |cut -f3-|sort -nrk2,2|head -1|cut -f1`
ulim=`echo "$(($avg*25/10))"`
blim=`echo "$(($avg*10/25))"`
bcftools mpileup -Ou --threads $thread -Q 20 -q 20 -f $ref reads.sort.filter1.bam | bcftools call -Ou --threads $thread -mv | bcftools filter -e '%QUAL<20' > snp0.vcf
snpcount0=`grep -c -v '^#' snp0.vcf`
echo Round 0: $snpcount0 SNPs
covflt="(DP4[0]+DP4[1]+DP4[2]+DP4[3])<$blim||(DP4[0]+DP4[1]+DP4[2]+DP4[3])>$ulim"
bcftools filter -e $covflt snp0.vcf  > snp1.vcf
echo Filter SNPs by coverage: $covflt
snpcount1=`grep -c -v '^#' snp1.vcf`
echo Round 1: $snpcount1 SNPs

frqflt="(DP4[2]+DP4[3])/(DP4[0]+DP4[1]+DP4[2]+DP4[3])<0.25"
bcftools filter -e $frqflt snp1.vcf > snp2.vcf
bcftools norm -f $ref snp2.vcf -Ov -o snp2.norm.vcf
mv snp2.norm.vcf snp2.vcf
echo Filter SNPs by alt frequency
snpcount2=`grep -c -v '^#' snp2.vcf`
echo Round 2: $snpcount2 SNPs

frqflt2="(DP4[2]+DP4[3])/(DP4[0]+DP4[1]+DP4[2]+DP4[3])<0.9"
bcftools filter -e $frqflt2 snp2.vcf | bcftools filter -e '%QUAL<200' | bcftools filter -e 'MQ<40' | bcftools filter -e 'MQSB<0.5' | awk '{split($10, a, ":");split(a[2], b, ",");if (b[1]>40&&b[2]>20&&b[3]==0) print}' > snp3.vcf
grep '^#' snp2.vcf |cat - snp3.vcf > tmp
mv tmp snp3.vcf
echo Filter SNPs by homozygousity and mapping quality
snpcount3=`grep -c -v '^#' snp3.vcf`
echo Round 3: $snpcount3 SNPs

echo Finish SNP calling and filtering
}

filter()
{
perl $SCRIPT_DIR/MiMut.pl -f=snp3.vcf -v=$lib -o=SNP -m=on
echo Finish SNPs filtering
}

filterb()
{
perl $SCRIPT_DIR/MiMut.pl -f=snp3.vcf -m=on -v=off -o=SNP 
cp SNP.eps ../../SNP.eps
echo Finish SNPs filtering
}

annotate()
{
mkdir $(which snpEff | perl -ae '$_=~s/bin\/snpEff/share\/snpeff-5.1-2\/data/;print $_')
mkdir $(which snpEff | perl -ae '$_=~s/bin\/snpEff/share\/snpeff-5.1-2\/data\/ref/;print $_')

cp $ref $(which snpEff | perl -ae '$_=~s/bin\/snpEff/share\/snpeff-5.1-2\/data\/ref\/sequences.fa/;print $_')
cp $gtf $(which snpEff | perl -ae '$_=~s/bin\/snpEff/share\/snpeff-5.1-2\/data\/ref\/genes.gtf/;print $_')
cp $cds $(which snpEff | perl -ae '$_=~s/bin\/snpEff/share\/snpeff-5.1-2\/data\/ref\/cds.fa/;print $_')
cp $prot $(which snpEff | perl -ae '$_=~s/bin\/snpEff/share\/snpeff-5.1-2\/data\/ref\/protein.fa/;print $_')

echo "ref.genome : ref" > $(which snpEff | perl -ae '$_=~s/bin\/snpEff/share\/snpeff-5.1-2\/ref.config/;print $_')

snpEff build -gtf22 -c $(which snpEff | perl -ae '$_=~s/bin\/snpEff/share\/snpeff-5.1-2\/ref.config/;print $_') -v ref

snpEff ref SNP.vcf > SNP.ann.vcf
SnpSift filter "ANN[0].IMPACT has 'HIGH'" SNP.ann.vcf > SNP.ann.1.vcf
SnpSift filter "ANN[0].IMPACT has 'MODERATE'" SNP.ann.vcf > SNP.ann.2.vcf

cp SNP.ann.*.vcf ../

echo Finish annotation
}

annotateb()
{

awk '$3>0{print $1"\t"$2"\t"$2+20000}' SNP.txt |tail -n +2 > tmp.bed
bedtools merge -i tmp.bed |awk '$3-$2>80000{print}'|bedtools merge -i - -d 200000 |awk '{print $1"\t"$2"\t"$3}'> ../high_count_regions.bed
rm tmp.bed
cd ..

cat SNP.ann.vcf | SnpSift intervals high_count_regions.bed > SNP.ann.high_count_regions.vcf
SnpSift filter "ANN[0].IMPACT has 'HIGH'" SNP.ann.high_count_regions.vcf > SNP.ann.1.vcf
SnpSift filter "ANN[0].IMPACT has 'MODERATE'" SNP.ann.high_count_regions.vcf > SNP.ann.2.vcf

cp SNP.ann.*.vcf ../

echo Finish annotation
}

##### Main

thread=8

if [ $# -lt 12 ]; then 
	usage
	exit 1
else
	while [ "$1" != "" ]; do
	    case $1 in
	        	-r | --reference )	shift
					if [[ "$1" == "" || "$1" =~ ^- ]]; then 
						echo "missing value for -r"
						exit 1
					fi 
					ref=$1 
					;;
			-g | --gtf ) 		shift
					if [[ "$1" == "" || "$1" =~ ^- ]]; then
						echo "missing value for -g"
						exit 1
					fi
					gtf=$1
					;;
                        -c | --cds )            shift
                                        if [[ "$1" == "" || "$1" =~ ^- ]]; then
                                                echo "missing value for -c"
                                                exit 1
                                        fi
                                        cds=$1
                                        ;;
                        -p | --protein )        shift
                                        if [[ "$1" == "" || "$1" =~ ^- ]]; then
                                                echo "missing value for -p"
                                                exit 1
                                        fi
                                        prot=$1
                                        ;;
			-l | --library ) 	shift
					if [[ "$1" == "" || "$1" =~ ^- ]]; then
						echo "missing value for -l"
						exit 1
					fi
					lib=$1
					;;
			-f | --files)		shift
					if [[ "$1" == "" || "$1" =~ ^- ]]; then 
						echo "missing value for -f"
						exit 1
					fi
					file=$1 
					;;
			-b | --bsa ) 	shift
					if [[ "$1" == "" || "$1" =~ ^- ]]; then
						echo "missing value for -b"
						exit 1
					fi
					bsaref=$1
					;;		
			-s | --step )	shift
					if [[ "$1" == "" || "$1" =~ ^- ]]; then 
						echo "missing value for -s"
						exit 1
					fi
					step=$1 
					;;
                        -t | --thread )	shift
                                        if [[ "$1" == "" || "$1" =~ ^- ]]; then
                                                echo "missing value for -t"
                                                exit 1
                                        fi
                                        thread=$1
                                        ;;
			-h | --help )	usage
					exit 
					;;
	    		* )		usage
					exit 1
	    esac
	    shift
	done
fi

sed -i '/^$/d' $file
array=()
while read line; do   array+=("$line");   done < $file

if [[ `ls -l | grep tmp` ]]; then echo overwrite previous results;else mkdir tmp;fi
cd tmp

case $step in
        "" ) ;&
        "trim" ) trim ;&
        "align" ) align ;&
        "call-SNPs" ) call ;&
        "filter" ) filter ;&
	"annotate" ) annotate ;;
        *) echo "Error: no such a step"; exit 1 ;;
esac

if [ "$bsaref" != "" ]; then
	mkdir tmpb
	cd tmpb
	ref=$bsaref
	echo Start the analysis on the second  genome...
	case $step in
        "" ) ;&
        "trim" ) mv ../*fq.gz . ;&
        "align" ) align ;&
        "call-SNPs" ) call ;&
        "filter" ) filterb ;&
	"annotate" ) annotateb ;;
        *) echo "Error: no such a step"; exit 1 ;;
	esac
fi




