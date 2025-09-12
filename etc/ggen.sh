#! /usr/bin/env bash

# "strict mode"
set -euo pipefail

script_name=$(basename "$0")
default_seed=1

usage() {
  cat >&2 <<EOF
Usage: $script_name --graph-type <graph_type> --v <v> --density <density> [--seed <seed>] [--graph-dir <graph_dir>] [--hist] [--plot]

Arguments:  
  --graph-type Type of graph to generate (exponential, power, geometric)
  --v          Number of vertices
  --density    Graph density (0 <= density <= 1000; density 500 means that 50% of the edges are present)
  --seed       Optional random seed (a positive integer), default: $default_seed
  --graph-dir  Optional directory to save graphs to, default: current working directory
  --hist       Optionally generate Gnuplot histogram
  --plot       Optionally generate Graphviz plot

Examples:
  exponential, 100  vertices, density 600, seed $default_seed,  save to pwd,    no histogram, no plot: $script_name --graph-type exponential --v 100  --density 600
  exponential, 100  vertices, density 600, seed 42, save to graphs, histogram only:        $script_name --graph-type exponential --v 100  --density 600 --seed 42 --graph-dir graphs --hist
  power,       2500 vertices, density 200, seed 42, save to graphs, plot only:             $script_name --graph-type power       --v 2500 --density 200 --seed 42 --graph-dir graphs --plot
  geometric,   790  vertices, density 150, seed 42, save to graphs, histogram and plot:    $script_name --graph-type geometric   --v 790  --density 150 --seed 42 --graph-dir graphs --hist --plot

EOF
  exit 1
}

if [[ $# -eq 0 ]]; then
  usage
fi

generate_histogram=0
generate_plot=0
while [[ $# -gt 0 ]]; do
  case $1 in
    --graph-type)
      graph_type_str="$2"
      shift
      shift
      ;;
    --v)
      v="$2"
      shift
      shift
      ;;
    --density)
      density="$2"
      shift
      shift
      ;;
    --seed)
      seed="$2"
      shift
      shift
      ;;
    --graph-dir)
      graph_dir="$2"
      shift
      shift
      ;;
    --hist)
      generate_histogram=1
      shift
      ;;
    --plot)
      generate_plot=1
      shift
      ;;
    *)
      usage
      ;;
  esac
done

if [[ -z "$graph_type_str" || -z "$v" || -z "$density" ]]; then
  usage
fi

case $graph_type_str in
  exponential)
    graph_type=2
    ;;
  power)
    graph_type=3
    ;;
  geometric)
    graph_type=4
    ;;
  *)
    usage
    ;;
esac

script_dir=$(dirname "$(realpath "$0")")
repo_dir=$(dirname "$script_dir")
ggen_binary="$repo_dir/bin/ggen"
if [[ ! -f "$ggen_binary" ]]; then
  echo "$script_name: ggen binary not found" >&2
  echo "make -C $repo_dir ggen" >&2
  exit 1
fi

default_graph_dir=$(pwd)
graph_dir=${graph_dir:-"$default_graph_dir"}
if [[ ! -d "$graph_dir" ]]; then
  echo "$script_name: graph directory '$graph_dir' does not exist" >&2
  echo "mkdir -p $graph_dir" >&2
  exit 1
fi

seed=${seed:-"$default_seed"}
signature="$graph_type_str-$v-$density-$seed"

hist_file="histogram_$signature.pdf"
hist_path="$graph_dir/$hist_file"

xlabel='degree'
ylabel='frequency'
gnuplot_script="
set terminal pdf monochrome;
set title '$graph_type_str (v = $v, density = $density); seed: $seed';
set xlabel '$xlabel';
set ylabel '$ylabel';
set output '$hist_path';
plot '-' using 1:(1.0) smooth freq with boxes notitle
"

graph_prefix="graph"
graph_file="${graph_prefix}_$signature.txt"
graph_path="$graph_dir/$graph_file"

graphviz_file="graphviz_$signature.pdf"
graphviz_path="$graph_dir/$graphviz_file"

dot_file="${graph_prefix}_$signature.dot"
dot_path="$graph_dir/$dot_file"

stats_file="stats_$signature.txt"
stats_path="$graph_dir/$stats_file"

awk_script='
  BEGIN {
    for (i = 0; i < v; i++) {
      degrees[i] = 0
    }

    print "graph G {" > "/dev/stderr"

    if (large_graph) {
      print "  layout=sfdp;\n" \
            "  sep=\"+150,150\";\n" \
            "  overlap=false;\n" \
            "  splines=false;\n" \
            "  node [shape=point, width=0.05, height=0.05];\n" > "/dev/stderr"
    }
  }
  
  {
    vertex = NR-1
    for (i = 1; i <= NF; i++) {
      degrees[vertex]++
      degrees[$i]++

      # undirected graph
      print "  " vertex " -- " $i ";" > "/dev/stderr"
    }
  }

  END {
    for (vertex in degrees) {
      degree = degrees[vertex]
      print degree

      if (!degree) {
        print "  " vertex ";" > "/dev/stderr"
      }
    }

    print "}" > "/dev/stderr"
  }'

# an arbitrary threshold chosen based on what "looks reasonable" on my machine
if (( v > 20 )); then
  large_graph=1
else
  large_graph=0
fi


if (( generate_histogram == 1 )); then
  histogram_cmd="gnuplot -e \"$gnuplot_script\""
else
  histogram_cmd="cat > /dev/null"
fi

if (( generate_plot == 1 )); then
  plot_cmd="dot -Tpdf -o $graphviz_path"
else
  plot_cmd="cat > /dev/null"
fi

# we want a pipeline that extracts the graph out of the ggen output and converts it to a dot format
# as well as rendering it and producing a gnuplot histogram of the degree distribution.
# certain ggen arguments are hardcoded to 0 because ggen.sh does not expose the corresponding ggen functionality
num_sets=0
num_fixed=0
fixed_type=0
compl=0
echo "$graph_type $v $num_sets $density $seed $num_fixed $fixed_type $compl" | $ggen_binary \
  | tee >(grep "\-1$" > "$graph_path") | tee >(grep -v "\-1$" > "$stats_path") \
  | grep "\-1$" | sed 's/-1//g' | awk -v v="$v" -v large_graph="$large_graph" "$awk_script" \
  2> >(tee >(eval "$plot_cmd") "$dot_path") \
  | eval "$histogram_cmd"

nedges=$(grep 'E =' "$stats_path" | cut -d',' -f 2 | cut -d'=' -f 2 | tr -d ' ')
echo "$nedges"
echo "$dot_path"
echo "$graph_path"
echo "$stats_path"
if (( generate_histogram == 1 )); then
  echo "$hist_path"
fi
if (( generate_plot == 1 )); then
  echo "$graphviz_path"
fi
