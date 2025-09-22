#!/usr/bin/env bash

# "strict mode"
set -euo pipefail

script_name=$(basename "$0")

usage() {
  cat >&2 <<EOF
Usage: $script_name laplacian_file edges_file degrees_file [--verbose]

Arguments:  
  laplacian_file  Path to Laplacian file. Filename must match laplacian_*.csv
  edges_file      Path to edges file. Filename must match edges_*.csv
  degrees_file    Path to degrees file. Filename must match degrees_*.csv
  --verbose       Optional flag to enable verbose output

EOF
  exit 1
}

verbose=0
laplacian_file=""
edges_file=""
degrees_file=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --verbose)
      verbose=1
      shift
      ;;
    *)
      if [[ -z "$laplacian_file" ]]; then
        laplacian_file="$1"
      elif [[ -z "$edges_file" ]]; then
        edges_file="$1"
      elif [[ -z "$degrees_file" ]]; then
        degrees_file="$1"
      else
        usage
      fi
      shift
      ;;
  esac
done

if [[ -z "$laplacian_file" || -z "$edges_file" || -z "$degrees_file" ]]; then
  usage
fi

if [[ ! -f "$laplacian_file" ]]; then
  echo "$laplacian_file does not exist" >&2
  exit 1
fi

if [[ ! -f "$edges_file" ]]; then
  echo "$edges_file does not exist" >&2
  exit 1
fi

if [[ ! -f "$degrees_file" ]]; then
  echo "$degrees_file does not exist" >&2
  exit 1
fi

# Extract number of vertices from degrees file
v=$(wc -l < "$degrees_file")

if (( verbose == 1 )); then
  echo "Laplacian file: $laplacian_file"
  echo "Edges file: $edges_file"
  echo "Degrees file: $degrees_file"
  echo "Number of vertices: $v"
  echo
fi

# Test 1: Check matrix dimensions
if (( verbose == 1 )); then
  echo "1. Checking matrix dimensions..."
fi
rows=$(wc -l < "$laplacian_file")
cols=$(head -1 "$laplacian_file" | tr ',' '\n' | wc -l)
if [ "$rows" -eq "$v" ] && [ "$cols" -eq "$v" ]; then
    if (( verbose == 1 )); then
      echo "   Rows: $rows, Columns: $cols"
      echo "   ✅ Matrix dimensions are correct ($v x $v)"
    fi
else
    echo "❌ Matrix dimensions are incorrect: expected $v x $v, got $rows x $cols" >&2
    exit 1
fi
if (( verbose == 1 )); then
  echo
fi

# Test 2: Check diagonal elements match degrees
if (( verbose == 
1 )); then
  echo "2. Checking diagonal elements..."
fi
awk -F',' '{print $(NR)}' "$laplacian_file" > temp_diagonal.txt
awk -F',' '{print $2}' "$degrees_file" > temp_degrees.txt
if diff temp_diagonal.txt temp_degrees.txt > /dev/null; then
    if (( verbose == 1 )); then
      echo "   ✅ Diagonal elements match degrees"
    fi
else
    echo "❌ Diagonal elements don't match degrees file" >&2
    exit 1
fi
if (( verbose == 1 )); then
  echo
fi

# Test 3: Check symmetry
if (( verbose == 1 )); then
  echo "3. Checking matrix symmetry..."
fi
python3 -c "
import sys
import csv

# Read Laplacian matrix
with open('$laplacian_file', 'r') as f:
    reader = csv.reader(f)
    matrix = [list(map(int, row)) for row in reader]

# Check symmetry
symmetric = True
for i in range($v):
    for j in range($v):
        if matrix[i][j] != matrix[j][i]:
            symmetric = False
            print(f'❌ Matrix is not symmetric at ({i},{j}): {matrix[i][j]} != {matrix[j][i]}', file=sys.stderr)
            break
    if not symmetric:
        break

if symmetric:
    if $verbose:
        print('   ✅ Matrix is symmetric')
else:
    sys.exit(1)
" || exit 1
if (( verbose == 1 )); then
  echo
fi

# Test 4: Check adjacency matrix correctness
if (( verbose == 1 )); then
  echo "4. Checking off-diagonal elements..."
fi
python3 -c "
import csv

# Read edges
edges = set()
with open('$edges_file', 'r') as f:
    reader = csv.reader(f)
    for row in reader:
        v1, v2 = int(row[0]), int(row[1])
        edges.add((v1, v2))
        edges.add((v2, v1))  # undirected graph

# Read Laplacian matrix
with open('$laplacian_file', 'r') as f:
    reader = csv.reader(f)
    matrix = [list(map(int, row)) for row in reader]

# Check adjacency entries
correct = True
for i in range($v):
    for j in range($v):
        if i != j:  # off-diagonal elements
            if (i, j) in edges:
                if matrix[i][j] != -1:
                    print(f'❌ Edge ({i},{j}) should have -1, got {matrix[i][j]}', file=sys.stderr)
                    correct = False
            else:
                if matrix[i][j] != 0:
                    print(f'❌ Non-edge ({i},{j}) should have 0, got {matrix[i][j]}', file=sys.stderr)
                    correct = False

if correct:
    if $verbose:
        print('   ✅ Off-diagonal elements match edges')
else:
    exit(1)
" || exit 1
if (( verbose == 1 )); then
  echo
fi

# Test 5: Check row sums (should be 0 for Laplacian matrix)
if (( verbose == 1 )); then
  echo "5. Checking row sums..."
fi
python3 -c "
import csv

with open('$laplacian_file', 'r') as f:
    reader = csv.reader(f)
    matrix = [list(map(int, row)) for row in reader]

row_sums_correct = True
for i in range($v):
    row_sum = sum(matrix[i])
    if row_sum != 0:
        print(f'❌ Row {i} sum is {row_sum}, should be 0', file=sys.stderr)
        row_sums_correct = False

if row_sums_correct:
    if $verbose:
        print('   ✅ All row sums are 0')
else:
    exit(1)
" || exit 1
if (( verbose == 1 )); then
  echo
fi

# Cleanup
rm -f temp_diagonal.txt temp_degrees.txt

echo "All validation tests passed"
