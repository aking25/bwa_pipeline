process FILTER_READS {
    publishDir "${params.out_dir}/merged_fastq/ont", mode: 'copy'
    input:
    tuple val(sample_id), path(fastq)

    output:
    tuple val(sample_id), path("${sample_id}.fastq.gz")

    // conda "bioconda::artic=1.2.3" (test if this works)
    shell:
    '''
    source activate artic-ncov2019
    artic guppyplex --min-length !{params.min_readlen} --max-length !{params.max_readlen} --directory ./ --output !{sample_id}.fastq
    gzip -9 !{sample_id}.fastq 
    '''
}