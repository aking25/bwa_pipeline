#!/bin/bash

sample_id=$1
sed ':a;N;/>/!s/\n//;ta;P;D' ${sample_id}.consensus.fasta > ${sample_id}.fa
