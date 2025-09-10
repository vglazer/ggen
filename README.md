# ggen

## Quickstart

- `brew install graphviz`
- `brew install gnuplot`
- Clone the repo
- cd into the top-level repo directory
- `make`
- Check out the Graphviz plots and Gnuplot histograms in the `gallery` subdirectory as well as the CSV files in the `tests` subdirectory

## Background

- [`ggen`](https://github.com/vglazer/USRA/blob/master/subgraph_finding/doc/ggen.md) is part of [a larger suite of programs](https://github.com/vglazer/USRA/tree/master/subgraph_finding) for finding induced subgraphs with a prescribed edge count.
- Among other things, ggen can generate three kinds of random graphs: "exponential" ([Erdős–Rényi](https://en.wikipedia.org/wiki/Erd%C5%91s%E2%80%93R%C3%A9nyi_model)), "power" (scale-free) and "geometric" (in the plane, with no wrap-around).
- It is intended to be used in conjunction with [`sub_search`](https://github.com/vglazer/USRA/blob/master/subgraph_finding/doc/sub_search.md) and is a bit awkward to call directly.
- Moreover, the native graph representation format used by `ggen`, `sub_search` and related programs &mdash; effectively the [adjacency lists](https://en.wikipedia.org/wiki/Adjacency_list) corresponding to the upper-triangular portion of the [adjacency matrix](https://en.wikipedia.org/wiki/Adjacency_matrix) &mdash; is non-standard and does not lend itself to visualization or manipulation.
- This standalone repo contains a copy of [`ggen.c`](src/ggen.c) as well as [`ggen.sh`](etc/ggen.sh), a friendlier wrapper for a subset of `ggen`'s functionality. Be sure to `make ggen` before running `ggen.sh`.
- `ggen.sh` outputs graphs in the standard [DOT format](https://graphviz.org/doc/info/lang.html) as well as generating [Graphviz plots](https://graphviz.org/) and [Gnuplot](http://www.gnuplot.info/) histograms. `make gallery` will produce a bunch of these.
- There are also some additional scripts for producing CSV files suitable for validation, visualization and further processing. `make tests` to see them in action.
