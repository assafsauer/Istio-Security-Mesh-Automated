import csv
import sys
import pandas as pd
import re
import string
import os

# print all rows
pd.set_option('display.max_column',None)
pd.set_option('display.max_rows',None)
pd.set_option('display.max_seq_items',None)
pd.set_option('display.max_colwidth', 500)
pd.set_option('expand_frame_repr', True)

os.system('chmod 777 *.sh')
# get pod list
os.system('./create.istio.logs.sh')


# # get pod list
# os.system('./create.istio.logs.sh')

input_file = "logs.csv"
dataset = pd.read_csv(input_file, usecols=[1, 13], header=None, names=['col1', 'col12'], engine='python', dialect='excel')
df = pd.DataFrame(dataset)
for i in dataset.get('col1'):
    print(i)

df.to_csv('logs.csv', index=False)

f = open('logs.csv')
text = f.read()
f.close()

clean = re.sub('(?:(?!\/).)*,HTTP.*\/.*"', '', text)

#cleanq = re.sub(r'"', '', text)
#cleanc = re.sub(r',', '\s', text)
f = open('logs.csv', 'w')

f.write(clean)
#f.write(cleanq)
#f.write(cleanc)
f.close()


f = open('logs.csv')
text = f.read()
f.close()

cleanq = re.sub(r'"', '', text)
f = open('logs.csv', 'w')

f.write(cleanq)
f.close()


os.system('./create.auth.sh')
