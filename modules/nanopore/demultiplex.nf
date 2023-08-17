process DEMULTIPLEX {
    input:
    path fastqs

    output:
    path "**[!unclassified].fastq"

    shell:
    '''
    cat *.fastq.gz > all.fastq.gz
    nanoplexer -b !{params.ont_barcodes} -p ./ all.fastq.gz
    '''
}

process BARCODE_TO_SAMPLEID {
    errorStrategy 'ignore'
    input:
    path fastq

    output:
    tuple env(samplename), path("*.fastq"), optional: true

    shell:
    id = fastq.toString().tokenize('.')[0]
    '''
    if [ -s !{fastq}  ]
    then
        count=$(grep -c !{id} !{params.barcode_samplesheet})
        echo $count
        if [ $count -eq 1 ]; then
            samplename=$(less !{params.barcode_samplesheet} | grep !{id} | awk -F',' '{print $1}')
            cp !{fastq} ${samplename}_unfiltered.fastq
        else
            exit 1 
        fi
    fi
    '''
}