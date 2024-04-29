from pytictoc import TicToc
import pandas as pd
import networkx as nx
import numpy as np

graphs = 1
instances_greedy = 10
instances_final = 100
k = 10

t = TicToc()
runtimes_path = "runtimes/greedy_full/cascade.txt"
with open(runtimes_path, "w") as runtimes_output:
    runtimes_output.write("Runtimes (s) - greedy instances: " + str(instances_greedy)
                          + " - final instances: " + str(instances_final) + "\n")

for graph_num in range(1, graphs + 1):

    t.tic()

    # Read graph file
    print("##################################################")
    print("Reading graph #" + str(graph_num))
    graph_path = "data/networks/" + str(graph_num) + "/edgeweighted.csv"
    graph_df = pd.read_csv(graph_path, sep=";")

    greedy_full_path = "results/greedy_full/cascade/" + str(graph_num) + ".csv"
    with open(greedy_full_path, 'w') as greedy_full_output:
        greedy_full_output.write("greedy instances: " + str(instances_greedy) +
                                 " - final instances: " + str(instances_final) +
                                 " - k: " + str(k) + "\n")

    possible_nodes = range(1, 1000 + 1)
    best_k = list()

    print("Greedy for graph #" + str(graph_num) + " in progress...")

    for i in range(1, k + 1):
        print("k: " + str(i))
        best_inf = 0
        best_node = 0
        for node in possible_nodes:
            if node not in best_k:
                curr_inf = 0
                for instance_num in range(1, instances_greedy + 1):

                    G = nx.DiGraph()
                    G.add_nodes_from(range(1, 1000 + 1))

                    for row in graph_df.itertuples():
                        r = np.random.rand()
                        if r < row[3]:
                            G.add_edge(int(row[1]), int(row[2]))
                    # print(G)

                    # reached_nodes = set(best_k)
                    # reached_nodes.add(node)
                    # temp_nodes = reached_nodes.copy()
                    # for temp_node in temp_nodes:
                    #     reached_nodes.update(nx.descendants(G, temp_node))

                    # reached_nodes = set()
                    # temp_nodes = set(best_k)
                    # temp_nodes.add(node)
                    # while temp_nodes:
                    #     temp_node = temp_nodes.pop()
                    #     reached_nodes.add(temp_node)
                    #     temp_nodes.update([item for item in nx.descendants_at_distance(G, temp_node, 1)
                    #                        if item not in reached_nodes])

                    reached_nodes = set()
                    temp_nodes = set(best_k)
                    temp_nodes.add(node)
                    while temp_nodes:
                        temp_node = temp_nodes.pop()
                        reached_nodes.add(temp_node)
                        temp_nodes.update([item for item in G.neighbors(temp_node) if item not in reached_nodes])

                    curr_inf += len(reached_nodes)
                    # print(str(reached_nodes) + " len: " + str(len(reached_nodes)))

                curr_inf /= instances_greedy
                # print(curr_inf)
                if curr_inf > best_inf:
                    best_inf = curr_inf
                    best_node = node

        best_k.append(best_node)
        print(best_k)

        with open(greedy_full_path, "a") as greedy_full_output:
            greedy_full_output.write(str(i) + " --- " + str(best_k) + " --- " + str(best_inf) + "\n")

    ####################################################################################################

    final_inf = 0

    # t.tic()

    for instance_num in range(1, instances_final + 1):

        G = nx.DiGraph()
        G.add_nodes_from(range(1, 1000 + 1))

        for row in graph_df.itertuples():
            r = np.random.rand()
            if r < row[3]:
                G.add_edge(int(row[1]), int(row[2]))

        # reached_nodes = set(best_k)
        reached_nodes = set()
        temp_nodes = set(best_k)

        # for temp_node in temp_nodes:
        #     reached_nodes.update(nx.descendants(G, temp_node))

        while temp_nodes:
            temp_node = temp_nodes.pop()
            reached_nodes.add(temp_node)
            temp_nodes.update([item for item in nx.descendants_at_distance(G, temp_node, 1)
                              if item not in reached_nodes])

        final_inf += len(reached_nodes)
        # print(reached_nodes)

    final_inf /= instances_final
    # print(final_inf)

    # runtime = t.tocvalue()
    # print("Runtime:", runtime, "s")

    with open(greedy_full_path, "a") as greedy_full_output:
        greedy_full_output.write("final infection: " + str(final_inf) + "\n")

    ####################################################################################################

    # t.tic()

    print("Greedy for graph #" + str(graph_num) + " finished")
    runtime = t.tocvalue()
    print("Runtime:", runtime, "s")
    with open(runtimes_path, "a") as runtimes_output:
        runtimes_output.write(str(graph_num) + ": " + str(runtime) + "\n")

    print("##################################################")
