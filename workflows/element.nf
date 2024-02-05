#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { BASES2FASTQ } from '../modules/element/bases2fastq.nf'
include { ALIGN_TRIM_CONSENSUS } from '../modules/illumina/align_trim_consensus.nf'
include { MAPPED_UNMAPPED; MERGE_MAPPED_UNMAPPED} from '../modules/illumina/align_reads.nf'
include { COVERAGE_STATS; MERGE_COVERAGE_STATS } from '../modules/illumina/trim_reads.nf'
include { CALL_VARIANTS; COUNT_VARIANTS } from '../modules/illumina/variants.nf'
include { CALL_DEPTH } from '../modules/illumina/depth.nf'
include { QC_REPORT; SUMMARY_REPORT } from '../modules/illumina/reports.nf'

// same as Illumina steps, except for basecalling
workflow ELEMENT {
    BASES2FASTQ("${params.element_input}") | toSortedList | flatten | collate(2) | ALIGN_TRIM_CONSENSUS

    MAPPED_UNMAPPED(ALIGN_TRIM_CONSENSUS.out.mapped_stats) | collect | MERGE_MAPPED_UNMAPPED

    COVERAGE_STATS(ALIGN_TRIM_CONSENSUS.out.coverage_stats) | collect | MERGE_COVERAGE_STATS

    CALL_VARIANTS(ALIGN_TRIM_CONSENSUS.out.trimmed_bam, ALIGN_TRIM_CONSENSUS.out.pileup)

    QC_REPORT(MERGE_COVERAGE_STATS.out.coverage_tsv, MERGE_MAPPED_UNMAPPED.out, ALIGN_TRIM_CONSENSUS.out.trim_log.collect())

    COUNT_VARIANTS(CALL_VARIANTS.out.collect(), QC_REPORT.out)

    CALL_DEPTH(ALIGN_TRIM_CONSENSUS.out.trimmed_bam)

    SUMMARY_REPORT(QC_REPORT.out, MERGE_COVERAGE_STATS.out.coverage_tsv, MERGE_COVERAGE_STATS.out.coverage_png, MERGE_MAPPED_UNMAPPED.out)
}