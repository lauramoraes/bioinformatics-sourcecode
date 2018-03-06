#!/bin/bash

# check to see if all required arguments were provided
if [ $# -eq 3 ]; then
    # assign the provided arguments to variables
    number_of_cycles=$1
    plot_title=$2
    input_data=$3
else
    # assign the default values to variables
    number_of_cycles=3
    plot_title="Hello Code Ocean"
    input_data="../data/sample-data.txt"
fi

echo "Running main.m with arguments $plot_title, $number_of_cycles, $input_data"
matlab -nodisplay -nosoftwareopengl -r \
  "run()"
