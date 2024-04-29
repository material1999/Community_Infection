from pytictoc import TicToc
import pandas as pd
import networkx as nx
import numpy as np

graphs = 1
instances_infection_graph = 1000
cutoff = 2

t = TicToc()
runtimes_path = "runtimes/infection_graphs/cascade.txt"
with open(runtimes_path, "w") as runtimes_output:
    runtimes_output.write("Runtimes (s) - instances: " + str(instances_infection_graph)
                          + " - cutoff: " + str(cutoff) + "\n")

for graph_num in range(1, graphs + 1):

    t.tic()

    # Read graph file
    print("##################################################")
    print("Reading graph #" + str(graph_num))
    graph_path = "data/networks/" + str(graph_num) + "/edgeweighted.csv"
    graph_df = pd.read_csv(graph_path, sep=";")

    # df = pd.read_csv(graph_path, sep=";")
    # graph_df = df[df['edgeweight'] >= 0.05]

    # print(graph_df)
    # print(graph_df._get_value(0, "edgeweight"))

    reached_nodes = dict()

    print("Creating instances for graph #" + str(graph_num))

    for instance_num in range(1, instances_infection_graph + 1):

        # Create instances
        # print("graph: " + str(graph_num) + " --- instance: " + str(instance_num)
        #       + "/" + str(instances_infection_graph))

        G = nx.DiGraph()
        G.add_nodes_from(range(1, 1000 + 1))

        # for index, row in graph_df.iterrows():
        #     r = np.random.rand()
        #     if r < row["edgeweight"]:
        #         G.add_edge(int(row["V1"]), int(row["V2"]))
        # print(G)

        for row in graph_df.itertuples():
            r = np.random.rand()
            if r < row[3]:
                G.add_edge(int(row[1]), int(row[2]))
        # print(G)

        # General solution for any cutoff value

        # roots = [v for v, d in G.out_degree() if d > 0]
        # leaves = [v for v, d in G.in_degree() if d > 0]
        # for root in roots:
        #     for path in nx.all_simple_paths(G, source=root, target=leaves, cutoff=cutoff):
        #         # print(path)
        #         if len(path) > 1:
        #             # print(path)
        #             key = str(path[0]) + ";" + str(path[-1])
        #             if key not in reached_nodes:
        #                 reached_nodes[key] = 1
        #             else:
        #                 reached_nodes[key] += 1

        # Faster solution for cutoff = 2

        for edge in G.edges():
            # print(edge)
            key = str(edge[0]) + ";" + str(edge[1])
            if key not in reached_nodes:
                reached_nodes[key] = 1
            elif reached_nodes[key] < instance_num:
                reached_nodes[key] += 1
            # print([n for n in G[edge[1]]])
            neighbours = G.neighbors(edge[1])
            # print([n for n in G.neighbors(edge[1])])
            for n in neighbours:
                if str(edge[0]) != str(n):
                    key = str(edge[0]) + ";" + str(n)
                    if key not in reached_nodes:
                        reached_nodes[key] = 1
                    elif reached_nodes[key] < instance_num:
                        reached_nodes[key] += 1

    # print(reached_nodes)

    infection_graph_path = "results/infection_graphs/cascade/" + str(graph_num) + ".csv"
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
