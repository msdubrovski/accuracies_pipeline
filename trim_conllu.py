import argparse
import random
import sys, os #import re #,os,sys
import conllu

'''
Simple script that selects N sentences from a conllu file. The selection could be ordered or random.
Needs python package _conllu_
Raises a warning if it asks for more sentences than available.
Usage: python3 trim_conllu.py <infile> <size> <outfile> (-r) (-s)
'''
# define arguments
parser = argparse.ArgumentParser(description="Extracts N sentences from conllu file. Usage: python3 trim_conllu.py <infile> <size> <outfile>")
parser.add_argument("infile", type=str,
                    #default="../ud-treebanks-unpacked-selected/UD_English-EWT/en_ewt-ud-train.conllu",
                    help="conllu file to trim.")
parser.add_argument("size", type=int, #action='store_const',
                    help="size, number of sentences to extract.")
parser.add_argument("outfile", type=str,
                    #default=,
                    help="name of new file with selected sentences.")
parser.add_argument("-r", "--randomness",
                    help="whether to choose sentences randomly", action='store_true',)
parser.add_argument("-s", "--splits",
                    help="whether to split file into train and test. size becomes size of train, outfile name of train file.", action='store_true',)
args = parser.parse_args()

# funcitons
def open_conllu(filename):
    # opens a file in conllu format to python-conllu format:
    ## sentences := LIST of sentences
    with open(filename, 'r') as file:
        data = file.read()
    sentences = conllu.parse(data)
    return sentences

def write_conllu(sentences, N, filename, S=None):                   ##!
        with open(filename, 'a') as f:
            for sentence in sentences[S:N]:
                f.write(sentence.serialize())
# run
if __name__ == '__main__':
    os.system("pwd")
    open(args.outfile, 'w') # to forcce the file to be created and overwritten
    print("saving to {}".format(args.outfile))
    # get sentences:
    sentences = open_conllu(args.infile)
    if args.randomness: # if random, randomize sentences
        random.shuffle(sentences)
    # write file with first N sentences    
    write_conllu(sentences, args.size, args.outfile)
    if args.splits:                                                 ##!
        write_conllu(sentences, None, args.outfile.replace("-train.conllu","-test.conllu"), S=args.size)   ##!
    # raise a warning if there are fewer sentences than asked for:
    if len(sentences) < args.size :
        print("Obs! fewer senteces than", args.size)
    print("Done.")
    