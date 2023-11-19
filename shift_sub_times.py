# This will go into sub files and move them by a set amount of seconds dtermined by the arguemnt input

import sys
import datetime

# python find_replace_line.py file_name search_text replacement_text

file_name = sys.argv[1]
secs_shift = float(sys.argv[2])
# file_name = "Subs/NFLX-Subs/ita/Ep20.ass"
# secs_shift = 3.5
'''
Aiming to adjust text after:
[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
starting with
'''
with open(file_name,'r') as file:
    # Reading the content of the file
    # using the read() function and storing
    # them in a new variable
    lines = file.readlines()
    lines_out = lines
    # Loop through lines looking for lines containing text
    for k,line in enumerate(lines) :
        if line.find("Dialogue:") != -1 :
            line_list = line.split(',')
            t_start = datetime.datetime.strptime(line_list[1],'%H:%M:%S.%f') + datetime.timedelta(0,secs_shift)
            t_end = datetime.datetime.strptime(line_list[2],'%H:%M:%S.%f') + datetime.timedelta(0,secs_shift)
            t_start_str = t_start.strftime("%H:%M:%S.%f")
            t_end_str = t_end.strftime("%H:%M:%S.%f")
            line_list[1] = t_start_str[1:-4]
            line_list[2] = t_end_str[1:-4]
            lines_out[k] = ','.join(line_list)

with open(file_name,'w') as file:
    file.writelines(lines_out)

