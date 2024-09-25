from pytictoc import TicToc
import pandas as pd
import networkx as nx
import numpy as np
import random
import os

graphs = 1
instances_greedy = 100
instances_final = 10000
k = 50
narrow = 200

connected_percent = [0.4, 0.45, 0.5, 0.55, 0.6]
times_average = [4, 4.5, 5, 5.5, 6]

t = TicToc()
runtimes_path = "runtimes/greedy_narrow/threshold.txt"
with open(runtimes_path, "w") as runtimes_output:
    runtimes_output.write("Runtimes (s) - greedy instances: " + str(instances_greedy)
                          + " - final instances: " + str(instances_final) + "\n")

for graph_num in range(1, graphs + 1):

    # Read graph file
    print("##################################################")
    print("Reading graph #" + str(graph_num))
    graph_path = "data/networks/" + str(graph_num) + "/edgeweighted.csv"
    graph_df = pd.read_csv(graph_path, sep=";")
    vertex_path = "data/networks/" + str(graph_num) + "/vertices.txt"
    vertex_df = pd.read_csv(vertex_path, sep=";", names=["vertex", "weight"])

    for c_p in connected_percent:
        for t_a in times_average:

            communities_path = ("results/communities_gridsearch/threshold/" + str(graph_num) + "_" +
                                str(int(c_p * 100)) + "%_" + str(t_a) + "x.csv")
            if not os.path.exists(communities_path):
                print(communities_path + " does not exist")
                continue
            else:
                print(communities_path + " exists")

            t.tic()

            greedy_narrow_path = ("results/greedy_narrow/threshold/" + str(graph_num) + "_" +
                                str(int(c_p*100)) + "%_" + str(t_a) + "x.csv")
            with open(greedy_narrow_path, 'w') as greedy_full_output:
                greedy_full_output.write("greedy instances: " + str(instances_greedy) +
                                         " - final instances: " + str(instances_final) +
                                         " - k: " + str(k) + "\n")

            incoming_edges_dict = dict()
            for row in vertex_df.itertuples():
                weights = graph_df.loc[graph_df['V2'] == row[1]]["edgeweight"].tolist()
                from_vertex = graph_df.loc[graph_df['V2'] == row[1]]["V1"].tolist()
                if sum(weights) < 1:
                    weights.append(1 - sum(weights))
                    from_vertex.append(None)
                else:
                    weights = [float(i) / sum(weights) for i in weights]

                # print(row)
                # print(graph_df.loc[graph_df['V2'] == row[1]])
                # print(weights)
                # print(from_vertex)

                incoming_edges_dict[row[1]] = [from_vertex, weights]

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

            print("Greedy for graph #" + str(graph_num) + " in progress...")

            for i in range(1, k + 1):
                print("k: " + str(i))
                best_node = 0
                best_inf = 0
                node_infections = dict()

                for instance_num in range(1, instances_greedy + 1):
                    G = nx.DiGraph()
                    G.add_nodes_from(range(1, 1000 + 1))

                    for vertex in range(1, 1000 + 1):
                        choice = random.choices(incoming_edges_dict[vertex][0],
                                                weights=incoming_edges_dict[vertex][1])[0]
                        if choice is not None:
                            G.add_edge(choice, vertex)

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
                G.add_nodes_from(range(1, 1000 + 1))

                for vertex in range(1, 1000 + 1):
                    choice = random.choices(incoming_edges_dict[vertex][0],
                                            weights=incoming_edges_dict[vertex][1])[0]
                    if choice is not None:
                        G.add_edge(choice, vertex)

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

            print("Greedy for graph #" + str(graph_num) + " finished")
            runtime = t.tocvalue()
            print("Runtime:", runtime, "s")
            with open(runtimes_path, "a") as runtimes_output:
                runtimes_output.write(str(graph_num) + ": " + str(runtime) + "\n")
