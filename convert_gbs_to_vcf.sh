#!/usr/bin/env bash
# Simple placeholder script to convert a GBS dataset to VCF format.
# Usage: ./convert_gbs_to_vcf.sh INPUT_FILE OUTPUT_FILE
set -euo pipefail

usage() {
    cat <<USAGE
Usage: $(basename "$0") INPUT_FILE OUTPUT_FILE
Convert a GBS dataset to VCF format (placeholder).
USAGE
}

if [[ $# -ne 2 ]]; then
    usage
    exit 1
fi

input="$1"
output="$2"

echo "Converting $input to $output"
# Placeholder for actual conversion commands. For now just copy.
cp "$input" "$output"
echo "Done."
