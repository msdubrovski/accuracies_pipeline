# accuracies_pipeline

## ```pipeline_gold.sh``` script

Bash file that takes a UD treebank, trims it, trains a udpipe parser, tests and evalutates it against a gold standard.

### Requisites
Uses gf-ud, udpipe and two python scripts.
- ```gf-ud``` is available at https://github.com/GrammaticalFramework/gf-ud
- ```udpipe``` is available at https://github.com/ufal/udpipe
- ```trim_conllu.py``` is a Python script that trims treebanks to a required number of trees. It is part of this repo and it is documented below.
- ```conll17_ud_eval.py``` is part of https://github.com/ufal/conll2017, a collection of python scripts made available for working with UD-treebanks. This file computes the LAS accuracy, as defined in CoNLL17 UD Shared Task evaluation metrics.


### Preamble:
It needs adjusting the following paths and files:

- ```PATHGF``` : location of gf-ud folder.
- ```CALLUDPIPE``` : call to udpipe, can be only udpipe, or /src/udpipe, etc.
- ```UDEVAL``` : udpipe script for evaluation.
- ```PYFILE``` : location of ```trim_goldenfile.py```, python file that trims conllu files.
- ```PATHOUT``` : where to store  output files.
- ```ACCUFILE``` : path to .csv file where accuracies are stored (appended).
- ```GOLD_NAME_DEFAULT``` and ```GOLD_DEFAULT```: default gold treebank to use, name and location, respectively.

The last variable of the preamble is ```NAME```, a common name for all intermediary and outputs created in the pipeline. It does not need to be changed, but is easily done.

Command-line (positional) arguments:
- ```<corpus>``` : given name for the corpus
- ```<train>``` : train-file of corpus. test-file should be in the same location with matching name (e.g sometb-train.conllu and sometb-test.conllu)
- ```<N>``` : wanted size (number of trees) of treebank
- ```(<gold_name>)``` : (optional) name of gold treebank to compare against. If none, uses default, "ewt".
- ```(<gold>) ``` (optional) path to gold treebank, if none, uses default, as specified above.



--------------------

It produces the following files (stored in ```$PATHDATA```):
- ```accuracies.csv``` : results are saved in this file in comma-separated format. It is never overwritten.
- ```$NAME.udpipe``` : udpipe parser file.
- ```$NAME_TB.conllu``` : complete collected treebank in conllu format.
- ```$NAME-train.gft``` and ```-test.gft``` : split files in gf format (from wordnet-gf data).
- ```$NAME-train.conllu``` and ```-test.conllu``` : ud-labelled files (with gf-ud).
- ```$NAME-test-udpipe.conllu``` : test file with trained parser labels.
- ```$NAME-gold-udpipe.conllu``` : gold file with trained parser labels.

All the steps are depicted in the following flow chart:
![](flochart.png)

## ```trim_goldenfile.py``` script
python script that opens file in conllu format, selects a fixed number of sentences (either randomly or ordered) and writes them into a new conllu file.
flags:
- ```--infile``` : input file.
- ```--outfile``` : name of output file. 
- ```--randomness``` : wether to select randomly, default False,
- ```p n``` : parameters for P proportion of native trees out of N total trees. (might change).

