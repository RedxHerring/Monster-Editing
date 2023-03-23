# Simple python function to add lines from one subtitle file to another.
import sys
import datetime
import numpy as np
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
popped_lines = []
inserted_times = []
with open(main_sub,'r') as mainf, open(titles_sub, 'r') as titlesf:
    # Reading the content of the file
    # using the read() function and storing
    # them in a new variable
    linest = titlesf.readlines()
    dialinest = linest.copy()
    times_t = []
    for kt,linet in enumerate(linest): # loop through lines in titles file
        if linet.find("Dialogue:") != -1: # have arrived at a dialogue line
            line_list = linet.split(',')
            # Find start time of title sub line
            t_startt = datetime.datetime.strptime(line_list[1],'%H:%M:%S.%f') 
            times_t.append(t_startt.minute*60 + t_startt.second + t_startt.microsecond/1e6)
        else:
            dialinest.pop(0) # we know all the dialogue is at the end so we can always pop the first line
    times_t = np.asarray(times_t)
    linesm = mainf.readlines()
    lines_out = linesm.copy()
    times_m = []
    num_popped = 0
    idx1 = -1
    for km,linem in enumerate(linesm):
        if linem.find("Dialogue:") != -1:
            if idx1 == -1:
                idx1 = km
            line_list = linem.split(',')
            # Find start time of title sub line
            t_startm = datetime.datetime.strptime(line_list[1],'%H:%M:%S.%f') 
            t_start_numm = t_startm.minute*60 + t_startm.second + t_startm.microsecond/1e6
            times_m.append(t_start_numm)
            line_list = linem.split(',,') # assume nothing in Effect column
            text_m = line_list[-1]
            if len(text_m) < 20:
                text_m = '{\}{\}' + text_m + '{\}{\}' # add some chaos
            docm = nlp(text_m.lower())
            idxst = np.asarray(np.asarray(np.abs(times_t-t_start_numm) < time_thresh).nonzero())
            
            for idxt in idxst.flat:
                linet = dialinest[idxt]
                line_list = linet.split(',,') # assume nothing in Effect column
                text_t = line_list[-1] # actual subtitle text
                doct = nlp(text_t.lower()) # force lowercase
                if doct.similarity(docm) > .5:
                    idxi = km - num_popped
                    lines_out.pop(idxi)
                    times_m.pop(-1)
                    num_popped += 1
                    break # got to next km, linem
    times_m = np.asarray(times_m)
    # Now last loop to insert titles and signs lines
    
    for kt,linet in enumerate(dialinest):
        idxi = np.where(times_m>times_t[kt])[0][0]
        lines_out.insert(idx1+idxi,linet)
        times_m = np.insert(times_m,idxi,times_t[kt])


with open(main_sub,'w') as file:
    file.writelines(lines_out)


