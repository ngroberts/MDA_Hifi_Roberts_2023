import os

# Function to parse SAM file and compare scaffold IDs for corresponding reads
def check_mapping(filename):
    read_pairs = {}
    with open(filename, 'r') as sam_file:
        for line in sam_file:
            if not line.startswith('@'):  # Skip headers
                fields = line.split('\t')
                read_name_parts = fields[0].rsplit('_', 1)  # Split at the last underscore
                read_name = read_name_parts[0]  # Take the part before the last underscore
                scaffold = fields[2]
                if read_name not in read_pairs:
                    read_pairs[read_name] = []  # Initialize list for each read name
                read_pairs[read_name].append(scaffold)

    # Check if any read name has different scaffold IDs
    for read_name, scaffolds in read_pairs.items():
        if len(set(scaffolds)) > 1:  # Check if more than one scaffold is mapped for the same read name
            print("Reads with name {} map to different scaffolds: {}".format(read_name, ', '.join(set(scaffolds))))

# Get the path to the SAM file from the environmental variable
sam_file_path = os.environ.get('SAM')

if sam_file_path is not None:
    check_mapping(sam_file_path)
else:
    print("Error: Environmental variable SAM is not set or points to an invalid file.")

