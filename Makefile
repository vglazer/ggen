.PHONY: all test create_gallery clean

CC = gcc
CFLAGS = -ansi -pedantic -Wall -Werror -O3 -march=native

all: ggen test create_gallery

bin:
	mkdir -p $@

bin/ggen: src/ggen.c bin
	$(CC) $(CFLAGS) $< -o $@
ggen: bin/ggen

tests:
	mkdir -p $@

test: ggen tests
	etc/ggen.sh --graph-type exponential --v 10 --density 0 --seed 42 --graph-dir tests
	etc/graph2edges.sh tests/graph_exponential-10-0-42.txt
	etc/edges2degrees.sh 10 tests/edges_exponential-10-0-42.csv
	etc/laplacian.sh tests/edges_exponential-10-0-42.csv tests/degrees_exponential-10-0-42.csv
	etc/validate_laplacian.sh tests/laplacian_exponential-10-0-42.csv tests/edges_exponential-10-0-42.csv tests/degrees_exponential-10-0-42.csv --verbose
	etc/stats2counts.sh tests/stats_exponential-10-0-42.txt
	etc/edges2neato.sh 10 tests/edges_exponential-10-0-42.csv
	etc/dot2pdf.sh tests/neato_exponential-10-0-42.dot
	diff -s tests/degree_counts_exponential-10-0-42.csv tests/counts_exponential-10-0-42.csv
	etc/ggen.sh --graph-type exponential --v 10 --density 500 --seed 42 --graph-dir tests
	etc/graph2edges.sh tests/graph_exponential-10-500-42.txt
	etc/edges2degrees.sh 10 tests/edges_exponential-10-500-42.csv
	etc/laplacian.sh tests/edges_exponential-10-500-42.csv tests/degrees_exponential-10-500-42.csv
	etc/validate_laplacian.sh tests/laplacian_exponential-10-500-42.csv tests/edges_exponential-10-500-42.csv tests/degrees_exponential-10-500-42.csv
	etc/stats2counts.sh tests/stats_exponential-10-500-42.txt
	etc/edges2neato.sh 10 tests/edges_exponential-10-500-42.csv
	etc/dot2pdf.sh tests/neato_exponential-10-500-42.dot
	diff -s tests/degree_counts_exponential-10-500-42.csv tests/counts_exponential-10-500-42.csv
	etc/ggen.sh --graph-type exponential --v 100 --density 500 --seed 42 --graph-dir tests
	etc/graph2edges.sh tests/graph_exponential-100-500-42.txt
	etc/edges2degrees.sh 100 tests/edges_exponential-100-500-42.csv
	etc/laplacian.sh tests/edges_exponential-100-500-42.csv tests/degrees_exponential-100-500-42.csv
	etc/validate_laplacian.sh tests/laplacian_exponential-100-500-42.csv tests/edges_exponential-100-500-42.csv tests/degrees_exponential-100-500-42.csv
	etc/stats2counts.sh tests/stats_exponential-100-500-42.txt
	etc/edges2dot.sh 100 tests/edges_exponential-100-500-42.csv neato 30 true point 0.05
	etc/dot2pdf.sh tests/neato_exponential-100-500-42.dot
	diff -s tests/degree_counts_exponential-100-500-42.csv tests/counts_exponential-100-500-42.csv
	etc/ggen.sh --graph-type power --v 10 --density 500 --seed 42 --graph-dir tests
	etc/graph2edges.sh tests/graph_power-10-500-42.txt
	etc/edges2degrees.sh 10 tests/edges_power-10-500-42.csv
	etc/laplacian.sh tests/edges_power-10-500-42.csv tests/degrees_power-10-500-42.csv
	etc/validate_laplacian.sh tests/laplacian_power-10-500-42.csv tests/edges_power-10-500-42.csv tests/degrees_power-10-500-42.csv
	etc/stats2counts.sh tests/stats_power-10-500-42.txt
	etc/edges2neato.sh 10 tests/edges_power-10-500-42.csv
	etc/dot2pdf.sh tests/neato_power-10-500-42.dot
	diff -s tests/degree_counts_power-10-500-42.csv tests/counts_power-10-500-42.csv
	etc/ggen.sh --graph-type power --v 100 --density 500 --seed 42 --graph-dir tests
	etc/graph2edges.sh tests/graph_power-100-500-42.txt
	etc/edges2degrees.sh 100 tests/edges_power-100-500-42.csv
	etc/laplacian.sh tests/edges_power-100-500-42.csv tests/degrees_power-100-500-42.csv
	etc/validate_laplacian.sh tests/laplacian_power-100-500-42.csv tests/edges_power-100-500-42.csv tests/degrees_power-100-500-42.csv
	etc/stats2counts.sh tests/stats_power-100-500-42.txt
	etc/edges2dot.sh 100 tests/edges_power-100-500-42.csv neato 30 true point 0.05
	etc/dot2pdf.sh tests/neato_power-100-500-42.dot
	diff -s tests/degree_counts_power-100-500-42.csv tests/counts_power-100-500-42.csv
	etc/ggen.sh --graph-type geometric --v 10 --density 500 --seed 42 --graph-dir tests
	etc/graph2edges.sh tests/graph_geometric-10-500-42.txt
	etc/edges2degrees.sh 10 tests/edges_geometric-10-500-42.csv
	etc/laplacian.sh tests/edges_geometric-10-500-42.csv tests/degrees_geometric-10-500-42.csv
	etc/validate_laplacian.sh tests/laplacian_geometric-10-500-42.csv tests/edges_geometric-10-500-42.csv tests/degrees_geometric-10-500-42.csv
	etc/stats2counts.sh tests/stats_geometric-10-500-42.txt
	etc/edges2neato.sh 10 tests/edges_geometric-10-500-42.csv
	etc/dot2pdf.sh tests/neato_geometric-10-500-42.dot
	diff -s tests/degree_counts_geometric-10-500-42.csv tests/counts_geometric-10-500-42.csv
	etc/ggen.sh --graph-type geometric --v 100 --density 500 --seed 42 --graph-dir tests
	etc/graph2edges.sh tests/graph_geometric-100-500-42.txt
	etc/edges2degrees.sh 100 tests/edges_geometric-100-500-42.csv
	etc/laplacian.sh tests/edges_geometric-100-500-42.csv tests/degrees_geometric-100-500-42.csv
	etc/validate_laplacian.sh tests/laplacian_geometric-100-500-42.csv tests/edges_geometric-100-500-42.csv tests/degrees_geometric-100-500-42.csv
	etc/stats2counts.sh tests/stats_geometric-100-500-42.txt
	etc/edges2dot.sh 100 tests/edges_geometric-100-500-42.csv neato 30 true point 0.05
	etc/dot2pdf.sh tests/neato_geometric-100-500-42.dot
	diff -s tests/degree_counts_geometric-100-500-42.csv tests/counts_geometric-100-500-42.csv

