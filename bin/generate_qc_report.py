#!/usr/bin/env python

import sys
import shutil
import argparse
import pandas as pd
import re

if __name__ == "__main__":
    # grab user args
    parser = argparse.ArgumentParser()
    parser.add_argument("-c", "--coverage-report",
                            type=str,
                            required=True,
                            help="Coverage report for samples")
    parser.add_argument("-m", "--mapped-report",
                            type=str,
                            required=True,
                            help="Mapped unmapped report for samples")
    parser.add_argument("-t", "--trim-logs",
                            type=str,
                            required=True,
                            nargs='+',
                            help="Trimmed logs for samples")

    args = parser.parse_args()
    cov_report = args.coverage_report
    map_report = args.mapped_report
    trim_logs = args.trim_logs
    depth_cols = ['SAMPLE_ID', 'COVERAGE', 'AVG_DEPTH', 'PATH_depth']
    # get depth information from samtools output
    depth_df = pd.read_csv(cov_report, sep='\t')
    depth_df.fillna('NA', inplace=True)
    depth_df.rename(columns={'SAMPLE': 'PATH_depth'}, inplace=True)
    depth_df['SAMPLE_ID'] = depth_df['PATH_depth'].apply(lambda x: x.split('.')[0])
    depth_df = depth_df[depth_cols]
    print(depth_df)
    # get mapped vs unmapped read count information
    mapped_cols = ['SAMPLE_ID', 'mapped', 'unmapped', 'PATH_mapped']
    mapped_df = pd.read_csv(map_report, sep='\t')
    mapped_df.fillna('NA', inplace=True)
    mapped_df.rename(columns={'SAMPLE': 'PATH_mapped'}, inplace=True)
    mapped_df['SAMPLE_ID'] = mapped_df['PATH_mapped'].apply(lambda x: x.split('.')[0])
    print(mapped_df)
    # fuse depth and mapped information to create temporary QC dataframe
    qc_df_tmp1 = pd.merge(depth_df, mapped_df, on='SAMPLE_ID')
    print(qc_df_tmp1)
    # get trim information from iVar's log files
    trim_df = pd.DataFrame(columns=['SAMPLE_ID', 'trimmed_pct', 'quality_pct', 
                                    'trimmed_count', 'quality_count', 'PATH_trim'])
    for fp in trim_logs:
        print(fp)
        with open(fp, 'r') as fh:
            sample_data = {}
            sample_data['PATH_trim'] = fp
            sample_data['SAMPLE_ID'] = fp.split('.')[0]
            data = fh.readlines()
            try:
                trim_line = [l for l in data if 'Trimmed primers' in l][0]
                sample_data['trimmed_pct'] = re.findall('(\d+(?:\.\d+)?)', trim_line)[0]
                sample_data['trimmed_count'] = re.findall('\((\d+)\)', trim_line)[0]
                quality_line = [l for l in data if 'quality trimmed' in l][0]
                sample_data['quality_pct'] = re.findall('(\d+(?:\.\d+)?)', quality_line)[0]
                sample_data['quality_count'] = re.findall('\((\d+)\)', quality_line)[0]
            except:
                print(f"Not able to collect trim information from log file: {fp}")
            trim_df = trim_df.append(pd.Series(sample_data), ignore_index=True)
            print(trim_df)
    # Fuse trim information to create final QC dataframe
    qc_df = pd.merge(qc_df_tmp1, trim_df, on='SAMPLE_ID')
    print(qc_df)
    # save QC dataframe to file
    qc_df.to_csv("./qc_report.csv", index=False)