#!usr/bin/env python
# conding: utf-8
import sys
import pandas as pd

data = pd.read_csv(sys.argv[1], sep="\t", header=None, comment='#', dtype={0: str})
data = data[data[2] == 'mRNA']

data['id'] = data[8].str.split(';').str[0].str.replace('ID=', '', regex=False).str.split('.').str[0]

data['len'] = data[4]-data[3]

for name, group in data.groupby(['id']):
    if len(group) == 1:
        continue
    ind = group.sort_values(by='len', ascending=False).index[1:].values
    data.drop(index=ind, inplace=True)

data['order'] = ''
data['newname'] = ''
data[3] = data[3].astype('int')

for name, group in data.groupby([0]):
    group = group.sort_values(by=[2])
    data.loc[group.index, 'order'] = list(range(1, len(group) + 1))

data['id'] = data['id'] + '.1'
data = data[[0,'id',3,4,6,'order',8]]

data = data.sort_values(by=[0, 'order'])
data.to_csv(sys.argv[2], sep="\t", index=False, header=None)
lens = data.groupby(0).max()[[3, 'order']]
lens.to_csv(sys.argv[3], sep="\t", header=None)
