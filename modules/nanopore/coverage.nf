process COVERAGE_STATS {
    input:
    tuple val(sample_id), path(bam)
    path idx

    output:
    path "${sample_id}_coverage_report.tsv"

    shell:
    '''
    compute_coverage.sh !{bam} !{params.coding_region} > !{sample_id}_coverage.stats
    echo -e "SAMPLE\tCOVERAGE\tAVG_DEPTH\tMIN\tMAX\tZERO_DEPTH" > !{sample_id}_coverage_report.tsv
    cat !{sample_id}_coverage.stats | sort -n -k 2 >> !{sample_id}_coverage_report.tsv
    '''
}

process MERGE_COVERAGE_STATS {
    publishDir "${params.out_dir}/trimmed_bams/ont/reports", mode: 'link'
    input:
    path(reports)

    output:
    path "coverage_report.tsv", emit: coverage_tsv
    path "coverage_report.png", emit: coverage_png

    conda 'gnuplot'
    shell:
    '''
    echo -e "SAMPLE\tCOVERAGE\tAVG_DEPTH\tMIN\tMAX\tZERO_DEPTH" > coverage_report.tsv
    for f in !{reports}; do
        tail -n 1 $f >> coverage_report.tsv
    done
    #less coverage_report_unsorted.tsv | sort -k 1 > coverage_report.tsv
    gnuplot -e "filename='coverage_report.tsv';ofilename='coverage_report.png';set terminal png size 3000,1000;\
        set output ofilename;set boxwidth 0.5;set style fill solid;set xtics rotate by 90 right noenhanced;plot filename using 2:xtic(1) with boxes" 
    '''
}

process MAPPED_UNMAPPED {
    input:
    tuple val(sample_id), path(bam)

    output:
    path "${sample_id}_mapped_unmapped_report.tsv"

    conda 'bioconda::samtools'
    shell:
    '''
    samtools stats !{sample_id}.sorted.bam > !{sample_id}.stats
    ls !{sample_id}.stats | xargs -n 1 bash -c 'echo -e $0"\t"$(grep "mapped" $0 | head -n 1 | cut -f 3)"\t"$(grep "unmapped" $0 | head -n 1 | cut -f 3)' > !{sample_id}_mapped_unmapped_report.tsv 
    '''
}

process MERGE_MAPPED_UNMAPPED {
    publishDir "${params.out_dir}/reports/ont", mode: 'link'  
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
    #less mapped_unmapped_report_unsorted.tsv | sort -k 1 > mapped_unmapped_report.tsv
    '''
}