gallery:
	mkdir -p $@

create_gallery: ggen gallery
	etc/ggen.sh --graph-type exponential --v 10 --density 200 --seed 1 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type exponential --v 10 --density 200 --seed 2 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type exponential --v 10 --density 200 --seed 3 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type exponential --v 10 --density 500 --seed 1 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type exponential --v 10 --density 500 --seed 2 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type exponential --v 10 --density 500 --seed 3 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type power --v 10 --density 200 --seed 1 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type power --v 10 --density 200 --seed 2 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type power --v 10 --density 200 --seed 3 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type power --v 10 --density 500 --seed 1 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type power --v 10 --density 500 --seed 2 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type power --v 10 --density 500 --seed 3 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type geometric --v 10 --density 200 --seed 1 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type geometric --v 10 --density 200 --seed 2 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type geometric --v 10 --density 200 --seed 3 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type geometric --v 10 --density 500 --seed 1 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type geometric --v 10 --density 500 --seed 2 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type geometric --v 10 --density 500 --seed 3 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type exponential --v 20 --density 100 --seed 1 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type exponential --v 20 --density 100 --seed 2 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type exponential --v 20 --density 100 --seed 3 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type power --v 20 --density 100 --seed 1 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type power --v 20 --density 100 --seed 2 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type power --v 20 --density 100 --seed 3 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type geometric --v 20 --density 100 --seed 1 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type geometric --v 20 --density 100 --seed 2 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type geometric --v 20 --density 100 --seed 3 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type exponential --v 30 --density 200 --seed 1 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type exponential --v 30 --density 200 --seed 2 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type exponential --v 30 --density 200 --seed 3 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type exponential --v 30 --density 500 --seed 1 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type exponential --v 30 --density 500 --seed 2 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type exponential --v 30 --density 500 --seed 3 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type power --v 30 --density 200 --seed 1 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type power --v 30 --density 200 --seed 2 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type power --v 30 --density 200 --seed 3 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type power --v 30 --density 500 --seed 1 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type power --v 30 --density 500 --seed 2 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type power --v 30 --density 500 --seed 3 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type geometric --v 30 --density 200 --seed 1 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type geometric --v 30 --density 200 --seed 2 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type geometric --v 30 --density 200 --seed 3 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type geometric --v 30 --density 500 --seed 1 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type geometric --v 30 --density 500 --seed 2 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type geometric --v 30 --density 500 --seed 3 --graph-dir gallery --hist --plot
	etc/ggen.sh --graph-type exponential --v 100 --density 500 --seed 1 --graph-dir gallery --hist --plot

clean:
	rm -rf bin tests gallery
