#! /usr/bin/env bash

# "strict mode"
set -euo pipefail

script_name=$(basename "$0")

if (( $# != 2 )); then
  cat >&2 <<EOF
Usage: $script_name edges_file degrees_file

Arguments:
  edges_file   Path to file containing graph edges. Filename must match edges_*.csv
  degrees_file Path to file containing vertex degrees. Filename must match degrees_*.csv

EOF
  exit 1
fi

edges_path="$1"
degrees_path="$2"
edges_dir=$(dirname "$edges_path")
edges_file=$(basename "$edges_path")
degrees_file=$(basename "$degrees_path")

if [[ ! -f "$edges_path" ]]; then
  echo "$edges_path does not exist" >&2
  exit 1
fi

if [[ ! -f "$degrees_path" ]]; then
  echo "$degrees_path does not exist" >&2
  exit 1
fi

if [[ $edges_file =~ ^edges_(.+).csv$ ]]; then
    signature="${BASH_REMATCH[1]}"
    laplacian_file="laplacian_$signature.csv"
    laplacian_path="$edges_dir/$laplacian_file"
else
    echo "$script_name: expected edges_file to match edges_*.csv, got $edges_file" >&2
    exit 1
fi

if [[ $degrees_file =~ ^degrees_(.+).csv$ ]]; then
    degrees_signature="${BASH_REMATCH[1]}"
    if [[ "$signature" != "$degrees_signature" ]]; then
        echo "$script_name: signature mismatch between edges file ($signature) and degrees file ($degrees_signature)" >&2
        exit 1
    fi
else
    echo "$script_name: expected degrees_file to match degrees_*.csv, got $degrees_file" >&2
    exit 1
fi

# Build adjacency matrix and output Laplacian
laplacian_script='
BEGIN {
  # Read degrees and count vertices
  v = 0
  while ((getline line < degrees_file) > 0) {
    split(line, parts, ",")

    vertex = parts[1]
    degree = parts[2]
    degrees[vertex] = degree

    v++
  }

  close(degrees_file)
  
  # Print number of vertices
  print v > "/dev/stderr"
  
  # Initialize adjacency matrix
  for (i = 0; i < v; i++) {
    for (j = 0; j < v; j++) {
      adj[i "," j] = 0
    }
  }
}

{
  # Mark adjacency
  adj[$1 "," $2] = 1
  adj[$2 "," $1] = 1
}

END {
  # Print number of edges
  print NR > "/dev/stderr"
  
  # Output Laplacian matrix L = D - A
  for (i = 0; i < v; i++) {
    for (j = 0; j < v; j++) {
      if (i == j) {
        # Diagonal: degree of vertex i
        printf "%d", degrees[i]
      } else {
        # Off-diagonal: negative of adjacency
        printf "%d", -adj[i "," j]
      }
      
      if (j < v - 1) {
        printf ","
      }
    }

    printf "\n"
  }
}'

cat "$edges_path" | awk -F ',' -v degrees_file="$degrees_path" "$laplacian_script" > "$laplacian_path"
echo "$laplacian_path"
