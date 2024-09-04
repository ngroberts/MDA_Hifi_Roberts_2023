from collections import defaultdict

# Function to parse the data file and return grouped data
def group_and_sort_data(filename):
    grouped_data = defaultdict(list)

    # Read data from file
    with open(filename, "r") as file:
        for line in file:
            columns = line.strip().split()
            group_key = columns[3]
            grouped_data[group_key].append(columns)

    # Sort each group based on the numerical value in the 5th column
    for group_key, group_data in grouped_data.items():
        grouped_data[group_key] = sorted(group_data, key=lambda x: int(x[4]))

    return grouped_data

# Function to write grouped and sorted data to a file
def write_sorted_data(grouped_data, output_filename):
    with open(output_filename, "w") as file:
        for group_key in ["BX284606.5", "BX284605.5", "BX284604.4", "BX284603.4", "BX284602.5", "BX284601.5"]:
            group_data = grouped_data[group_key]
            for line in group_data:
                file.write("\t".join(line) + "\n")

# Main function
def main():
    input_filename = "links_alignments_fix.txt"
    output_filename = "sorted_data.txt"  

    # Group and sort data
    grouped_data = group_and_sort_data(input_filename)

    # Write sorted data to file
    write_sorted_data(grouped_data, output_filename)

if __name__ == "__main__":
    main()
