# Simple python function to find lines in file and replace it.
# This will look for lines containing a string, and then replace that entire line with another string
import sys

# python find_replace_line.py file_name search_text replacement_text

file_name = sys.argv[1]
search_text = sys.argv[2]
replacement_text = sys.argv[3:]
for idx in range(len(replacement_text)):
    if '\n' not in replacement_text[idx]:
        replacement_text[idx] = f'{replacement_text[idx]}\n'
added_lines = 0 # iterate when we insert instead of replacing, ie when replacing one line with multiple lines
with open(file_name,'r') as file:
    # Reading the content of the file
    # using the read() function and storing
    # them in a new variable
    lines = file.readlines()
    lines_out = lines
    # Loop through lines looking for lines contianing text
    for k,line in enumerate(lines) :
        if line.find(search_text) != -1 :
            lines_out[k] = replacement_text[0]
            if len(replacement_text) > 1:
                for iline in replacement_text[1:]:
                    lines_out.insert(k+added_lines+1,iline)
                    added_lines = added_lines + 1

with open(file_name,'w') as file:
    file.writelines(lines_out)


