#!/bin/bash

bam=$1
sample=$(basename $bam)
# echo -e "SAMPLE\tCOVERAGE\tAVG_DEPTH\tMIN\tMAX\tZERO_DEPTH"
samtools depth -r $2 -d 0 -a $1 | awk -v b="$sample" 'BEGIN{MIN=10000000000;MAX=0;NUC=0;COV=0;DEPTH=0;NUCZERO=0;}{if(MIN > $3){MIN=$3;};if(MAX < $3){MAX=$3;};if($3==0){NUCZERO+=1};if($3 >= 10){COV+=1;}NUC+=1;DEPTH+=$3;}END{if(NUC>0){print b"\t"(COV/NUC)*100"\t"DEPTH/NUC"\t"MIN"\t"MAX"\t"NUCZERO}else{print b"\t"0"\t"0"\t"MIN"\t"MAX"\t"NUCZERO}}'
