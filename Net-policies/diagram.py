import networkx as nx
from pyvis.network import Network
import pandas as pd
import numpy as np
import os
import sys

# Reference
# https://pyvis.readthedocs.io/en/latest/tutorial.html#networkx-integration

#os.system('cat uniqe.list | awk '{$1=$1}1' OFS="," > uniqe.list.csv')

inputFile = "uniqe.list.csv"
dataset = pd.read_csv(inputFile, header=None, names=['source', 'port', 'target'], engine='python')
df = pd.DataFrame(dataset)

# convert the type of a Pandas DataFrame column from integer to string in Python
# https://www.kite.com/python/answers/how-to-convert-the-type-of-a-pandas-dataframe-column-from-integer-to-string-in-python
df["port"] = df["port"].astype(str)

UniqNodes = (np.unique(df[['source', 'port', 'target']].values)).size

nx_graph = nx.Graph()

for node in np.unique(df[['source']].values):
    print(f'add node: {node}')
    # nx_graph.add_node(node)
    nx_graph.add_node(node, size=10, title=node, group=node)

for node in np.unique(df[['target']].values):
    print(f'add node: {node}')
    # nx_graph.add_node(node)
    nx_graph.add_node(node, size=20, title=node, group=node)

for ind in df.index:
    print(f"{df['source'][ind]} => {df['port'][ind]} => {df['target'][ind]}")
    port = f"{df['target'][ind]}:{df['port'][ind]}"
    nx_graph.add_edge(df['source'][ind], port)
    nx_graph.add_edge(port, df['target'][ind])

nt = Network('800px', '1024px')
# populates the nodes and edges data structures
nt.from_nx(nx_graph)
nt.show_buttons(filter_=['physics'])
nt.show('AssafNetworkGraph.html')
