import statistics
import networkx as nx
import pandas as pd

graphs = 1080
infection_model = "onlylistenonce"

##### mean input graph density #####

print("##################################################")

densities = list()
clustering_coefficients = list()
diameters = list()

for graph_num in range(1, graphs + 1, 10):

    graph_path = "data/networks/" + str(graph_num) + "/edgeweighted.csv"
    graph_df = pd.read_csv(graph_path, sep=";")

    G = nx.DiGraph()
    for row in graph_df.itertuples():
        G.add_edge(int(row[1]), int(row[2]), weight=float(row[3]))

    # densities.append(nx.density(G))
    # clustering_coefficients.append(nx.average_clustering(G))
    # diameters.append(nx.diameter(G))

# print("mean input graph density:", statistics.mean(densities))
# print("mean input graph average clustering coefficient:", statistics.mean(clustering_coefficients))
# print("mean input graph diameter:", statistics.mean(diameters))

####################################################################################################

##### mean infection graph density #####

print("##################################################")

densities = list()
clustering_coefficients = list()
diameters = list()

for graph_num in range(1, graphs + 1, 10):

    graph_path = "_office/results/infection_graphs/" + infection_model + "/" + str(graph_num) + ".csv"
    graph_df = pd.read_csv(graph_path, sep=";")

    G = nx.DiGraph()
    for row in graph_df.itertuples():
        G.add_edge(int(row[1]), int(row[2]), weight=float(row[3]))

    # densities.append(nx.density(G))
    # clustering_coefficients.append(nx.average_clustering(G))
    diameters.append(nx.diameter(G))

# print("mean infection graph density:", statistics.mean(densities))
# print("mean infection graph average clustering coefficient:", statistics.mean(clustering_coefficients))
print("mean infection graph diameter:", statistics.mean(diameters))

####################################################################################################

