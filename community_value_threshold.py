from pytictoc import TicToc
import pandas as pd
import networkx as nx
import random
import os

graphs = 1080
instances_final = 10000
k = 50

connected_percent = [0.4, 0.45, 0.5, 0.55, 0.6]
times_average = [4, 4.5, 5, 5.5, 6]

t = TicToc()

runtimes_path = "runtimes/community_value/threshold.csv"
community_value_path = "results/community_value/threshold.csv"

with open(runtimes_path, "w") as runtimes_output, open(community_value_path, 'w') as community_value_output:

    runtimes_output.write("Runtimes (s) - final instances: " + str(instances_final) + "\n")
    community_value_output.write("final instances: " + str(instances_final) + " - k: " + str(k) + "\n")

for graph_num in range(1, graphs + 1, 10):

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
                weights = graph_df.loc[graph_df['V2'] == row[1]]["edgeweight"].tolist()
                from_vertex = graph_df.loc[graph_df['V2'] == row[1]]["V1"].tolist()
                if sum(weights) < 1:
                    weights.append(1 - sum(weights))
                    from_vertex.append(None)
                else:
                    weights = [float(i) / sum(weights) for i in weights]
                incoming_edges_dict[row[1]] = [from_vertex, weights]

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

            with open(community_value_path, "a") as community_value_output:
                community_value_output.write(str(final_inf) + ";")

            ####################################################################################################

            print("Community value influence for graph #" + str(graph_num) + " finished")
            runtime = t.tocvalue()
            print("Runtime:", runtime, "s")
            with open(runtimes_path, "a") as runtimes_output:
                runtimes_output.write(str(runtime) + ";")

    with open(community_value_path, "a") as community_value_output:
        community_value_output.write("\n")
    with open(runtimes_path, "a") as runtimes_output:
        runtimes_output.write("\n")
