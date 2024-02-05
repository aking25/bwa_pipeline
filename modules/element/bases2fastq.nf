process BASES2FASTQ {
    input:
    path runinfo

    output:
    path("Samples/*/*/*.fastq.gz")

    container "elembio/bases2fastq"
    shell:
    '''
    bases2fastq -p !{params.threads} !{runinfo} ./ 
    #filenames=($(find -type f -name '*.fastq.gz' ! -name 'Unassigned*.fastq.gz'))
    '''
}