process TRIM_READS {
    publishDir "${params.out_dir}/trimmed_bams/illumina", mode: 'link', pattern: '*.bam'
    input:
    tuple val(sample), path(sorted_bam)

    output:
    tuple val(sample), path("${sample}.trimmed.sorted.bam")
    tuple val(sample), path("${sample}.stats")
    tuple val(sample), path("${sample}_bam.stats")
    path "${sample}.log"

    conda 'ivar' //1.4.2
    shell:
    '''
    # Add -e if nextera used
    ivar trim -x 3 -m 30 -i !{sorted_bam} -b !{params.bed_file} -p !{sample}.trimmed.bam 
    cat .command.log > !{sample}.log ## need to fix this
    samtools sort -o !{sample}.trimmed.sorted.bam !{sample}.trimmed.bam
    samtools index !{sample}.trimmed.sorted.bam
    compute_coverage.sh !{sample}.trimmed.sorted.bam > !{sample}.stats
    samtools stats !{sample}.trimmed.sorted.bam > !{sample}_bam.stats
    rm !{sample}.trimmed.bam
    '''
}

process COVERAGE_STATS {
    input:
    tuple val(sample), path(sample_stats)
    
    output:
    path "${sample}_coverage_report.tsv"
    
    shell:
    '''
    echo -e "SAMPLE\tCOVERAGE\tAVG_DEPTH\tMIN\tMAX\tZERO_DEPTH" > !{sample}_coverage_report.tsv
    cat !{sample_stats} | sort -n -k 2 >> !{sample}_coverage_report.tsv
    '''
}

process MERGE_COVERAGE_STATS {
    publishDir "${params.out_dir}/trimmed_bams/illumina/reports", mode: 'link'
    input:
    path(reports)

    output:
    path "coverage_report.tsv", emit: coverage_tsv
    path "coverage_report.png", emit: coverage_png

    shell:
    '''
    echo -e "SAMPLE\tCOVERAGE\tAVG_DEPTH\tMIN\tMAX\tZERO_DEPTH" > coverage_report.tsv
    for f in !{reports}; do
        tail -n 1 $f >> coverage_report.tsv
    done
    gnuplot -e "filename='coverage_report.tsv';ofilename='coverage_report.png';set terminal png size 3000,1000;\
        set output ofilename;set boxwidth 0.5;set style fill solid;set xtics rotate by 90 right noenhanced;plot filename using 2:xtic(1) with boxes" 
    '''
}