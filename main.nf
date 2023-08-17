#!/usr/bin/env nextflow
nextflow.enable.dsl=2

if (params.platform == 'illumina') {
    include { ILLUMINA } from './workflows/illumina.nf'
} else if (params.platform == 'ont') {
    include { NANOPORE } from './workflows/nanopore.nf'
}

workflow BWA_PIPELINE {
    if (params.platform == 'illumina') {
        ILLUMINA()
    } else if (params.platform == 'ont') {
        NANOPORE()
    }
}

workflow {
    BWA_PIPELINE()
}