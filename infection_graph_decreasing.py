from pytictoc import TicToc
import pandas as pd
import networkx as nx
import numpy as np

graphs = 1080
instances_infection_graph = 10000
cutoff = 2
decrease = 0.1

t = TicToc()
runtimes_path = "runtimes/infection_graphs/decreasing.txt"
with open(runtimes_path, "w") as runtimes_output:
    runtimes_output.write("Runtimes (s) - instances: " + str(instances_infection_graph)
                          + " - cutoff: " + str(cutoff) + "\n")

for graph_num in range(1, graphs + 1):

    t.tic()

    print("##################################################")
    print("Reading graph #" + str(graph_num))
    graph_path = "data/networks/" + str(graph_num) + "/edgeweighted.csv"

    graph_df = pd.read_csv(graph_path, sep=";")
    G = nx.DiGraph()
    G.add_nodes_from(range(1, 1000 + 1))
    for row in graph_df.itertuples():
        G.add_edge(int(row[1]), int(row[2]), weight=row[3])
    print(G)

    reached_nodes = dict()

    print("Creating instances for graph #" + str(graph_num))

    for instance_num in range(1, instances_infection_graph + 1):

        if instance_num % 100 == 0:
            print("graph: " + str(graph_num) + " --- instance: " + str(instance_num)
                  + "/" + str(instances_infection_graph))

        for node in G.nodes():

            newly_infected = list()
            attempts = dict()
            prev_weight = dict()

            out_neighbors = list(G.successors(node))
            for out_neighbor in out_neighbors:
                weight = G[node][out_neighbor]['weight']
                r = np.random.rand()
                if r < weight:
                    newly_infected.append(out_neighbor)
                    key = str(node) + ";" + str(out_neighbor)
                    reached_nodes[key] = reached_nodes.get(key, 0) + 1
                else:
                    attempts[out_neighbor] = attempts.get(out_neighbor, 0) + 1
                    prev_weight[out_neighbor] = weight
            # print(newly_infected)
            # print(attempts)

            for node_new in newly_infected:
                out_neighbors = list(G.successors(node_new))
                # print(out_neighbors)
                for out_neighbor in out_neighbors:
                    if out_neighbor == node:
                        continue
                    if out_neighbor not in attempts:
                        weight = G[node_new][out_neighbor]['weight']
                    else:
                        # print(node_new, out_neighbor, attempts)
                        temp = G[node_new][out_neighbor]['weight']
                        if attempts[out_neighbor] == 1:
                            weight = 1 - ((1 - temp) / (1 - prev_weight[out_neighbor])) * (1 - prev_weight[out_neighbor] * (1 - decrease))
                        else:
                            weight = 0
                        # print("old weight:", temp)
                        # print("new weight:", weight)
                        # raise Exception("Node has already been attempted")
                    r = np.random.rand()
                    if r < weight:
                        key = str(node) + ";" + str(out_neighbor)
                        reached_nodes[key] = reached_nodes.get(key, 0) + 1
                    else:
                        attempts[out_neighbor] = attempts.get(out_neighbor, 0) + 1
                        prev_weight[out_neighbor] = weight

    # print(reached_nodes)

    infection_graph_path = "results/infection_graphs/decreasing/" + str(graph_num) + ".csv"
    with open(infection_graph_path, 'w') as infection_graph_output:
        infection_graph_output.write("\"V1\";\"V2\";\"edgeweight\"\n")
        for key, value in reached_nodes.items():
            infection_graph_output.write(str(key) + ";" + str(value / instances_infection_graph) + "\n")

    print("Infection graph #" + str(graph_num) + " created")
    runtime = t.tocvalue()
    print("Runtime:", runtime, "s")
    with open(runtimes_path, "a") as runtimes_output:
        runtimes_output.write(str(graph_num) + ": " + str(runtime) + "\n")

    print("##################################################")
