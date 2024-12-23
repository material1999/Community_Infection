from pytictoc import TicToc
import pandas as pd
import networkx as nx
import numpy as np
import os
from tqdm import tqdm

graphs = ["Cit-HepPh", "Email-EuAll", "soc-Epinions1"]
# graphs = ["Cit-HepPh"]

instances_greedy = 10
instances_final = 100

k = 50
narrow = {"Cit-HepPh": 6909, "Email-EuAll": 53042, "soc-Epinions1": 15175}

connected_percent = [0.7, 0.75, 0.8]
times_average = [7, 7.5, 8]

t = TicToc()
runtimes_path = "runtimes/greedy_narrow_big/onlylistenonce.txt"
with open(runtimes_path, "w") as runtimes_output:
    runtimes_output.write("Runtimes (s) - greedy instances: " + str(instances_greedy)
                          + " - final instances: " + str(instances_final) + "\n")

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
                continue
            else:
                print(communities_path + " exists")

            t.tic()

            greedy_narrow_path = ("results/greedy_narrow_big/onlylistenonce/" + graph + "_" +
                                str(int(c_p*100)) + "%_" + str(t_a) + "x.csv")
            with open(greedy_narrow_path, 'w') as greedy_full_output:
                greedy_full_output.write("greedy instances: " + str(instances_greedy) +
                                         " - final instances: " + str(instances_final) +
                                         " - k: " + str(k) + "\n")

            incoming_edges_dict = dict()

            for row in vertex_df.itertuples():

                # print(row)
                # print(graph_df.loc[graph_df['V2'] == row[1]])

                incoming_edges_dict[row[1]] = graph_df.loc[graph_df['V2'] == row[1]]["V1"].tolist()

            # print(incoming_edges_dict)

            ####################################################################################################
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
            possible_nodes = list(community_values_sorted.keys())[:narrow]
            ####################################################################################################
            best_k = list()

            print("Greedy for graph " + graph + " in progress...")

            for i in range(1, k + 1):
                print("k: " + str(i))
                best_node = 0
                best_inf = 0
                node_infections = dict()

                for instance_num in tqdm(range(1, instances_greedy + 1)):

                    G = nx.DiGraph()
                    G.add_nodes_from(all_nodes)

                    for vertex in range(0, len(all_nodes)):

                        r = np.random.rand()
                        if r < vertex_df._get_value(vertex, "weight"):
                            for node in incoming_edges_dict[all_nodes[vertex]]:
                                G.add_edge(node, all_nodes[vertex])

                    for node in possible_nodes:
                        if node not in best_k:

                            # 1.5x slower

                            # reached_nodes = set(best_k)
                            # reached_nodes.add(node)
                            # temp_nodes = reached_nodes.copy()
                            # for temp_node in temp_nodes:
                            #     reached_nodes.update(nx.descendants(G, temp_node))

                            reached_nodes = set()
                            temp_nodes = set(best_k)
                            temp_nodes.add(node)
                            while temp_nodes:
                                temp_node = temp_nodes.pop()
                                reached_nodes.add(temp_node)
                                temp_nodes.update([item for item in G.neighbors(temp_node) if item not in reached_nodes])

                            if node not in node_infections:
                                node_infections[node] = len(reached_nodes)
                            else:
                                node_infections[node] += len(reached_nodes)

                    best_node = max(node_infections, key=node_infections.get)
                    best_inf = node_infections[best_node] / instances_greedy

                best_k.append(best_node)
                # print(best_k)

                with open(greedy_narrow_path, "a") as greedy_full_output:
                    greedy_full_output.write(str(i) + " --- " + str(best_k) + " --- " + str(best_inf) + "\n")

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

            with open(greedy_narrow_path, "a") as greedy_full_output:
                greedy_full_output.write("final infection: " + str(final_inf) + "\n")

            ####################################################################################################

            print("Greedy for graph " + graph + " finished")
            runtime = t.tocvalue()
            print("Runtime:", runtime, "s")
            with open(runtimes_path, "a") as runtimes_output:
                runtimes_output.write(graph + ": " + str(runtime) + "\n")
