#!/usr/bin/bash

ref=/Volumes/Seagate_Exp/factera-v1/UCSC_HG19.fa
picardDir=/Volumes/Seagate_Exp/ref
nthd=8   
 
infolder=/Volumes/Seagate_Exp/2019
outfolder=/Volumes/Seagate_Exp/results_2019_1
mkdir -p ${outfolder}
exons=/Volumes/Seagate_Exp/factera-v1/exons.bed
factDir=/Volumes/Seagate_Exp/factera-v1
bitRef=/Volumes/Seagate_Exp/factera-v1/UCSC_HG19.2bit

cd $infolder


read1=$infolder/$id/${id}_R1_001.fastq.gz
read2=$infolder/$id/${id}_R2_001.fastq.gz
    
# create new folder    
outf=${outfolder}/${id}
mkdir -pv ${outf}
    
outfolder2=${outf}/factera_result
mkdir -pv ${outfolder2}

# bwa mem
bwa mem -t $nthd $ref $read1 $read2 

samtools sort -o $outf/${id}.out.sorted.bam $outf/${id}.out.bam 
samtools index $outf/${id}.out.sorted.bam

 
echo "# finished bwa mapping, sort and index on ${id} "
      
# mark duplicates
cmd="java -Xmx8g -jar ${picardDir}/picard.jar \
	 MarkDuplicates \
	I=${outf}/${id}.out.sorted.bam \
	O=${outf}/${id}.dedup_reads.bam \
       METRICS_FILE=${outfolder1}/${id}_duplicate_metrics.txt"
echo ${cmd}
eval ${cmd}
    
    
##### get basic stats from the resulting bam file
samtools flagstat $outf/${id}.dedup_reads.bam >${outf}/${id}_flagstat.txt


## fusion identification by factera v1.4.4
perl $factDir/factera.pl -o ${outfolder2}/ ${id}.dedup_reads.bam $exons $bitRef

echo "# finished fusion identification in DNA-seq: ${id} "

