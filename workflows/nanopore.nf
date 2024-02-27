#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { FAST5_TO_POD5; BASECALL_DORADO } from '../modules/nanopore/basecall.nf'
include { DEMULTIPLEX_DORADO } from '../modules/nanopore/demultiplex.nf'
include { FILTER_READS } from '../modules/nanopore/filter_reads.nf'
include { CALL_CONSENSUS } from '../modules/nanopore/consensus.nf'
include { COVERAGE_STATS; MERGE_COVERAGE_STATS; MAPPED_UNMAPPED; MERGE_MAPPED_UNMAPPED } from '../modules/nanopore/coverage.nf'

workflow NANOPORE {
    FAST5_TO_POD5()
    NANOPORE_FROM_POD5(FAST5_TO_POD5.out)
}

workflow NANOPORE_FROM_POD5 {
    take:
    pod5

    main:
    BASECALL_DORADO("${params.pod5}") | DEMULTIPLEX_DORADO | flatten | FILTER_READS
    CALL_CONSENSUS(FILTER_READS.out, params.scheme_directory)
    COVERAGE_STATS(CALL_CONSENSUS.out.primer_trimmed, CALL_CONSENSUS.out.primer_trimmed_idx) | collect | MERGE_COVERAGE_STATS
    MAPPED_UNMAPPED(CALL_CONSENSUS.out.sorted_bam) | collect | MERGE_MAPPED_UNMAPPED
}