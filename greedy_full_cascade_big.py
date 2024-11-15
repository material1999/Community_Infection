from pytictoc import TicToc
import pandas as pd
import networkx as nx
import numpy as np
from tqdm import tqdm

graphs = ["Cit-HepPh", "Email-EuAll", "soc-Epinions1"]
#graphs = ["Cit-HepPh"]
instances_greedy = 10
instances_final = 100
#k_percent = 0.05

t = TicToc()
runtimes_path = "runtimes/greedy_full_big/cascade.txt"
with open(runtimes_path, "w") as runtimes_output:
    runtimes_output.write("Runtimes (s) - greedy instances: " + str(instances_greedy)
                          + " - final instances: " + str(instances_final) + "\n")

for graph in graphs:

    t.tic()

    # Read graph file
    print("##################################################")
    print("Reading graph " + graph)
    graph_path = "data/big_graphs_weighted/" + graph + ".csv"
    graph_df = pd.read_csv(graph_path, sep=";")

    G = nx.DiGraph()
    for row in graph_df.itertuples():
        G.add_edge(int(row[1]), int(row[2]))

    all_nodes = G.nodes
    #k = int(len(G.nodes) * k_percent)
    k = 50

    greedy_full_path = "results/greedy_full_big/cascade/" + graph + ".csv"
    with open(greedy_full_path, 'w') as greedy_full_output:
        greedy_full_output.write("greedy instances: " + str(instances_greedy) +
                                 " - final instances: " + str(instances_final) +
                                 " - k: " + str(k) + "\n")

    possible_nodes = G.nodes
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

            for row in graph_df.itertuples():
                r = np.random.rand()
                if r < row[3]:
                    G.add_edge(int(row[1]), int(row[2]))
            # print(G)

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

        with open(greedy_full_path, "a") as greedy_full_output:
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
    # print(final_inf)

    with open(greedy_full_path, "a") as greedy_full_output:
        greedy_full_output.write("final infection: " + str(final_inf) + "\n")

    ####################################################################################################

    print("Greedy for graph " + graph + " finished")
    runtime = t.tocvalue()
    print("Runtime:", runtime, "s")
    with open(runtimes_path, "a") as runtimes_output:
        runtimes_output.write(graph + ": " + str(runtime) + "\n")
