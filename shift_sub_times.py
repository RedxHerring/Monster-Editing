# This will go into sub files and move them by a set amount of seconds dtermined by the arguemnt input

import sys

# python find_replace_line.py file_name search_text replacement_text

file_name = sys.argv[1]
secs_shift = sys.argv[2]

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

