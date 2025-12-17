#!/usr/bin/python3

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Imports
import pandas as pd
import argparse
import os
from time import localtime, strftime

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Functions

def parse_arguments():
    parser = argparse.ArgumentParser(
            prog = "rat.py",
            description = "R.A.T. (Repeatmasker Annotation Tabler) outputs a condensed summary tsv from Repeat Masker out files for use in further analysis.",
            epilog = "~~(  ^*> squeak squeak")
    parser.add_argument("-i", "--input", help="Path to RepeatMasker .out file", type=in_path)
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

#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Main

def main():
    arg = parse_arguments()

    # It's necessary to provide col names here or it fails because of 
    # RM putting an additional * at the end of some lines
    rmout_df = pd.read_table(arg.input,
            names=["col1","col2","col3","col4","col5","col6","col7","col8",
                "col9","col10","col11","col12","col13","col14","col15","col16"],
            usecols = [4, 5, 6, 10], skiprows = 3, header = None, sep = '\s+')
    
    # Obtain only the useful data (chr name, length of TE, TE class/family)
    working_df = pd.DataFrame()
    working_df["chromosome"] = rmout_df.iloc[:,0]
    working_df["length"] = rmout_df.iloc[:,2] - rmout_df.iloc[:,1]
    working_df["te"] = rmout_df.iloc[:,3]
    
    # Sum lengths by chromosome and TE type, drop excess info, de-duplicate
    working_df["total_length"] = working_df.groupby(["chromosome","te"])["length"].transform("sum")
    working_df.drop("length", axis=1, inplace = True)
    working_df.drop_duplicates(inplace = True)
    working_df.reset_index(drop = True, inplace = True)

    # Generate output tsv
    working_df.to_csv(arg.output, index = False, sep = "\t")


#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
# Execute

if __name__ == "__main__":
    main()
