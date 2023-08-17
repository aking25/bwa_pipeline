process CALL_CONSENSUS { 
    errorStrategy 'ignore'
    publishDir "${params.out_dir}/trimmed_bams/ont/", mode: 'copy', pattern: '**primertrimmed.rg.sorted.bam'
    publishDir "${params.out_dir}/consensus_sequences/ont/", mode: 'copy', pattern: '*.fa'
    publishDir "${params.out_dir}/merged_aligned_bams/ont/", mode: 'copy', pattern: '**[!primer][!trimmed].sorted.bam'
    input:
    tuple val(sample_id), path(fastq)

    output:
    tuple val(sample_id), path("${sample_id}.primertrimmed.rg.sorted.bam")     , emit: primer_trimmed
    path("${sample_id}.primertrimmed.rg.sorted.bam.bai")                       , emit: primer_trimmed_idx 
    path("${sample_id}.fa")
    tuple val(sample_id), path("${sample_id}.sorted.bam")                      , emit: sorted_bam

    // conda "bioconda::artic=1.2.3" (test if this works)
    shell:
    '''
    source activate artic-ncov2019
    artic minion --medaka --medaka-model !{params.medaka_model} --normalise !{params.normalize} --threads !{params.threads} --scheme-directory !{params.scheme_directory} \
        --read-file !{fastq} !{params.scheme} !{sample_id}
    format_fasta.sh !{sample_id}
    '''
}