import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

df = pd.read_csv('/Users/richardparada/Desktop/Data_Science/Capstone Project/NSDUH_2016_Tab.csv')
print(df.describe())

df.plot(data=df['CIGEVER'], kind='box')
plt.show()