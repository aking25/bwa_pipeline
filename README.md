# BWA Pipeline

## Pipeline Summary

### Illumina

1. Basecalling (`bclconvert`)
2. Align reads (`bwa mem`), assumes paired reads
3. Trim reads and call consensus (`iVar`)
4. Mapping/coverage stats and variant calling
    * Collect mapped/unmapped stats (`samtools`)
    * Collect coverage stats (`samtools`)
    * Call variants (`iVar`)
    * Call depth (`samtools`)
5. Generate quality control report
6. Count variants
7. Generate summary report

### Nanopore

1. Basecalling (`guppy`)
2. Demultiplexing (`nanoplexer`)
3. Filter reads (`artic guppyplex`)
4. Call consensus (`artic minion`)
5. Mapping/coverage stats (`samtools`)

## Usage

1. Open `template.config` and set the following parameters:
    * `platform`: the sequencing platform (*illumina* or *ont*) 
    * `out_dir`: the directory to output the files to
    * `threads`: the number of threads to use
    * `coding_region`: the coding region (default: *NC_045512.2:266-29674*)
2. Set platform specific parameters:
    1. illumina
        * `bcl_dir`: the run folder directory
        * `bcl_sample_sheet`:  path to the sample sheet
        * `bed_file`: BED file with primer sequences and positions
        * `gff3_file`: GFF file in  GFF3 format to specify coordinates of open reading frames (ORFs)
        * `ref_fasta`: reference file used for alignment
        * `reference`: prefix of output database (from bwa index)
    2. ont
        * `fast5`: directory with fast5 files
        * `barcode_samplesheet`: Comma-separated file with barcodes and sample names (see `ont_samplesheet_example.csv`)
        * `ont_barcodes`: fasta file with barcodes used
        * `scheme_directory`: directory with primer schemes used in artic minion
        * `scheme`: scheme used in artic minion
        * `guppy_path`: directory where guppy_basecaller is located 
        * `guppy_config`: basecalling model for guppy based on library preparation kit 
        * `basecall_device`: basecalling device (*auto* or *cuda:\<device_id>*)
        * `min_readlen`: min read length for filtering
        * `max_readlen`: max read length for filtering
        * `medaka_model`: medaka model for artic minion
        * `normalize`: length to normalize reads
3. Run the command:   
    ```
    mv template.config nextflow.config
    nextflow run main.nf
    ```

## Output
Both illumina and ont produce the following directories:
* `consensus_sequences`: consensus sequences of samples
* `merged_aligned_bams`: sorted bam files
* `merged_fastq`: fastq files of samples
* `reports`: mapping report
* `trimmed_bams`: trimmed bam files and coverage report graph

Illumina also produces two additional directories and files:
* `depth`: depth of samples
* `logs`: logs from calling `iVar consensus`
* `qc_report.csv`: quality report containing coverage, depth, mapping, trimming, and quality information