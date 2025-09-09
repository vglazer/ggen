CC=gcc
CFLAGS=-ansi -pedantic -Wall -Werror -O3 -march=native

all: ggen tests gallery

ggen: src/ggen.c bin_dir
	$(CC) $(CFLAGS) $< -o bin/$@

.PHONY: bin_dir
bin_dir:
	mkdir -p bin

.PHONY: tests_dir
tests_dir:
	mkdir -p tests

.PHONY: tests
tests: tests_dir
	etc/ggen.sh 2 100 500 42 tests
	etc/graph2edges.sh tests/graph_exponential-100-500-42.txt
	etc/edges2degrees.sh tests/edges_exponential-100-500-42.csv
	etc/stats2counts.sh tests/stats_exponential-100-500-42.txt
	diff -s tests/degree_counts_exponential-100-500-42.csv tests/counts_exponential-100-500-42.csv
	etc/ggen.sh 3 100 500 42 tests
	etc/graph2edges.sh tests/graph_power-100-500-42.txt
	etc/edges2degrees.sh tests/edges_power-100-500-42.csv
	etc/stats2counts.sh tests/stats_power-100-500-42.txt
	diff -s tests/degree_counts_power-100-500-42.csv tests/counts_power-100-500-42.csv
	etc/ggen.sh 4 100 500 42 tests
	etc/graph2edges.sh tests/graph_geometric-100-500-42.txt
	etc/edges2degrees.sh tests/edges_geometric-100-500-42.csv
	etc/stats2counts.sh tests/stats_geometric-100-500-42.txt
	diff -s tests/degree_counts_geometric-100-500-42.csv tests/counts_geometric-100-500-42.csv

.PHONY: gallery_dir
gallery_dir:
	mkdir -p gallery

.PHONY: gallery
gallery: gallery_dir
	etc/ggen.sh 2 10 500 1 gallery
	etc/ggen.sh 2 10 500 2 gallery
	etc/ggen.sh 2 10 500 3 gallery
	etc/ggen.sh 3 10 500 1 gallery
	etc/ggen.sh 3 10 500 2 gallery
	etc/ggen.sh 3 10 500 3 gallery
	etc/ggen.sh 4 10 500 1 gallery
	etc/ggen.sh 4 10 500 2 gallery
	etc/ggen.sh 4 10 500 3 gallery
	etc/ggen.sh 2 30 500 1 gallery
	etc/ggen.sh 2 30 500 2 gallery
	etc/ggen.sh 2 30 500 3 gallery
	etc/ggen.sh 3 30 500 1 gallery
	etc/ggen.sh 3 30 500 2 gallery
	etc/ggen.sh 3 30 500 3 gallery
	etc/ggen.sh 4 30 500 1 gallery
	etc/ggen.sh 4 30 500 2 gallery
	etc/ggen.sh 4 30 500 3 gallery

.PHONY: clean
clean:
	rm -rf bin tests gallery
