process BASES2FASTQ {
    output:
    path("Samples/*/*/*.fastq.gz")

    shell:
    '''
    bases2fastq -p !{params.threads} !{params.element_input} ./ 
    #filenames=($(find -type f -name '*.fastq.gz' ! -name 'Unassigned*.fastq.gz'))
    '''
}