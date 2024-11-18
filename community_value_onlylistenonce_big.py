from pytictoc import TicToc
import pandas as pd
import networkx as nx
import numpy as np
import os

# graphs = ["Cit-HepPh", "Email-EuAll", "soc-Epinions1"]
graphs = ["Cit-HepPh"]
instances_final = 100
k = 50

connected_percent = [0.7, 0.75, 0.8,]
times_average = [35, 35.5, 36]

t = TicToc()

runtimes_path = "runtimes/community_value_big/onlylistenonce.csv"
community_value_path = "results/community_value_big/onlylistenonce.csv"

with open(runtimes_path, "w") as runtimes_output, open(community_value_path, 'w') as community_value_output:

    runtimes_output.write("Runtimes (s) - final instances: " + str(instances_final) + "\n")
    community_value_output.write("final instances: " + str(instances_final) + " - k: " + str(k) + "\n")

for graph in graphs:

    # Read graph file
    print("##################################################")
    print("Reading graph " + graph)
    graph_path = "data/big_graphs_weighted/" + graph + ".csv"
    graph_df = pd.read_csv(graph_path, sep=";")
    graph_df.columns = ["V1", "V2", "edgeweight"]
    vertex_path = "data/big_graphs_vertices/" + graph + ".csv"
    vertex_df = pd.read_csv(vertex_path, sep=";", names=["vertex", "weight"])

    all_nodes = pd.concat([graph_df['V1'], graph_df['V2']]).unique().tolist()

    for c_p in connected_percent:
        for t_a in times_average:

            communities_path = ("results/communities_gridsearch_big/onlylistenonce/" + graph + "_" +
                                str(int(c_p * 100)) + "%_" + str(t_a) + "x.csv")
            if not os.path.exists(communities_path):
                print(communities_path + " does not exist")
                with open(community_value_path, "a") as community_value_output:
                    community_value_output.write("xxxxx" + ";")
                with open(runtimes_path, "a") as runtimes_output:
                    runtimes_output.write("xxxxx" + ";")
                continue
            else:
                print(communities_path + " exists")

            t.tic()

            incoming_edges_dict = dict()
            for row in vertex_df.itertuples():
                incoming_edges_dict[row[1]] = graph_df.loc[graph_df['V2'] == row[1]]["V1"].tolist()

            community_values = dict()
            with open(communities_path, 'r') as communities_input:
                for line in communities_input:
                    nodes = [int(item) for item in line.strip("\n").split(";")]
                    for node in nodes:
                        if node not in community_values:
                            community_values[node] = 1
                        else:
                            community_values[node] += 1

            community_values_sorted = dict(sorted(community_values.items(), key=lambda item: item[1], reverse=True))
            best_k = list(community_values_sorted.keys())[:k]

            ####################################################################################################

            final_inf = 0

            for instance_num in range(1, instances_final + 1):

                G = nx.DiGraph()
                G.add_nodes_from(all_nodes)

                for vertex in range(0, len(all_nodes)):

                    r = np.random.rand()
                    if r < vertex_df._get_value(vertex, "weight"):
                        for node in incoming_edges_dict[all_nodes[vertex]]:
                            G.add_edge(node, all_nodes[vertex])

                reached_nodes = set()
                temp_nodes = set(best_k)
                while temp_nodes:
                    temp_node = temp_nodes.pop()
                    reached_nodes.add(temp_node)
                    temp_nodes.update([item for item in G.neighbors(temp_node) if item not in reached_nodes])

                final_inf += len(reached_nodes)
                # print(reached_nodes)

            final_inf /= instances_final
            # print(final_inf)

            with open(community_value_path, "a") as community_value_output:
                community_value_output.write(str(final_inf) + ";")

            ####################################################################################################

            print("Community value influence for graph " + graph + " finished")
            runtime = t.tocvalue()
            print("Runtime:", runtime, "s")
            with open(runtimes_path, "a") as runtimes_output:
                runtimes_output.write(str(runtime) + ";")

    with open(community_value_path, "a") as community_value_output:
        community_value_output.write("\n")
    with open(runtimes_path, "a") as runtimes_output:
        runtimes_output.write("\n")
