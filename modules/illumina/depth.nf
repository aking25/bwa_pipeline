process CALL_DEPTH {
    publishDir "${params.out_dir}/depth/illumina", mode: 'copy'
    input:
    tuple val(sample), path(trimmed_sorted_bam)

    output:
    path "${sample}.depth"

    shell:
    '''
    samtools depth -d 0 -Q 0 -q 0 -aa !{trimmed_sorted_bam} > !{sample}.depth
    '''
}