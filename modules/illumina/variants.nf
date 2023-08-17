process CALL_VARIANTS {
    publishDir "${params.out_dir}/variants/illumina", mode: 'copy'
    input:
    tuple val(sample), path(trimmed_sorted_bam)
    path pileup

    output:
    path "${sample}.tsv"

    conda 'ivar=1.4.2'
    shell:
    '''
    cat !{pileup} | ivar variants -r !{params.ref_fasta}  -g !{params.gff3_file} -p !{sample}.tsv -m 10
    '''
}

process COUNT_VARIANTS {
    publishDir "${params.out_dir}/variants/illumina", mode: 'copy'
    input:
    path(samples_tsv)
    path(qc_report)

    output:
    path "coverage_vs_n.pdf"

    shell:
    '''
    variant_analysis.R !{qc_report} !{samples_tsv}
    '''
}