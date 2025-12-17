#!/bin/bash

# PASA Two-Round Wrapper Script
# This script runs PASA rounds 1 and 2 back-to-back using RAM disk for optimal performance
# Round 1: alignAssembly.conf (alignment and assembly)
# Round 2: annotCompare.conf (annotation comparison and updates)

set -e  # Exit on any error

# Default values
DEFAULT_CPU=$(($(nproc) - 4))

DUMP_RAMDISK=false
ALIGN_CONFIG=""
ANNOT_CONFIG=""
GENOME=""
TRANSCRIPTS=""
ORIGINAL_ANNOTS=""
CPU="$DEFAULT_CPU"

# Help function
show_help() {
    cat << EOF
PASA Two-Round Pipeline with RAM Disk Optimization

USAGE:
    $0 --align-config ALIGN_CONF --annot-config ANNOT_CONF -g GENOME -t TRANSCRIPTS -a ANNOTATIONS [OPTIONS]

REQUIRED ARGUMENTS:
    --align-config  FILE  PASA configuration file for Round 1 (alignment/assembly)
    --annot-config  FILE  PASA configuration file for Round 2 (annotation comparison)
    -g, --genome    FILE  Genome FASTA file
    -a, --annots    FILE  Original gene annotations (GFF3 format)
    -t, --transcripts FILE  Transcript sequences FASTA file

OPTIONAL ARGUMENTS:
    --cpu           NUM   Number of CPU threads (default: $DEFAULT_CPU - reserves 4 cores)
    --dump-ramdisk  FILE  Save RAM disk contents to specified file at end
    -h, --help           Show this help message

DESCRIPTION:
    This script automates the PASA two-round pipeline using /dev/shm (RAM disk) for
    dramatically improved performance. It will:

    1. Check available space in /dev/shm
    2. Create a temporary directory in /dev/shm
    3. Run PASA Round 1 with alignAssembly.conf (alignment and assembly)
    4. Run PASA Round 2 with annotCompare.conf (annotation comparison and updates)
    5. Copy results back to working directory
    6. Clean up RAM disk automatically

    The script uses separate configuration files for each round to ensure
    proper handling of both coding and non-coding genes throughout the pipeline.

    Note: This script uses the system's /dev/shm shared memory filesystem. 
    Available space is shared with all other processes on the system.

EXAMPLES:
    # Basic usage
    $0 --align-config alignAssembly.conf --annot-config annotCompare.conf \\
       -g genome.fa -t IsoSeq_transcripts.fasta -a gene_models.gff3

    # With custom CPU count and RAM disk dump
    $0 --align-config alignAssembly.conf --annot-config annotCompare.conf \\
       -g genome.fa -t IsoSeq_transcripts.fasta -a gene_models.gff3 \\
       --cpu 32 --dump-ramdisk final_database.db

REQUIREMENTS:
    - PASA pipeline installed and in PATH
    - minimap2 installed and in PATH
    - samtools installed and in PATH
    - Sufficient available space in /dev/shm (32GB+ recommended)

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --align-config)
            ALIGN_CONFIG="$2"
            shift 2
            ;;
        --annot-config)
            ANNOT_CONFIG="$2"
            shift 2
            ;;
        -g|--genome)
            GENOME="$2"
            shift 2
            ;;
        -t|--transcripts)
            TRANSCRIPTS="$2"
            shift 2
            ;;
        -a|--annots)
            ORIGINAL_ANNOTS="$2"
            shift 2
            ;;
        --cpu)
            CPU="$2"
            shift 2
            ;;
        --dump-ramdisk)
            DUMP_RAMDISK=true
            DUMP_FILE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "ERROR: Unknown option: $1"
            echo
            show_help
            exit 1
            ;;
    esac
done

# Check if required arguments are provided
if [[ -z "$ALIGN_CONFIG" || -z "$ANNOT_CONFIG" || -z "$GENOME" || -z "$TRANSCRIPTS" || -z "$ORIGINAL_ANNOTS" ]]; then
    echo "ERROR: Missing required arguments"
    echo
    show_help
    exit 1
fi

# Validate CPU count
if ! [[ "$CPU" =~ ^[0-9]+$ ]] || [[ "$CPU" -lt 1 ]]; then
    echo "ERROR: CPU count must be a positive integer"
    exit 1
fi

# RAM disk setup (Use process ID for uniqueness)
RAMDISK_MOUNT="/dev/shm/pasa_ramdisk_$$"

# Check available space in /dev/shm
AVAILABLE_SHM_GB=$(df -BG /dev/shm | tail -1 | awk '{print $4}' | sed 's/G//')
TOTAL_SHM_GB=$(df -BG /dev/shm | tail -1 | awk '{print $2}' | sed 's/G//')
RECOMMENDED_MIN_GB=32

