from pytictoc import TicToc
import pandas as pd
import networkx as nx
import numpy as np
import os
from tqdm import tqdm

# graphs = ["Cit-HepPh", "Email-EuAll", "soc-Epinions1"]
graphs = ["Cit-HepPh"]

instances_greedy = 10
instances_final = 100

k = 50
narrow = {"Cit-HepPh": 6909, "Email-EuAll": 53042, "soc-Epinions1": 15175}

connected_percent = [0.7, 0.75, 0.8]
times_average = [7, 7.5, 8]

t = TicToc()
runtimes_path = "runtimes/greedy_narrow_big/cascade.txt"
with open(runtimes_path, "w") as runtimes_output:
    runtimes_output.write("Runtimes (s) - greedy instances: " + str(instances_greedy)
                          + " - final instances: " + str(instances_final) + "\n")

for graph in graphs:

    print("##################################################")
    print("Reading graph " + str(graph))
    graph_path = "data/big_graphs_weighted/" + graph + ".csv"
    graph_df = pd.read_csv(graph_path, sep=";")
    graph_df.columns = ["V1", "V2", "edgeweight"]

    all_nodes = pd.concat([graph_df['V1'], graph_df['V2']]).unique().tolist()

    for c_p in connected_percent:
        for t_a in times_average:

            communities_path = ("results/communities_gridsearch_big/cascade/" + str(graph) + "_" +
                                str(int(c_p*100)) + "%_" + str(t_a) + "x.csv")
            if not os.path.exists(communities_path):
                print(communities_path + " does not exist")
                continue
            else:
                print(communities_path + " exists")

            t.tic()

            greedy_narrow_path = ("results/greedy_narrow_big/cascade/" + str(graph) + "_" +
                                str(int(c_p*100)) + "%_" + str(t_a) + "x.csv")
            with open(greedy_narrow_path, 'w') as greedy_full_output:
                greedy_full_output.write("greedy instances: " + str(instances_greedy) +
                                         " - final instances: " + str(instances_final) +
                                         " - k: " + str(k) + "\n")

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
            possible_nodes = list(community_values_sorted.keys())[:narrow[graph]]

            ####################################################################################################

            best_k = list()

            print("Greedy for graph " + str(graph) + " in progress...")

            for i in range(1, k + 1):
                print("k: " + str(i))
                best_node = 0
                best_inf = 0
                node_infections = dict()

                for instance_num in tqdm(range(1, instances_greedy + 1)):
                    G = nx.DiGraph()
                    G.add_nodes_from(all_nodes)

                    for row in graph_df.itertuples():
                        r = np.random.rand()
                        if r < row[3]:
                            G.add_edge(int(row[1]), int(row[2]))

                    for node in possible_nodes:
                        if node not in best_k:

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

                with open(greedy_narrow_path, "a") as greedy_full_output:
                    greedy_full_output.write(str(i) + " --- " + str(best_k) + " --- " + str(best_inf) + "\n")

            ####################################################################################################

            final_inf = 0

            for instance_num in range(1, instances_final + 1):

                G = nx.DiGraph()
                G.add_nodes_from(all_nodes)

                for row in graph_df.itertuples():
                    r = np.random.rand()
                    if r < row[3]:
                        G.add_edge(int(row[1]), int(row[2]))

                reached_nodes = set()
                temp_nodes = set(best_k)
                while temp_nodes:
                    temp_node = temp_nodes.pop()
                    reached_nodes.add(temp_node)
                    temp_nodes.update([item for item in G.neighbors(temp_node) if item not in reached_nodes])

                final_inf += len(reached_nodes)
                # print(reached_nodes)

            final_inf /= instances_final

            with open(greedy_narrow_path, "a") as greedy_full_output:
                greedy_full_output.write("final infection: " + str(final_inf) + "\n")

            ####################################################################################################

            print("Greedy for graph #" + str(graph) + " finished")
            runtime = t.tocvalue()
            print("Runtime:", runtime, "s")
            with open(runtimes_path, "a") as runtimes_output:
                runtimes_output.write(str(graph) + ": " + str(runtime) + "\n")
