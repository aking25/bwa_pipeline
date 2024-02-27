#!/usr/bin/env nextflow
nextflow.enable.dsl=2

if (params.platform == 'illumina') {
    include { ILLUMINA; ILLUMINA_FROM_FASTQ } from './workflows/illumina.nf'
} else if (params.platform == 'ont') {
    include { NANOPORE; NANOPORE_FROM_POD5 } from './workflows/nanopore.nf'
} else if (params.platform == 'element') {
    include { ELEMENT } from './workflows/element.nf'
}

workflow BWA_PIPELINE {
    if (params.platform == 'illumina') {
        if (!params.fastq) { ILLUMINA() } 
        else { ILLUMINA_FROM_FASTQ() }
    } else if (params.platform == 'ont') {
        if (!params.pod5) {NANOPORE()}
        else {NANOPORE_FROM_POD5("${params.pod5}")}
    } else if (params.platform == 'element') {
        ELEMENT()
    }
}

workflow {
    BWA_PIPELINE()
}