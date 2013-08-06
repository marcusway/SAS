__author__ = 'margaretsheridan'

def freq_file_to_dict(f):
    """
    Reads in a norm_freq file and returns a dictionary
    where each subject number is a key for a sub-dictionary
    that contains the relative power at each individual frequency.

    :param f: a file name 
    :return freq_dict: a dictionary with frequency, power
                        key, value pairs
    """
    freq_dict = {}
    with open(f,'r') as data:
        # The first row is all subject numbers
        #(and a 'Freqeuency' header)
        subNums = data.readline().split()[1:]
        # Make a subdictionary for each subject
        for sub in subNums:
            if sub not in freq_dict:
                freq_dict[sub] = {}

        print "There are ", len(freq_dict), "subjects."
        print freq_dict

        # Now each subject has sub dictionary that will be populated
        # with keys corresponding to frequencies from the first column
        # and entries corresponding to the relative power at the frequency

        for line in data:
            split_line = line.split()
            print "this line is ", len(split_line), "things long."
            i = 1

            for sub in freq_dict:
                freq_dict[sub][split_line[0]] = split_line[i]
                i += 1

    return freq_dict

    
def sub_files_to_dicts(globList, savefile=False):
    """
    This function is going to take all of the
    files given by the glob list and turn
    it into a list holding all of the data

    :param globList: A string i.e, 'ADHD*.csv'
                    to specify which files to
                    process
    """
    import csv
    import os
    import cPickle as pickle
    import glob
    import collections

    bands = {'delta': {'low': 1, 'high': 5}, 'theta': {'low': 5, 'high': 8},
             'alpha': {'low': 8, 'high': 12}, 'beta': {'low': 12, 'high': 30}}



    big_list = []
    sub_dict = {}

    for fileName in glob.glob(globList):
        # get condition/region info from file name



        regions = ['LF', 'RF', 'LP', 'RP', 'O']
        conditions = ['eo', 'ec']

        inFile = open(fileName, "rU")
        reader = csv.DictReader(inFile)

        # Build the general dictionary structure, which will be 
        # indexed by subject ID #, condition (eo/ec), region,
        # and frequency band in that order

        for subject in reader:
            if subject['sID'] not in sub_dict:
                sub_dict[subject['sID']] = {}
            for condition in conditions:
                if condition not in sub_dict[subject['sID']]:
                    sub_dict[subject['sID']][condition] = {}
                for region in regions:
                    if region not in sub_dict[subject['sID']][condition]:
                        sub_dict[subject['sID']][condition][region] = {}
                    for band in bands:
                        if band not in sub_dict[subject['sID']][condition][region]:
                            sub_dict[subject['sID']][condition][region][band] = ''

            # Populate the dictionary by summing over relative power values given
            # in the input file over the ranges given by the bands dictionary above

            condition, region = os.path.basename(fileName)[14:16], os.path.basename(fileName)[16:18].strip(".")
            for band in bands:
                sub_dict[subject['sID']][condition][region][band] = \
                    sum(float(subject[freq]) for freq in subject
                        if freq and freq != 'sID' and bands[band]['low'] <= float(freq) < bands[band]['high'])

    ordered_sub_dict = collections.OrderedDict(sorted(sub_dict.iteritems(), key=lambda x: x[0]))
    if savefile:
        out = open("rel_power_dict.p", "w")
        pickle.dump(ordered_sub_dict, out)
        out.close()

    return ordered_sub_dict



        # Now for every subject, I want to
        # Get the power in each band.  Moreover,
        # I should like to

def write_thing(sub_dict, subList=None):

    """
    Writes the contents of a sub_dict dictionary
    of the form output by sub_files_to_dicts to 
    a .csv file. Optional parameter subList restricts
    the output to only include subjects whose ID numbers
    are included in the list. 
    """

    import sys

    if subList == None:
        subList = sub_dict.keys()

    bands = ['delta', 'theta', 'alpha', 'beta']
    regions = ['LF', 'RF', 'LP', 'RP', 'O']
    conditions = ['eo', 'ec']


    print 'sID,',
    for condition in conditions:
        for region in regions:
            for band in bands:
                sys.stdout.write(condition + "_" + region + "_" + band + ",")
    sys.stdout.write("\n")

    for subject in subList:
        sys.stdout.write(subject + ",")
        for condition in conditions:
            for region in regions:
                for band in bands:
                    sys.stdout.write("%s," %(sub_dict[subject][condition][region][band]))
        sys.stdout.write("\n")



if __name__ == '__main__':


    import cPickle as pickle
    from sys import argv

    dicts = sub_files_to_dicts(argv[1])
    write_thing(dicts)

