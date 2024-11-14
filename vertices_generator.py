import random
import os
import pandas as pd

graphs = ["Cit-HepPh", "Email-EuAll", "soc-Epinions1"]

min_value = 0.05
max_value = 0.1

for graph in graphs:

    graph_path = "data/big_graphs_weighted/" + graph + ".csv"
    graph_df = pd.read_csv(graph_path, sep=";")
    graph_df.columns = ["V1", "V2", "edgeweight"]

    all_nodes = pd.concat([graph_df['V1'], graph_df['V2']]).unique().tolist()
    vertex_num = len(all_nodes)

    vertex_weights = [random.uniform(min_value, max_value) for _ in range(vertex_num)]

    vertices_path = "data/big_graphs_vertices/" + graph + ".csv"
    os.makedirs(os.path.dirname(vertices_path), exist_ok=True)

    with open(vertices_path, "w") as vertices_output:
        for i in range(vertex_num):
            vertices_output.write(str(all_nodes[i]) + ";" + str(vertex_weights[i]) + "\n")

    print(graph, "done")
