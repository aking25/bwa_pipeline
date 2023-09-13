process ALIGN_READS {
    publishDir "${params.out_dir}/merged_aligned_bams/illumina", mode: 'link', pattern: '*.bam'
    input:
    path reads
    
    when:
    !(sample_id =~ /^Undetermined/)

    output:
    tuple val(sample_id), path("${sample_id}.sorted.bam")
    tuple val(sample_id), path("${sample_id}.stats")

    shell:
    sample_id = reads[0].toString().split('_')[0]
    '''
    bwa mem -t !{params.threads} !{params.illumina.reference} !{reads[0]} !{reads[1]} | samtools view -Sb | samtools sort -T !{sample_id}.align -o !{sample_id}.sorted.tmp.bam
    samtools addreplacerg -r "ID:!{sample_id}" -o !{sample_id}.sorted.bam !{sample_id}.sorted.tmp.bam
    rm "!{sample_id}.sorted.tmp.bam"
    samtools stats !{sample_id}.sorted.bam > !{sample_id}.stats
    '''

}

process MAPPED_UNMAPPED {
    input:
    tuple val(sample), path(sample_stats)

    output:
    path "${sample}_mapped_unmapped_report.tsv"

    shell:
    '''
    ls !{sample_stats} | xargs -n 1 bash -c 'echo -e $0"\t"$(grep "mapped" $0 | head -n 1 | cut -f 3)"\t"$(grep "unmapped" $0 | head -n 1 | cut -f 3)' > !{sample}_mapped_unmapped_report.tsv 
    '''
}

process MERGE_MAPPED_UNMAPPED {
    publishDir "${params.out_dir}/reports/illumina", mode: 'link'  
    input:
    path(reports)

    output:
    path "mapped_unmapped_report.tsv"

    shell:
    '''
    echo -e "SAMPLE\tmapped\tunmapped" > mapped_unmapped_report.tsv
    for f in !{reports}; do
        tail -n 1 $f >> mapped_unmapped_report.tsv
    done
    '''
}