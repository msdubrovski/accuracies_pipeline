#!/bin/bash

# usage: bash pipeline_gold.sh <corpus_name> <path/to/corpus_train> <size> [<gold_name> <path/to/gold_corpus>]

# create a TB from only one corpus (parameter), of a required size (paramater)
# for the sake of tidiness, let us use a name for each corpus, also requiered as parameter
# and train parser and compute acc against gold standard
# !! call script from this same folder.

############### Preamble ##############

# PATHS ######## adjust these paths to your computer 
# gf-ud location:
PATHGF=path_to/gf-ud
# udpipe location:
CALLUDPIPE=path_to/udpipe/src/udpipe # or only 'udpipe' if you have the command
# udpipe script for evaluation
UDEVAL=path_to/accuracies_pipeline/conll17_ud_eval.py
# location of python script that trims tbs:
PYFILE=path_to/accuracies_pipeline//trim_conllu.py 
# where to store the files created in this script: # maybe this could be another command line argument??
PATHOUT=path_to/accuracies_pipeline//data_aux
# file to store results
ACCUFILE=${PATHOUT}/results.csv
# Gold treebank to use as default, name and location:
GOLD_NAME_DEFAULT=ewt
GOLD_DEFAULT=path_to/accuracies_pipeline/data_source/en_ewt-ud-test.conllu

## creates a name:
NAME=auxfiles-${corpus}_${N}

## parse in-line arguments
corpus=$1   # name of corpus
train=$2    # train file (assumes test file is named the same except for 'train')
N=$3        # number of trees to take
# gold TB to use:
if [ $# -lt 5 ]; then # sets gold to default if none
    gold_name=$GOLD_NAME_DEFAULT
    gold=$GOLD_DEFAULT
else 
    gold_name=$4    # if provided, gold name
    gold=$5         # if provided, gold file location
fi

################ Pipeline ##########################
echo " ###################################################################
            --- Starting pipe with $N trees, from corpus $corpus"

## trim file:
#-- python3 $PYFILE <corpus>.conllu <size> <outputfile>.conllu
python3 $PYFILE $train $N $PATHOUT/$NAME-TB.conllu
## train parser:
#-- cat <trainfile>.conllu | udpipe --tokenizer none --tagger none --train <parser>.udpipe
cat $PATHOUT/$NAME-TB.conllu | $CALLUDPIPE --tokenizer none --tagger none --train $PATHOUT/$NAME.udpipe
## test parser
#-- cat  <testfile>.conllu | udpipe --parse <parser>.udpipe ><nameofparsedfile>.conllu
test="${train/train/test}" #replaces 'train' with 'test' in the name of file
# on test corpus 
cat $test | $CALLUDPIPE --parse $PATHOUT/$NAME.udpipe >$PATHOUT/$NAME-test-parsed.conllu
# on gold corpus
cat $gold | $CALLUDPIPE --parse $PATHOUT/$NAME.udpipe >$PATHOUT/$NAME-gold-parsed.conllu

## compute acc
echo " ###################################################################
            --- Results for corpus ${corpus} (${NAME})"
# evalutation from ud
for k in test gold; do
    evalud_k=$(python3 $UDEVAL "${!k}" $PATHOUT/$NAME-${k}-parsed.conllu | awk 'BEGIN{FS=": "}{ print $2 }')
    echo "acc UD on ${k} = ${evalud_k}"
    LINE+="${evalud_k};"
done;
## save results
echo "${NAME};${corpus};${N};${gold_name};${LINE};" >> $ACCUFILE
## clear files 
