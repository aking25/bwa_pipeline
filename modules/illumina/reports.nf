process QC_REPORT {
    publishDir "${params.out_dir}", mode: 'copy'
    input:
    path coverage_report
    path mapped_unmapped_report
    path sample_logs

    output:
    path "qc_report.csv"

    shell:
    '''
    generate_qc_report.py -c !{coverage_report} -m !{mapped_unmapped_report} -t !{sample_logs}
    '''
}

process SUMMARY_REPORT {
    publishDir "${params.out_dir}", mode: 'copy'
    input: 
    path qc_report
    path coverage_report_tsv
    path coverage_report_png
    path mapped_unmapped

    output: 
    path "${current_date}_analysis_report.tar"

    shell: 
    def date = new Date()
    current_date = date.format("yyyy-MM-dd")
    '''
    tar cvf !{current_date}_analysis_report.tar !{qc_report} !{coverage_report_tsv} \
        !{coverage_report_png} !{mapped_unmapped};
    '''
}