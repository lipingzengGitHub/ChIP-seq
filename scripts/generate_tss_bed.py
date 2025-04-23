#!/usr/bin/env python3

import argparse
import os 

def parse_gtf(gtf_path, output_path):
    tss_dict = {}
    with open(gtf_path, 'r') as gtf, open(output_path, 'w') as out:
        for line in gtf:
            if line.startswith("#"):
                continue
            fields = line.strip().split("\t")
            if len(fields) < 9 or fields[2] != "transcript":
                continue
            chrom, source, feature, start, end, score, strand, frame, attributes = fields

            # Extract gene name from attributes
            attrs = {k.strip(): v.strip().strip('"') for k, v in 
                     [item.split(" ", 1) for item in attributes.strip(";").split("; ") if " " in item]}

            gene_id = attrs.get("gene_name") or attrs.get("gene_id", "NA")
            tss = start if strand == "+" else end
            tss = int(tss)
            tss_start = max(tss - 1, 0)
            tss_end = tss_start + 1
            tss_key = (chrom, tss_start, tss_end, gene_id)

            # Avoid duplicates
            if tss_key not in tss_dict:
                tss_dict[tss_key] = True
                out.write(f"{chrom}\t{tss_start}\t{tss_end}\t{gene_id}\n")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate TSS.bed from GTF")
    parser.add_argument("-g", "--gtf", required=True, help="Input GTF file")
    parser.add_argument("-o", "--output", default="TSS.bed", help="Output BED file")
    args = parser.parse_args()
    parse_gtf(args.gtf, args.output)
