process DEMULTIPLEX {
    input:
    path fastq

    output:
    path "**[!unclassified].fastq"

    conda 'bioconda::nanoplexer'
    shell:
    '''
    #cat *.fastq.gz > all.fastq.gz
    nanoplexer -b !{params.ont_barcodes} -p ./ -t !{params.threads} !{fastq}
    '''
}

process DEMULTIPLEX_DORADO {
    input:
    path bam

    output:
    path "**[!unclassified].fastq"

    shell:
    '''
    !{params.dorado_path}/dorado demux --output-dir ./ --kit-name !{params.dorado_barcode_kit} \
        --sample-sheet !{params.dorado_samplesheet} --emit-fastq !{bam}
    '''
}

process BARCODE_TO_SAMPLEID {
    errorStrategy 'ignore'
    publishDir "${params.out_dir}/merged_fastq/ont", mode: 'copy'
    input:
    path fastq

    output:
    tuple env(samplename), path("*.fastq.gz"), optional: true

    shell:
    id = fastq.toString().tokenize('.')[0]
    '''
    if [ -s !{fastq}  ]
    then
        count=$(grep -c !{id} !{params.barcode_samplesheet})
        echo $count
        if [ $count -eq 1 ]; then
            samplename=$(less !{params.barcode_samplesheet} | grep !{id} | awk -F',' '{print $1}')
            cp !{fastq} ${samplename}.fastq
            gzip -9 ${samplename}.fastq 
        else
            exit 1 
        fi
    fi
    '''
}