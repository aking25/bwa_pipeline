process BASECALL {
    output:
    path "*.fastq.gz"

    shell:
    '''
    !{params.guppy_path}/guppy_basecaller -c !{params.guppy_config} -i !{params.fast5} --compress_fastq -s ./ -x !{params.basecall_device} -r
    '''
}

process BASECALL_DORADO {
    input:
    path pod5

    output:
    path 'basecall.bam'

    shell:
    '''
    !{params.dorado_path}/dorado basecaller !{params.dorado_model} !{pod5} --no-trim -x !{params.basecall_device} \
        --kit-name !{params.dorado_barcode_kit} --sample-sheet !{params.dorado_samplesheet} > basecall.bam
    '''
}

process FAST5_TO_POD5 {
    publishDir "${params.fast5}", mode: 'link'
    output:
    path "pod5/"

    shell:
    '''
    pod5 convert fast5 !{params.fast5}/*.fast5 --output pod5/ --one-to-one !{params.fast5}/ --threads !{params.threads}
    '''
}