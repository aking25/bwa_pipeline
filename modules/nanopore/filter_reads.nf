process FILTER_READS {
    publishDir "${params.out_dir}/merged_fastq/ont", mode: 'link'
    input:
    tuple val(sample_id), path(fastq)

    output:
    tuple val(sample_id), path("${sample_id}.fastq.gz")

    container 'quay.io/biocontainers/artic:1.2.3--pyhdfd78af_0'
    shell:
    '''
    artic guppyplex --min-length !{params.min_readlen} --max-length !{params.max_readlen} --directory ./ --output !{sample_id}.fastq
    gzip -9 !{sample_id}.fastq 
    '''
}