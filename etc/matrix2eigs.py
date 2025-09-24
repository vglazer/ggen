import sys
import numpy as np
import os
import re

EIGENVALUE_TOLERANCE = 1e-12

def load_matrix(file_path):
    """
    Loads a matrix from a CSV file.

    Args:
        file_path (str): The path to the CSV file containing the matrix.

    Returns:
        np.ndarray: The loaded matrix as a NumPy array.
    """
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"File not found: {file_path}")
    return np.loadtxt(file_path, delimiter=',')

def extract_signature(file_path, pattern):
    """
    Extracts a signature from a filename based on a regex pattern.

    Args:
        file_path (str): The full path to the file.
        pattern (str): The regex pattern to match against the filename.

    Returns:
        str: The extracted signature.

    Raises:
        ValueError: If the filename does not match the expected pattern.
    """
    filename = os.path.basename(file_path)
    match = re.match(pattern, filename)
    if not match:
        raise ValueError(f"Filename '{filename}' does not match expected pattern '{pattern}'")
    return match.group(1)

def compute_num_spanning_trees(eigenvalues, num_vertices, num_connected_components):
    """
    Computes the number of spanning trees in a graph.

    Args:
        eigenvalues (np.ndarray): Sorted eigenvalues of the Laplacian matrix.
        num_vertices (int): The number of vertices in the graph.
        num_connected_components (int): The number of connected components in the graph.

    Returns:
        int: The number of spanning trees. Returns 0 for disconnected graphs or invalid inputs.
    """
    if num_connected_components > 1:
        return 0  # A disconnected graph has no spanning trees

    if num_vertices == 0:
        return 0  # No vertices, no spanning trees

    if num_vertices == 1:
        return 1  # A single vertex graph has 1 spanning tree (itself)

    # Sort eigenvalues to ensure the smallest is first
    sorted_eigenvalues = np.sort(eigenvalues)

    # Spectral gap is the Fiedler value (2nd smallest eigenvalue), because the smallest eigenvalue is 0
    spectral_gap = sorted_eigenvalues[1]
    print(f"Spectral gap: {spectral_gap}")

    # Kirchhoff's Matrix Tree Theorem: (1/n) * product of (n-1) non-zero eigenvalues.
    non_zero_eigenvalues_for_product = sorted_eigenvalues[~np.isclose(sorted_eigenvalues, 0, atol=EIGENVALUE_TOLERANCE)]

    # For a connected graph, we expect exactly num_vertices - 1 non-zero eigenvalues.
    if len(non_zero_eigenvalues_for_product) != num_vertices - 1:
        return 0

    product_of_non_zero_eigenvalues = np.prod(non_zero_eigenvalues_for_product)
    num_spanning_trees = product_of_non_zero_eigenvalues / num_vertices

    # The number of spanning trees must be an integer.
    return round(num_spanning_trees)

def process_laplacian(laplacian_path, perform_check=False):
    """
    Computes and prints various spectral properties of a graph given its Laplacian matrix,
    and saves the eigenvalues to a file.

    Args:
        laplacian_path (str): The path to the Laplacian matrix CSV file.
        perform_check (bool): Whether to perform consistency checks.

    Returns:
        str: The path to the output file containing the eigenvalues.
    """
    laplacian_matrix = load_matrix(laplacian_path)
    num_vertices = laplacian_matrix.shape[0]

    # Compute all eigenvalues and eigenvectors in a single call
    eigenvalues, eigenvectors = np.linalg.eigh(laplacian_matrix)

    if perform_check:
        # Consistency checks for L = D - A:
        # - off-diagonal entries sum to 2*|E|
        # - eigenvalues add up to the trace, which equals the sum of the degrees
        trace = np.trace(laplacian_matrix)
        print(f"Sum of degrees (trace of Laplacian): {trace}")

        two_E = np.sum(np.abs(laplacian_matrix)) - trace
        print(f"2 * |E| (from off-diagonals): {two_E}")

        eig_sum = np.sum(eigenvalues)
        print(f"Sum of eigenvalues: {eig_sum}")

        if not np.isclose(two_E, trace, atol=EIGENVALUE_TOLERANCE):
            print(f"Warning: 2 * |E| from off-diagonals ({two_E}) does not match sum of degrees ({trace}).")
        if not np.isclose(trace, eig_sum, atol=EIGENVALUE_TOLERANCE):
            print(f"Warning: Sum of degrees ({trace}) does not match sum of eigenvalues ({eig_sum}).")

    num_connected_components = np.sum(np.isclose(eigenvalues, 0, atol=EIGENVALUE_TOLERANCE))
    print(f"Number of connected components: {int(num_connected_components)}")

    num_spanning_trees = compute_num_spanning_trees(eigenvalues, num_vertices, num_connected_components)
    print(f"Number of spanning trees: {int(num_spanning_trees)}")

    signature = extract_signature(laplacian_path, r"laplacian_(.+)\.csv$")
    output_dir = os.path.dirname(laplacian_path)

    # Save eigenvalues to a CSV file
    eigenvalues_output_filename = f"eigs_{signature}.csv"
    eigenvalues_output_path = os.path.join(output_dir, eigenvalues_output_filename)
    with open(eigenvalues_output_path, 'w') as f:
        f.write(f"{','.join(map(str, eigenvalues))}\n")
    print(f"{eigenvalues_output_path}")

    # Save eigenvectors to a CSV file
    eigenvectors_output_filename = f"eigvects_{signature}.csv"
    eigenvectors_output_path = os.path.join(output_dir, eigenvectors_output_filename)
    np.savetxt(eigenvectors_output_path, eigenvectors.T, delimiter=',') # Transpose to have eigenvectors as rows
    print(f"{eigenvectors_output_path}")

if __name__ == "__main__":
    script_name = os.path.basename(sys.argv[0])

    def usage():
        print(f"Usage: {script_name} <path_to_laplacian_csv> [--check]")
        sys.exit(1)

    # Parse arguments
    laplacian_file_path = None
    perform_check = False

    args = sys.argv[1:]
    i = 0
    while i < len(args):
        if args[i] == "--check":
            perform_check = True
            i += 1
        elif laplacian_file_path is None:
            laplacian_file_path = args[i]
            i += 1
        else:
            usage()

    if laplacian_file_path is None:
        usage()

    try:
        process_laplacian(laplacian_file_path, perform_check)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)
