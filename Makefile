CC=gcc
CFLAGS=-ansi -pedantic -Wall -Werror -O3 -march=native

all: ggen tests gallery

ggen: src/ggen.c bin_dir
	$(CC) $(CFLAGS) $< -o bin/$@

.PHONY: bin_dir
bin_dir:
	mkdir -p bin

.PHONY: tests
tests: ggen tests_dir
	etc/ggen.sh 2 10 500 42 tests
	etc/graph2edges.sh tests/graph_exponential-10-500-42.txt
	etc/edges2degrees.sh 10 tests/edges_exponential-10-500-42.csv
	etc/stats2counts.sh tests/stats_exponential-10-500-42.txt
	etc/edges2neato.sh tests/edges_exponential-10-500-42.csv
	etc/dot2pdf.sh tests/neato_exponential-10-500-42.dot
	diff -s tests/degree_counts_exponential-10-500-42.csv tests/counts_exponential-10-500-42.csv
	etc/ggen.sh 2 100 500 42 tests
	etc/graph2edges.sh tests/graph_exponential-100-500-42.txt
	etc/edges2degrees.sh 100 tests/edges_exponential-100-500-42.csv
	etc/stats2counts.sh tests/stats_exponential-100-500-42.txt
	etc/edges2dot.sh tests/edges_exponential-100-500-42.csv neato 30 true point 0.05
	etc/dot2pdf.sh tests/neato_exponential-100-500-42.dot
	diff -s tests/degree_counts_exponential-100-500-42.csv tests/counts_exponential-100-500-42.csv
	etc/ggen.sh 3 10 500 42 tests
	etc/graph2edges.sh tests/graph_power-10-500-42.txt
	etc/edges2degrees.sh 10 tests/edges_power-10-500-42.csv
	etc/stats2counts.sh tests/stats_power-10-500-42.txt
	etc/edges2neato.sh tests/edges_power-10-500-42.csv
	etc/dot2pdf.sh tests/neato_power-10-500-42.dot
	diff -s tests/degree_counts_power-10-500-42.csv tests/counts_power-10-500-42.csv
	etc/ggen.sh 3 100 500 42 tests
	etc/graph2edges.sh tests/graph_power-100-500-42.txt
	etc/edges2degrees.sh 100 tests/edges_power-100-500-42.csv
	etc/stats2counts.sh tests/stats_power-100-500-42.txt
	etc/edges2dot.sh tests/edges_power-100-500-42.csv neato 30 true point 0.05
	etc/dot2pdf.sh tests/neato_power-100-500-42.dot
	diff -s tests/degree_counts_power-100-500-42.csv tests/counts_power-100-500-42.csv
	etc/ggen.sh 4 10 500 42 tests
	etc/graph2edges.sh tests/graph_geometric-10-500-42.txt
	etc/edges2degrees.sh 10 tests/edges_geometric-10-500-42.csv
	etc/stats2counts.sh tests/stats_geometric-10-500-42.txt
	etc/edges2neato.sh tests/edges_geometric-10-500-42.csv
	etc/dot2pdf.sh tests/neato_geometric-10-500-42.dot
	diff -s tests/degree_counts_geometric-10-500-42.csv tests/counts_geometric-10-500-42.csv
	etc/ggen.sh 4 100 500 42 tests
	etc/graph2edges.sh tests/graph_geometric-100-500-42.txt
	etc/edges2degrees.sh 100 tests/edges_geometric-100-500-42.csv
	etc/stats2counts.sh tests/stats_geometric-100-500-42.txt
	etc/edges2dot.sh tests/edges_geometric-100-500-42.csv neato 30 true point 0.05
	etc/dot2pdf.sh tests/neato_geometric-100-500-42.dot
	diff -s tests/degree_counts_geometric-100-500-42.csv tests/counts_geometric-100-500-42.csv

.PHONY: tests_dir
tests_dir:
	mkdir -p tests

.PHONY: gallery
gallery: ggen gallery_dir
	etc/ggen.sh 2 10 200 1 gallery
	etc/ggen.sh 2 10 200 2 gallery
	etc/ggen.sh 2 10 200 3 gallery
	etc/ggen.sh 2 10 500 1 gallery
	etc/ggen.sh 2 10 500 2 gallery
	etc/ggen.sh 2 10 500 3 gallery
	etc/ggen.sh 3 10 200 1 gallery
	etc/ggen.sh 3 10 200 2 gallery
	etc/ggen.sh 3 10 200 3 gallery
	etc/ggen.sh 3 10 500 1 gallery
	etc/ggen.sh 3 10 500 2 gallery
	etc/ggen.sh 3 10 500 3 gallery
	etc/ggen.sh 4 10 200 1 gallery
	etc/ggen.sh 4 10 200 2 gallery
	etc/ggen.sh 4 10 200 3 gallery
	etc/ggen.sh 4 10 500 1 gallery
	etc/ggen.sh 4 10 500 2 gallery
	etc/ggen.sh 4 10 500 3 gallery
	etc/ggen.sh 2 20 100 1 gallery
	etc/ggen.sh 2 20 100 2 gallery
	etc/ggen.sh 2 20 100 3 gallery
	etc/ggen.sh 3 20 100 1 gallery
	etc/ggen.sh 3 20 100 2 gallery
	etc/ggen.sh 3 20 100 3 gallery
	etc/ggen.sh 4 20 100 1 gallery
	etc/ggen.sh 4 20 100 2 gallery
	etc/ggen.sh 4 20 100 3 gallery
	etc/ggen.sh 2 30 200 1 gallery
	etc/ggen.sh 2 30 200 2 gallery
	etc/ggen.sh 2 30 200 3 gallery
	etc/ggen.sh 2 30 500 1 gallery
	etc/ggen.sh 2 30 500 2 gallery
	etc/ggen.sh 2 30 500 3 gallery
	etc/ggen.sh 3 30 200 1 gallery
	etc/ggen.sh 3 30 200 2 gallery
	etc/ggen.sh 3 30 200 3 gallery
	etc/ggen.sh 3 30 500 1 gallery
	etc/ggen.sh 3 30 500 2 gallery
	etc/ggen.sh 3 30 500 3 gallery
	etc/ggen.sh 4 30 200 1 gallery
	etc/ggen.sh 4 30 200 2 gallery
	etc/ggen.sh 4 30 200 3 gallery
	etc/ggen.sh 4 30 500 1 gallery
	etc/ggen.sh 4 30 500 2 gallery
	etc/ggen.sh 4 30 500 3 gallery
	etc/ggen.sh 2 100 500 1 gallery

.PHONY: gallery_dir
gallery_dir:
	mkdir -p gallery

.PHONY: clean
clean:
	rm -rf bin tests gallery
