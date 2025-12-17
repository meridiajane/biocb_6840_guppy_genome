#!/usr/bin/env python3

import re
import sys
import csv

def load_gene_names(tsv_file):
    """Load gene names from a TSV file."""
    gene_name_map = {}
    
    with open(tsv_file, 'r') as f:
        reader = csv.reader(f, delimiter='\t')
        header = next(reader)  # Skip header line
        
        for row in reader:
#            if len(row) < 3:
#                continue
                
            gene_id = row[0]
            preferred_name = row[1]
#            fallback_names = row[2].split(',') if row[2] != '-' else []
            
            # If preferred name is not set, try to use the first fallback name
#            if preferred_name == '-' and fallback_names:
#                preferred_name = fallback_names[0]
            
            # Only add to the map if we have a valid name
#            if preferred_name != '-' or fallback_names:
            gene_name_map[gene_id] = preferred_name
    
    return gene_name_map

def update_gff_file(gff_file, gene_name_map, output_file=None):
    """Update gene names in a GFF3 file."""
    if output_file is None:
        output_file = gff_file + '.updated'
    
    # First, read the entire file to handle potential line join issues
    with open(gff_file, 'r') as file:
        content = file.read()
    
    # Fix any merged lines first by looking for patterns indicating missing newlines
    # This regex finds instances where "ID=geneX;Name=Y" might be on the same line as the next record
#    pattern = re.compile(r'(ID=gene\d+;Name=[^;\n]+)(Parae_)', re.MULTILINE)
#    content = pattern.sub(r'\1\n\2', content)
    
    # Now split the fixed content into lines
    lines = content.split('\n')
    
    # Regex patterns to match gene IDs and names
    gene_id_pattern = re.compile(r'ID=(g\d+)')
    parent_pattern = re.compile(r'Parent=(g\d+)')
    name_pattern = re.compile(r'Name=([g\d;\n]+[^;\n]+)')
    
    with open(output_file, 'w') as outfile:
        for line in lines:
            # Skip empty lines
            if not line.strip():
                outfile.write('\n')
                continue
                
            # Skip comment lines
            if line.startswith('#'):
                outfile.write(line + '\n')
                continue
            
            # Find gene ID
            gene_id_match = gene_id_pattern.search(line)
            parent_match = parent_pattern.search(line)
            
            gene_id = None
            if gene_id_match:
                gene_id = gene_id_match.group(1)
            elif parent_match:
                gene_id = parent_match.group(1)
            
            # Check if we need to update the name
            name_match = name_pattern.search(line)
            if name_match:
                current_name = name_match.group(1)
                new_name = None
                
                # If we have a gene ID and it's in our map, use that name
                if gene_id and gene_id in gene_name_map:
                    new_name = gene_name_map[gene_id]
                    if new_name == '-':
                        new_name = None  # Will be handled in the next steps
                
                # Handle special cases if we didn't get a valid name from the map
                if not new_name or new_name == '-':
                    # Case 1: Current name is "-" or "NONE"
                    if current_name == '-' or current_name.upper() == 'NONE':
                        new_name = '-'
                    # Case 2: Current name starts with anno1, anno2, etc.
                    elif re.match(r'anno\d+\.', current_name, re.IGNORECASE):
                        new_name = '-'
                    # Case 3: Convert lowercase to uppercase if needed
                    elif any(c.islower() for c in current_name):
                        new_name = current_name.upper()
                
                # Update the name if we have a new one
                if new_name:
                    line = name_pattern.sub(r'Name=' + new_name, line)
            
            # Ensure line has a newline character
            outfile.write(line + '\n')
    
    print(f"Updated GFF file written to: {output_file}")

def main():
    if len(sys.argv) < 3:
        print("Usage: python update_gene_names.py gene_names.tsv annotations.gff3 [output.gff3]")
        sys.exit(1)
    
    tsv_file = sys.argv[1]
    gff_file = sys.argv[2]
    output_file = sys.argv[3] if len(sys.argv) > 3 else None
    
    gene_name_map = load_gene_names(tsv_file)
    print(f"Loaded {len(gene_name_map)} gene name mappings")

    # Check if we encountered any issues with the gene name map
    if not gene_name_map:
        print("Warning: No gene name mappings loaded. Check your TSV file format.")
        sys.exit(1)
    
    try:
        update_gff_file(gff_file, gene_name_map, output_file)
        print("File processing completed successfully.")
    except Exception as e:
        print(f"Error processing file: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()
