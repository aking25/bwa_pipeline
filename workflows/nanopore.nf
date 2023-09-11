#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { BASECALL } from '../modules/nanopore/basecall.nf'
include { DEMULTIPLEX; BARCODE_TO_SAMPLEID } from '../modules/nanopore/demultiplex.nf'
include { FILTER_READS } from '../modules/nanopore/filter_reads.nf'
include { CALL_CONSENSUS } from '../modules/nanopore/consensus.nf'
include { COVERAGE_STATS; MERGE_COVERAGE_STATS; MAPPED_UNMAPPED; MERGE_MAPPED_UNMAPPED } from '../modules/nanopore/coverage.nf'

workflow NANOPORE {
    BASECALL() | collect | DEMULTIPLEX | flatten | BARCODE_TO_SAMPLEID | FILTER_READS
    CALL_CONSENSUS(FILTER_READS.out, params.scheme_directory)
    COVERAGE_STATS(CALL_CONSENSUS.out.primer_trimmed, CALL_CONSENSUS.out.primer_trimmed_idx) | collect | MERGE_COVERAGE_STATS
    MAPPED_UNMAPPED(CALL_CONSENSUS.out.sorted_bam) | collect | MERGE_MAPPED_UNMAPPED
}