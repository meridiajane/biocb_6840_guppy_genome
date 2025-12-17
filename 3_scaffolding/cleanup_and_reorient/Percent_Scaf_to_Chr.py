# Import packages needed to run
import sys
import pandas as pd

# Import data from standard input and name columns (can change to specific file)
df = pd.read_csv(sys.stdin, header=None, sep='\t')
df.columns = ["QueryName", "QueryLength","QueryStart","QueryEnd","strand","RefName","RefLength","RefStart","RefEnd","Matches","AlignmentLength","MapQuality", "AlnType", "Minimizes_on_chain", "ChainScore", "2ndChainScore","PerBaseSeqDiverg"]

# Make a subgroup by QueryName (scaffold) and RefName (female reference match)
Query_by_Ref_grouped = df.groupby(['QueryName','RefName','QueryLength'])['AlignmentLength'].sum()

# Turn subgroup into a dataframe to be used
Query_by_Ref_df = Query_by_Ref_grouped.reset_index()

# Calculate the percent of a scaffold that was match to female reference genome
Query_by_Ref_df ['Percent_of_Query'] = (Query_by_Ref_df['AlignmentLength'] / Query_by_Ref_df['QueryLength'] *100).round(2)

# Save as tsv file
Query_by_Ref_df.to_csv('allmatch.tsv', sep="\t",index=False)


# Find best match for each male scaffold
BestRef_per_Query = Query_by_Ref_df.loc[Query_by_Ref_df.groupby(["QueryName"])["Percent_of_Query"].idxmax()]

# Save as tsv file
BestRef_per_Query.to_csv('bestmatch.tsv', sep="\t",index=False)
