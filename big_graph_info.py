from pytictoc import TicToc
import pandas as pd
import networkx as nx
import numpy as np
import matplotlib.pyplot as plt

#graphs = ["Cit-HepPh", "Email-EuAll", "soc-Epinions1"]
graphs = ["Cit-HepPh"]
infection_model = "cascade"

max_community_size = 50
connected_percent = [0.7, 0.75, 0.8]
times_average = [5, 5.5, 6]

t = TicToc()
runtimes_path = "runtimes/communities_gridsearch_big/" + infection_model + ".txt"
with open(runtimes_path, "w") as runtimes_output:
    runtimes_output.write("Runtimes (s) - max_community_size: " + str(max_community_size) + "\n")

for graph in graphs:

    # Read infection graph file
    print("##################################################")
    print("Reading infection graph " + graph)
    graph_path = "results/infection_graphs_big/" + infection_model + "/" + graph + ".csv"
    graph_df = pd.read_csv(graph_path, sep=";")

    G = nx.DiGraph()
    for row in graph_df.itertuples():
        G.add_edge(int(row[1]), int(row[2]), weight=float(row[3]))

    mean_edge_weight = np.mean([weight for _, _, weight in G.edges(data='weight')], dtype=np.float64)

    degrees = [degree for _, degree in G.degree()]

    # Step 2: Calculate the degree distribution
    degree_counts = {}
    for degree in degrees:
        if degree in degree_counts:
            degree_counts[degree] += 1
        else:
            degree_counts[degree] = 1

    # Step 3: Plot the degree distribution
    plt.bar(degree_counts.keys(), degree_counts.values())
    plt.xlabel('Degree')
    plt.ylabel('Frequency')
    plt.title('Degree Distribution')
    plt.show()

    degree_dict = dict(G.degree())
    print(degree_dict)