#!/usr/bin/python3
#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Imports
import pandas as pd
import argparse
import os

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Functions

def parse_arguments():
    parser = argparse.ArgumentParser(
            prog = "reorient.py",
            description = "Reorient takes a gff3 file and tsv of sequences to flip, then outputs a gff3 file with those sequences being reoriented.",
            epilog = "")
    parser.add_argument("-i", "--input", help="Path to .gff3 file.", type=in_path)
    parser.add_argument("-s", "--seqs", help="Path to tsv containing the sequences to flip and their length, one per line (name\tlen).", type=in_path)
    parser.add_argument("-o", "--output", help="Path to write output to, will not overwrite existing files", type=out_path)
    return parser.parse_args()

def in_path(path):
    if os.path.isfile(path):
        return path
    else:
        raise argparse.ArgumentTypeError(f"{path} does not exist or is a directory")

def out_path(path):
    if os.path.isfile(path):
        raise argparse.ArgumentTypeError(f"{path} exists")
    else:
        return path

def reorient(x, chrs):
    if chrs.iloc[:,0].eq(x.iloc[0]).any():
        if x.iloc[6] == "+":
            x.iloc[6] = "-"
        else:
            x.iloc[6] = "+"
        start_old = x.iloc[3]
        end_old = x.iloc[4]
        chr_len = chrs.loc[chrs.iloc[:,0] == x.iloc[0]].iloc[:,1].values[0]
        x.iloc[3] = chr_len + 1 - end_old
        x.iloc[4] = chr_len + 1 - start_old
        print(x[0],"\tTrue")
    return x
                
#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Main

def main():
    arg = parse_arguments()

    mount_seq = pd.read_table(arg.seqs, header = None, sep = '\s+')
    mount_in = pd.read_table(arg.input, header = None, sep = '\s+')

    mount_out = mount_in.apply(lambda x: reorient(x, mount_seq), axis = 1)
    
    mount_out.to_csv(arg.output, index = False, sep = " ", header=None)


#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Execute

if __name__ == "__main__":
    main()
