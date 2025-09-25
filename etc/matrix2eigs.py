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

def process_laplacian(laplacian_path, check=False):
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

    if check:
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

    # Spectral gap is the difference between the 2nd smallest and smallest eigenvalues, which is just the
    # Fiedler value (2nd smallest eigenvalue), because the smallest is 0.
    sorted_eigenvalues = np.sort(eigenvalues)
    spectral_gap = sorted_eigenvalues[1]
    print(f"Spectral gap: {spectral_gap}")

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
    check = False

    args = sys.argv[1:]
    i = 0
    while i < len(args):
        if args[i] == "--check":
            check = True
            i += 1
        elif laplacian_file_path is None:
            laplacian_file_path = args[i]
            i += 1
        else:
            usage()

    if laplacian_file_path is None:
        usage()

    try:
        process_laplacian(laplacian_file_path, check)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)
