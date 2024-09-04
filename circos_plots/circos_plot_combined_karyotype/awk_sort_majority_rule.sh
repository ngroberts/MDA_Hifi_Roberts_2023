#!/bin/bash

#!/bin/bash

# Check if a filename is provided as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

# Store the filename provided as an argument
filename=$1

# Step 1: Sort the file by the highest number of occurrences of the same value in column 1 within the same value of column 5
sorted_file=$(awk '{print $1}' "$filename" | sort | uniq -c | sort -nr | awk '{print $2}')_sorted.txt

# Step 2: Extract only unique entries from column 1 while maintaining the sorting order
awk '!seen[$1]++' "$filename" > unique_entries.txt

# Step 3: Group the entries by the value in column 4
awk '{
    key = $4;
    data[key] = data[key] $0 "\n"
}
END {
    for (key in data) {
        print data[key]
    }
}' unique_entries.txt > grouped_entries.txt

# Step 4: Sort the grouped entries in increasing numerical order of column 5
sort -k4,4 -k5n grouped_entries.txt | awk NF > final_sorted_output.txt

# Remove temporary files
rm "$sorted_file" unique_entries.txt grouped_entries.txt

echo "Sorting completed. Output saved to final_sorted_output.txt"