echo "=== PASA Two-Round Pipeline with RAM Disk Optimization ==="
echo "CPU cores: $CPU"
echo "/dev/shm status: ${AVAILABLE_SHM_GB}GB available of ${TOTAL_SHM_GB}GB total"
echo "RAM disk location: $RAMDISK_MOUNT"
echo "Round 1 config: $ALIGN_CONFIG"
echo "Round 2 config: $ANNOT_CONFIG"

# Show warning if insufficient space available
if [[ $AVAILABLE_SHM_GB -lt $RECOMMENDED_MIN_GB ]]; then
    echo
    echo "╔════════════════════════════════════════════════════════════════════════════╗"
    echo "║               WARNING: Ram disk space at /dev/shm is low                   ║"
    echo "║                                                                            ║"
    echo "║  Available: ${AVAILABLE_SHM_GB}GB                                          ║"
    echo "║  Recommended minimum: ${RECOMMENDED_MIN_GB}GB                              ║"
    echo "║                                                                            ║"
    echo "║  PASA may fail during execution if space runs out.                         ║"
    echo "║  Consider:                                                                 ║"
    echo "║    - Waiting for other processes to finish                                 ║"
    echo "║    - Freeing up space in /dev/shm                                          ║"
    echo "║    - Running on a system with more RAM                                     ║"
    echo "║                                                                            ║"
    echo "╚════════════════════════════════════════════════════════════════════════════╝"
    echo
fi

if [[ "$DUMP_RAMDISK" == true ]]; then
    echo "Will dump RAM disk to: $DUMP_FILE"
fi
echo

# Setup RAM disk
echo "=== Setting up RAM disk ==="
echo "Creating RAM disk directory at: $RAMDISK_MOUNT"
mkdir -p "$RAMDISK_MOUNT"

# Update config files to use RAM disk
DB_PATH="$RAMDISK_MOUNT/pasa_database"
echo "Database will be created at: $DB_PATH"

# Create temporary config files with updated database paths
sed "s|^DATABASE=.*|DATABASE=$DB_PATH|" "$ALIGN_CONFIG" > "${ALIGN_CONFIG}.tmp"
sed "s|^DATABASE=.*|DATABASE=$DB_PATH|" "$ANNOT_CONFIG" > "${ANNOT_CONFIG}.tmp"

# Extract database name from config file for output file detection
DB_NAME=$(basename "$DB_PATH")

# Cleanup function
cleanup() {
    echo
    echo "=== Cleaning up ==="

    # Copy results before cleanup
    echo "Copying results from RAM disk to current directory..."
    find "$RAMDISK_MOUNT" -maxdepth 1 -type f \( -name "*.gff3" -o -name "*.bed" -o -name "*.gtf" -o -name "*.txt" -o -name "*.fasta" \) -exec cp {} . \; 2>/dev/null || true

    # Dump RAM disk if requested
    if [[ "$DUMP_RAMDISK" == true ]]; then
        echo "Dumping RAM disk contents to: $DUMP_FILE"
        if command -v tar >/dev/null 2>&1; then
            tar -czf "$DUMP_FILE" -C "$RAMDISK_MOUNT" . 2>/dev/null || true
            echo "RAM disk contents saved to $DUMP_FILE"
        else
            echo "WARNING: tar not found, cannot dump RAM disk"
        fi
    fi

    # Remove temporary config files
    rm -f "${ALIGN_CONFIG}.tmp" "${ANNOT_CONFIG}.tmp"

    # Remove RAM disk directory
    echo "Removing RAM disk directory..."
    rm -rf "$RAMDISK_MOUNT" 2>/dev/null || true
    echo "Cleanup completed"
}

# Set trap to cleanup on exit (success or failure)
trap cleanup EXIT

echo "=== Validating system requirements ==="
# Check if required tools are available
for tool in Launch_PASA_pipeline.pl minimap2 samtools; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "ERROR: Required tool '$tool' not found in PATH"
        exit 1
    fi
    echo "✓ Found: $tool"
done

echo "=== Validating input files ==="
# Check required files exist
for file in "$ALIGN_CONFIG" "$ANNOT_CONFIG" "$GENOME" "$TRANSCRIPTS" "$ORIGINAL_ANNOTS"; do
    if [[ ! -f "$file" ]]; then
        echo "ERROR: Required file not found: $file"
        exit 1
    fi
    echo "✓ Found: $file"
done

