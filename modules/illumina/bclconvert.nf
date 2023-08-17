process BCLCONVERT {
    publishDir "${params.out_dir}/merged_fastq/illumina", mode: 'copy'
    output:
    path("fastq/**[!Undetermined]_S[0-9]*_R{1,2}_001.fastq.gz")
    
    shell:
    '''
    bcl-convert --bcl-input-directory !{params.bcl_dir} --output-directory ./fastq -f --sample-sheet !{params.bcl_sample_sheet} --no-lane-splitting true \
        --bcl-num-parallel-tiles !{params.threads} --bcl-num-conversion-threads !{params.threads} --bcl-num-compression-threads !{params.threads} 
    '''
}