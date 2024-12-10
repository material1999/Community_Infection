import networkx as nx
import pandas as pd
import numpy as np

# graphs = ["Cit-HepPh", "Email-EuAll", "soc-Epinions1"]
graph = "soc-Epinions1"
infection_model = "onlylistenonce"

##### input graph density #####

print("##################################################")

graph_path = "data/big_graphs_weighted/" + graph + ".csv"
graph_df = pd.read_csv(graph_path, sep=";")

G = nx.DiGraph()
for row in graph_df.itertuples():
    G.add_edge(int(row[1]), int(row[2]), weight=float(row[3]))

mean_edge_weight = np.mean([weight for _, _, weight in G.edges(data='weight')], dtype=np.float64)
# density = nx.density(G)
# clustering_coefficient = nx.average_clustering(G)
# diameter = nx.diameter(G)

print("mean edge weight:", mean_edge_weight)
# print("input graph density:", density)
# print("input graph average clustering coefficient:", clustering_coefficient)
# print("input graph diameter:", diameter)

####################################################################################################

##### infection graph density #####

print("##################################################")

graph_path = "_office/results/infection_graphs_big/" + infection_model + "/" + graph + ".csv"
graph_df = pd.read_csv(graph_path, sep=";")

G = nx.DiGraph()
for row in graph_df.itertuples():
    G.add_edge(int(row[1]), int(row[2]), weight=float(row[3]))

mean_edge_weight = np.mean([weight for _, _, weight in G.edges(data='weight')], dtype=np.float64)
# density = nx.density(G)
# clustering_coefficient = nx.average_clustering(G)
# diameter = nx.diameter(G)

print("mean edge weight:", mean_edge_weight)
# print("input graph density:", density)
# print("input graph average clustering coefficient:", clustering_coefficient)
# print("input graph diameter:", diameter)

print("##################################################")

####################################################################################################
