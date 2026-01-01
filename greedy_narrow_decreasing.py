from pytictoc import TicToc
import pandas as pd
import networkx as nx
import numpy as np
import os

graphs = 1
# graphs = 1080
instances_greedy = 100
instances_final = 10000
k = 50
decrease = 0.1
narrow = 200

connected_percent = [0.4, 0.45, 0.5, 0.55, 0.6]
times_average = [4, 4.5, 5, 5.5, 6]

t = TicToc()
runtimes_path = "runtimes/greedy_narrow/decreasing.txt"
with open(runtimes_path, "w") as runtimes_output:
    runtimes_output.write("Runtimes (s) - greedy instances: " + str(instances_greedy)
                          + " - final instances: " + str(instances_final) + "\n")

for graph_num in range(1, graphs + 1, 10):

    t.tic()

    print("##################################################")
    print("Reading graph #" + str(graph_num))
    graph_path = "data/networks/" + str(graph_num) + "/edgeweighted.csv"

    possible_nodes = range(1, 1000 + 1)

    graph_df = pd.read_csv(graph_path, sep=";")
    G = nx.DiGraph()
    G.add_nodes_from(possible_nodes)
    for row in graph_df.itertuples():
        G.add_edge(int(row[1]), int(row[2]), weight=row[3])
    print(G)

    out_edges_precompute = {u: list(G.out_edges(u, data=True)) for u in G.nodes()}

    for c_p in connected_percent:
        for t_a in times_average:

            communities_path = ("results/communities_gridsearch/decreasing/" + str(graph_num) + "_" +
                                str(int(c_p * 100)) + "%_" + str(t_a) + "x.csv")
            if not os.path.exists(communities_path):
                print(communities_path + " does not exist")
                continue
            else:
                print(communities_path + " exists")

            t.tic()

            greedy_narrow_path = ("results/greedy_narrow/decreasing/" + str(graph_num) + "_" +
                                  str(int(c_p * 100)) + "%_" + str(t_a) + "x.csv")
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
            possible_nodes = list(community_values_sorted.keys())[:narrow]
            ####################################################################################################

            print("Greedy for graph #" + str(graph_num) + " in progress...")

            best_k = list()

            for i in range(1, k + 1):

                print("k: " + str(i))
                best_node = None
                best_inf = 0

                for node in possible_nodes:
                    if node not in best_k:

                        temp_nodes = set(best_k)
                        temp_nodes.add(node)
                        base_out_edges = [edge for node in temp_nodes for edge in out_edges_precompute[node]]

                        infected_sum = 0

                        for instance_num in range(1, instances_greedy + 1):

                            infected_instance = set()
                            attempts = dict()
                            prev_weight = dict()

                            out_edges = base_out_edges[:]

                            j = 0
                            while j < len(out_edges):
                                edge = out_edges[j]
                                to_node = edge[1]
                                j += 1

                                if to_node in infected_instance:
                                    continue
                                if to_node not in attempts:
                                    weight = edge[2]['weight']
                                else:
                                    if attempts[to_node] == 1:
                                        temp = edge[2]['weight']
                                        weight = 1 - ((1 - temp) / (1 - prev_weight[to_node])) * (
                                                1 - prev_weight[to_node] * (1 - decrease))
                                    else:
                                        weight = 0
                                        continue

                                r = np.random.rand()
                                if r < weight:
                                    infected_instance.add(to_node)
                                    infected_sum += 1
                                    out_edges.extend(out_edges_precompute[to_node])
                                else:
                                    attempts[to_node] = attempts.get(to_node, 0) + 1
                                    prev_weight[to_node] = weight

                        infected_avg = infected_sum / instances_greedy
                        if infected_avg >= best_inf:
                            best_inf = infected_avg
                            best_node = node

                best_k.append(best_node)

                with open(greedy_narrow_path, "a") as greedy_full_output:
                    greedy_full_output.write(str(i) + " --- " + str(best_k) + " --- " + str(best_inf) + "\n")

            ####################################################################################################

            infected_sum = 0

            temp_nodes = set(best_k)
            base_out_edges = [edge for node in temp_nodes for edge in out_edges_precompute[node]]

            for instance_num in range(1, instances_final + 1):

                infected_instance = set()
                attempts = dict()
                prev_weight = dict()

                out_edges = base_out_edges[:]

                j = 0
                while j < len(out_edges):
                    edge = out_edges[j]
                    to_node = edge[1]
                    j += 1

                    if to_node in infected_instance:
                        continue
                    if to_node not in attempts:
                        weight = edge[2]['weight']
                    else:
                        if attempts[to_node] == 1:
                            temp = edge[2]['weight']
                            weight = 1 - ((1 - temp) / (1 - prev_weight[to_node])) * (
                                    1 - prev_weight[to_node] * (1 - decrease))
                        else:
                            weight = 0
                            continue

                    r = np.random.rand()
                    if r < weight:
                        infected_instance.add(to_node)
                        infected_sum += 1
                        out_edges.extend(out_edges_precompute[to_node])
                    else:
                        attempts[to_node] = attempts.get(to_node, 0) + 1
                        prev_weight[to_node] = weight

            final_inf = infected_sum / instances_final
            final_inf += k

            with open(greedy_narrow_path, "a") as greedy_full_output:
                greedy_full_output.write("final infection: " + str(final_inf) + "\n")

            ####################################################################################################

            print("Greedy for graph #" + str(graph_num) + " finished")
            runtime = t.tocvalue()
            print("Runtime:", runtime, "s")
            with open(runtimes_path, "a") as runtimes_output:
                runtimes_output.write(str(graph_num) + ";" + str(c_p) + ";" + str(t_a) + ": " + str(runtime) + "\n")
