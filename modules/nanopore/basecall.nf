process BASECALL {
    output:
    path "*.fastq.gz"

    shell:
    '''
    !{params.guppy_path}/guppy_basecaller -c !{params.guppy_config} -i !{params.fast5} --compress_fastq -s ./ -x !{params.basecall_device} -r
    '''
}