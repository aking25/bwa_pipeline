process ALIGN_TRIM_CONSENSUS {
    publishDir "${params.out_dir}/merged_aligned_bams/illumina" , mode: 'link', pattern: '**[!trimmed].sorted.ba*'
    publishDir "${params.out_dir}/trimmed_bams/illumina"        , mode: 'link', pattern: '*.trimmed.sorted.ba*'
    publishDir "${params.out_dir}/consensus_sequences/illumina" , mode: 'link', pattern: '*.fa'
    publishDir "${params.out_dir}/logs/consensus_sequences"     , mode: 'link', pattern: '*_consensus.log'
    input:
    path reads

    when:
    !(sample_id =~ /^Undetermined/)

    output:
    tuple val(sample_id), path("${sample_id}.sorted.bam")               , emit: sorted_bam
    tuple val(sample_id), path("${sample_id}.trimmed.sorted.bam")       , emit: trimmed_bam
    tuple val(sample_id), path("${sample_id}.stats")                    , emit: mapped_stats
    tuple val(sample_id), path("${sample_id}_coverage.stats")           , emit: coverage_stats
    path("${sample_id}.pileup")                                         , emit: pileup
    path "${sample_id}.log"                                             , emit: trim_log
    path "${sample_id}_consensus.log"                                   , emit: log
    path "${sample_id}.fa"                                              , emit: fa

    // conda 'ivar=1.4.2 bwa=0.7.17 samtools=1.9'
    conda 'ivar=1.4.2'
    shell:
    sample_id = reads[0].toString().split('_')[0]
    '''
    bwa mem -t !{params.threads} !{params.illumina.reference} !{reads[0]} !{reads[1]} | samtools view -Sb - | samtools sort - | samtools addreplacerg -r "ID:!{sample_id}" - | tee !{sample_id}.sorted.bam \
        | ivar trim -b !{params.bed_file} -x 3 -m 30 2> !{sample_id}.log | samtools sort - | tee !{sample_id}.trimmed.sorted.bam \
        | samtools mpileup -aa -A -Q 0 -d 0 --reference !{params.ref_fasta} - | tee !{sample_id}.pileup | ivar consensus -p !{sample_id}.fa -m 10 -n N -t 0.5 > !{sample_id}_consensus.log
    samtools stats !{sample_id}.sorted.bam > !{sample_id}.stats
    samtools index !{sample_id}.trimmed.sorted.bam
    compute_coverage.sh !{sample_id}.trimmed.sorted.bam !{params.coding_region} > !{sample_id}_coverage.stats
    '''
}