echo "=== ROUND 1: Initial PASA run with alignment/assembly configuration ==="
echo "Using configuration: $ALIGN_CONFIG"
echo "Command: Launch_PASA_pipeline.pl --create --run --annot_compare -L \\"
echo "  --annots $ORIGINAL_ANNOTS \\"
echo "  --config ${ALIGN_CONFIG}.tmp \\"
echo "  --genome $GENOME \\"
echo "  --transcripts $TRANSCRIPTS \\"
echo "  --ALIGNERS minimap2 \\"
echo "  --CPU $CPU \\"
echo "  --INVALIDATE_SINGLE_EXON_ESTS \\"
echo "  -N 1 \\"
echo "  --MAX_INTRON_LENGTH 100000"
echo

Launch_PASA_pipeline.pl \
    --create \
    --run \
    --annot_compare \
    -L \
    --annots "$ORIGINAL_ANNOTS" \
    --config "${ALIGN_CONFIG}.tmp" \
    --genome "$GENOME" \
    --transcripts "$TRANSCRIPTS" \
    --ALIGNERS minimap2 \
    --CPU $CPU \
    --INVALIDATE_SINGLE_EXON_ESTS \
    -N 1 \
    --MAX_INTRON_LENGTH 100000

echo
echo "=== ROUND 1 COMPLETED ==="
echo "Looking for updated gene structures file..."

# Find the generated gene structures file
UPDATED_ANNOTS=""
for file in ${DB_NAME}.gene_structures_post_PASA_updates.*.gff3; do
    if [[ -f "$file" ]]; then
        UPDATED_ANNOTS="$file"
        break
    fi
done

if [[ -z "$UPDATED_ANNOTS" ]]; then
    echo "ERROR: Could not find gene_structures_post_PASA_updates file"
    echo "Expected pattern: ${DB_NAME}.gene_structures_post_PASA_updates.*.gff3"
    echo "Available files:"
    ls -la *.gff3 2>/dev/null || echo "No .gff3 files found"
    exit 1
fi

echo "Found updated annotations: $UPDATED_ANNOTS"
echo

echo "=== ROUND 2: Second PASA run with annotation comparison configuration ==="
echo "Using configuration: $ANNOT_CONFIG"
echo "Command: Launch_PASA_pipeline.pl --run --annot_compare -L \\"
echo "  --annots $UPDATED_ANNOTS \\"
echo "  --config ${ANNOT_CONFIG}.tmp \\"
echo "  --genome $GENOME \\"
echo "  --transcripts $TRANSCRIPTS \\"
echo "  --ALIGNERS minimap2 \\"
echo "  --CPU $CPU \\"
echo "  --INVALIDATE_SINGLE_EXON_ESTS \\"
echo "  -N 1 \\"
echo "  --MAX_INTRON_LENGTH 100000 \\"
echo "  --TRANSDECODER"
echo

Launch_PASA_pipeline.pl \
    --run \
    --annot_compare \
    -L \
    --annots "$UPDATED_ANNOTS" \
    --config "${ANNOT_CONFIG}.tmp" \
    --genome "$GENOME" \
    --transcripts "$TRANSCRIPTS" \
    --ALIGNERS minimap2 \
    --CPU $CPU \
    --INVALIDATE_SINGLE_EXON_ESTS \
    -N 1 \
    --MAX_INTRON_LENGTH 100000 \
    --TRANSDECODER

echo
echo "=== ROUND 2 COMPLETED ==="
echo

# Find the final gene structures file
FINAL_ANNOTS=""
for file in ${DB_NAME}.gene_structures_post_PASA_updates.*.gff3; do
    if [[ -f "$file" && "$file" != "$UPDATED_ANNOTS" ]]; then
        FINAL_ANNOTS="$file"
    fi
done

if [[ -n "$FINAL_ANNOTS" ]]; then
    echo "Final updated annotations: $FINAL_ANNOTS"
else
    echo "Final annotations (no additional updates): $UPDATED_ANNOTS"
    FINAL_ANNOTS="$UPDATED_ANNOTS"
fi

echo
echo "=== PASA TWO-ROUND PIPELINE COMPLETED SUCCESSFULLY ==="
echo "Results summary:"
echo "  - Database: $DB_PATH"
echo "  - Round 1 config: $ALIGN_CONFIG"
echo "  - Round 2 config: $ANNOT_CONFIG"
echo "  - Final annotations: $FINAL_ANNOTS"
echo "  - Check for additional output files with prefix: $DB_NAME"
echo
echo "Key output files to examine:"
echo "  - $FINAL_ANNOTS (final gene models)"
echo "  - ${DB_NAME}.pasa_assemblies.gff3 (PASA assemblies)"
echo "  - ${DB_NAME}.pasa_assemblies_described.txt (assembly descriptions)"
echo
echo "Pipeline completed successfully using RAM disk optimization!"
echo "Both coding and non-coding genes should be included in the updates."