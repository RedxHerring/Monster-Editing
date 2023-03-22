# Simple python function to add lines from one subtitle file to another.
import sys
import datetime
from difflib import SequenceMatcher # will use to check if string is already present

# python add_titlesnsigns.py main_sub titles_sub
# e.g.
# python add_titlesnsigns.py Subs/NFLX-Subs/eng/Ep01.ass Subs/Full-Subs/eng/Ep01-titlesnsigns.ass


def similarity(a, b):
    return SequenceMatcher(None, a, b).ratio()


main_sub = sys.argv[1]
titles_sub = sys.argv[2]

time_thresh = 5 # seconds within which we'll look for the title line
added_lines = 0 # iterate when we insert instead of replacing, ie when replacing one line with multiple lines
with open(main_sub,'r') as mainf, open(titles_sub, 'r') as titlesf:
    # Reading the content of the file
    # using the read() function and storing
    # them in a new variable
    linest = titlesf.readlines()
    linesm = mainf.readlines()
    lines_out = linesm.copy()
    
    # Loop through titles lines
    for kt,linet in enumerate(linest): # loop through lines in titles file
        if linet.find("Dialogue:") != -1: # have arrived at a dialodue line
            line_list = linet.split(',')
            # Find start time of title sub line
            t_startt = datetime.datetime.strptime(line_list[1],'%H:%M:%S.%f') 
            line_list = linet.split(',,') # assume nothing in Effect column
            text_t = line_list[-1].lower() # actual subtitle text, force lowercase
            # Now loop through main file to check if a similaar sub is already there, and either replace or insert
            inserted = False
            for km,linem in enumerate(linesm) :
                if linem.find("Dialogue:") != -1:
                    line_list = linem.split(',')
                    # Find start time of title sub line
                    t_startm = datetime.datetime.strptime(line_list[1],'%H:%M:%S.%f') 
                    line_list = linem.split(',,') # assume nothing in Effect column
                    text_m = line_list[-1].lower()
                    if abs((t_startm - t_startt).total_seconds()) < time_thresh:
                        if similarity(text_t,text_m) > .3:
                            lines_out.pop(km+added_lines) # remove this line sice we're adding a new version
                            added_lines -= 1
                    if t_startm > t_startt and not inserted:
                        lines_out.insert(km+added_lines+1,text_t)
                        added_lines += 1
                        inserted = True
                    if (t_startm - t_startt).total_seconds() > time_thresh:
                        break

with open(main_sub,'w') as file:
    file.writelines(lines_out)


