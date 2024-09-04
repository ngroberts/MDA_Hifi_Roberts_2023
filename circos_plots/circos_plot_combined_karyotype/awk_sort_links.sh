#!/bin/bash

#This awk command will:

#Group the dataset by the contig name in the fourth column and then sort that dataset in increasing numerical order by the 5th column.

#What happens here is that now your links file is sorted by the reference chromsome the contig aligns to and in order of the position it aligns to.

#Lastly you can output this to the proper format for the circos.config file by just pasting the output.

## awk '!seen[$1]++ {print $1}' your_sorted_unique_file.txt | paste -s -d "," > chromosome_order.txt

# The only issue with this is that it will sort simply by the earliest aligning portion of the query contig and not majority alignment.


awk '{ 
    key = $4; 
    if (!(key in data)) {
        keys[++n] = key
    } 
    data[key] = data[key] $0 "\n" 
} 
END {
    for (i = 1; i <= n; i++) {
        split(data[keys[i]], records, "\n")
        n_records = length(records)
        for (j = 1; j < n_records; j++) {
            for (k = j + 1; k <= n_records; k++) {
                split(records[j], fields1, " ")
                split(records[k], fields2, " ")
                if (fields1[5] > fields2[5]) {
                    temp = records[j]
                    records[j] = records[k]
                    records[k] = temp
                }
            }
        }
        for (j = 1; j <= n_records; j++) {
            if (records[j] != "") {
                print records[j]
            }
        }
    }
}' $1
