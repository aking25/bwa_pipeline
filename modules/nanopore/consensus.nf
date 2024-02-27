process CALL_CONSENSUS { 
    // errorStrategy 'ignore'
    publishDir "${params.out_dir}/trimmed_bams/ont/", mode: 'link', pattern: '**primertrimmed.rg.sorted.bam'
    publishDir "${params.out_dir}/consensus_sequences/ont/", mode: 'link', pattern: '*.fa'
    publishDir "${params.out_dir}/merged_aligned_bams/ont/", mode: 'link', pattern: '**[!primer][!trimmed].sorted.bam'
    maxForks 1
    input:
    tuple val(sample_id), path(fastq)
    path(scheme_directory)

    output:
    tuple val(sample_id), path("${sample_id}.primertrimmed.rg.sorted.bam")     , emit: primer_trimmed
    path("${sample_id}.primertrimmed.rg.sorted.bam.bai")                       , emit: primer_trimmed_idx 
    path("${sample_id}.fa")
    tuple val(sample_id), path("${sample_id}.sorted.bam")                      , emit: sorted_bam

    // container 'quay.io/biocontainers/artic:1.2.4--pyh7cba7a3_1'
    conda 'bioconda::artic'
    shell:
    '''
    artic minion --medaka --medaka-model !{params.medaka_model} --normalise !{params.normalize} --threads !{params.threads} --scheme-directory !{scheme_directory} \
        --read-file !{fastq} !{params.scheme} !{sample_id}
    format_fasta.sh !{sample_id}
    '''
}