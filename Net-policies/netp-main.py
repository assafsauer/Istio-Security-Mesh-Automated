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


# print columns 13 and 18 from log logs.csv
input_file = "logs.csv"
dataset = pd.read_csv(input_file)
df = pd.DataFrame(dataset)
cols = [13,18]
df = df[df.columns[cols]]
#print(df)

# print results to file
with open('file.txt', 'w') as f:
   print(df, file=f)


# Read in the file
with open('file.txt', 'r') as file :
  filedata = file.read()

# Replace the target string
filedata = filedata.replace(':', ' ')
#filedata  = re.sub(r":.*", "",filedata )

# Replace the target string
filedata = filedata.replace('service ', ' ')

# Write the file out again
with open('file.txt', 'w') as file:
  file.write(filedata)

os.system("./data.prep.sh")

os.system("./netpolicy.sh")

