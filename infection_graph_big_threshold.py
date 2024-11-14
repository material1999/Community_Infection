from pytictoc import TicToc
import pandas as pd
import networkx as nx
import random

graphs = ["Cit-HepPh", "Email-EuAll", "soc-Epinions1"]
instances_infection_graph = 10000
cutoff = 2

t = TicToc()
runtimes_path = "runtimes/infection_graphs_big/threshold.txt"
with open(runtimes_path, "w") as runtimes_output:
    runtimes_output.write("Runtimes (s) - instances: " + str(instances_infection_graph)
                          + " - cutoff: " + str(cutoff) + "\n")

for graph in graphs:

    t.tic()

    # Read graph file
    print("##################################################")
    print("Reading graph " + graph)
    graph_path = "data/big_graphs_weighted/" + graph + ".csv"
    graph_df = pd.read_csv(graph_path, sep=";")
    graph_df.columns = ["V1", "V2", "edgeweight"]
    vertex_path = "data/big_graphs_vertices/" + graph + ".csv"
    vertex_df = pd.read_csv(vertex_path, sep=";", names=["vertex", "weight"])

    all_nodes = pd.concat([graph_df['V1'], graph_df['V2']]).unique().tolist()

    # print(graph_df)
    # print(graph_df._get_value(0, "edgeweight"))
    # print(vertex_df)
    # print(vertex_df._get_value(0, "weight"))

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

    reached_nodes = dict()

    print("Creating instances for graph # " + graph)

    for instance_num in range(1, instances_infection_graph + 1):

        # Create instances
        print("graph: " + graph + " --- instance: " + str(instance_num)
              + "/" + str(instances_infection_graph))

        G = nx.DiGraph()
        G.add_nodes_from(all_nodes)

        for vertex in all_nodes:

            choice = random.choices(incoming_edges_dict[vertex][0],
                                    weights=incoming_edges_dict[vertex][1])[0]
            # choice = np.random.choice(incoming_edges_dict[vertex][0],
            #                           p=incoming_edges_dict[vertex][1])
            # print(choice)
            if choice is not None:
                G.add_edge(choice, vertex)

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

    infection_graph_path = "results/infection_graphs_big/threshold/" + graph + ".csv"
    with open(infection_graph_path, 'w') as infection_graph_output:
        infection_graph_output.write("\"V1\";\"V2\";\"edgeweight\"\n")
        for key, value in reached_nodes.items():
            infection_graph_output.write(str(key) + ";" + str(value / instances_infection_graph) + "\n")

    print("Infection graph # " + graph + " created")
    runtime = t.tocvalue()
    print("Runtime:", runtime, "s")
    with open(runtimes_path, "a") as runtimes_output:
        runtimes_output.write(graph + ": " + str(runtime) + "\n")
