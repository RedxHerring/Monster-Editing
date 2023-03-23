# Simple python function to add lines from one subtitle file to another.
import sys
import datetime
# using https://stackoverflow.com/questions/65199011/is-there-a-way-to-check-similarity-between-two-full-sentences-in-python
import spacy
nlp = spacy.load("en_core_web_lg") # large language model
# python add_titlesnsigns.py main_sub titles_sub
# e.g.
# python add_titlesnsigns.py Subs/NFLX-Subs/eng/Ep01.ass Subs/Full-Subs/eng/Ep01-titlesnsigns.ass

def num_less_than(sequence, value):
    return len([item for item in sequence if item < value])

main_sub = sys.argv[1]
titles_sub = sys.argv[2]

time_thresh = 5 # seconds within which we'll look for the title line
added_lines = 0 # iterate when we insert instead of replacing, ie when replacing one line with multiple lines
popped_lines = []
line_times = []
idx0 = -1 # index of first dialogue line
with open(main_sub,'r') as mainf, open(titles_sub, 'r') as titlesf:
    # Reading the content of the file
    # using the read() function and storing
    # them in a new variable
    linest = titlesf.readlines()
    linesm = mainf.readlines()
    lines_out = linesm.copy()
    
    # Loop through titles lines
    for kt,linet in enumerate(linest): # loop through lines in titles file
        if linet.find("Dialogue:") != -1: # have arrived at a dialogue line
            line_list = linet.split(',')
            # Find start time of title sub line
            t_startt = datetime.datetime.strptime(line_list[1],'%H:%M:%S.%f') 
            t_start_numt = t_startt.minute*60 + t_startt.second + t_startt.microsecond/1e6
            line_list = linet.split(',,') # assume nothing in Effect column
            text_t = line_list[-1] # actual subtitle text
            doct = nlp(text_t.lower()) # force lowercase
            # Now loop through main file to check if a similaar sub is already there, and either replace or insert
            inserted = False
            for km,linem in enumerate(linesm) :
                if linem.find("Dialogue:") != -1:
                    if idx0 == -1:
                        idx0 = km # set index that we can use later
                    line_list = linem.split(',')
                    # Find start time of title sub line
                    t_startm = datetime.datetime.strptime(line_list[1],'%H:%M:%S.%f') 
                    line_times.append(t_startm.minute*60 + t_startm.second + t_startm.microsecond/1e6)
                    line_list = linem.split(',,') # assume nothing in Effect column
                    text_m = line_list[-1].lower()
                    docm = nlp(text_m)
                    if abs((t_startm - t_startt).total_seconds()) < time_thresh:
                        if doct.similarity(docm) > .5 and km not in popped_lines:
                            idxi = idx0 + num_less_than(line_times, line_times[-1])
                            line_times.pop(-1)
                            lines_out.pop(idxi) # remove this line since we're adding a new version
                            popped_lines.append(km)
                    if t_startm > t_startt and not inserted:
                        idxi = idx0 + num_less_than(line_times, t_start_numt)
                        lines_out.insert(idxi,linet)
                        line_times.append(t_start_numt)
                        inserted = True
                    if (t_startm - t_startt).total_seconds() > time_thresh:
                        break

with open(main_sub,'w') as file:
    file.writelines(lines_out)


