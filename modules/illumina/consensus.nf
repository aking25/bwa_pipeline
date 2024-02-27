process CALL_CONSENSUS {
    publishDir "${params.out_dir}/consensus_sequences/${params.platform}", mode: 'link', pattern: '*.fa'
    publishDir "${params.out_dir}/logs/consensus_sequences"              , mode: 'link', pattern: '*.log'
    input:
    tuple val(sample), path(trimmed_sorted_bam)
    
    output:
    path "${sample}.fa"
    path "${sample}.log"
    
    conda 'ivar=1.4.2'
    shell:
    '''
    samtools mpileup -aa -A -Q 0 -d 0 !{trimmed_sorted_bam} | ivar consensus -p !{sample}.fa -m 10 -n N -t 0.5 > !{sample}.log
    '''
}