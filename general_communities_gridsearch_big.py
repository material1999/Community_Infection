from pytictoc import TicToc
import pandas as pd
import networkx as nx
import numpy as np

#graphs = ["Cit-HepPh", "Email-EuAll", "soc-Epinions1"]
graphs = ["Cit-HepPh"]
infection_model = "cascade"

max_community_size = 50
connected_percent = [0.7, 0.75, 0.8]
times_average = [7, 7.5, 8]

keep_neighbors = 50

t = TicToc()
runtimes_path = "runtimes/communities_gridsearch_big/" + infection_model + ".txt"
with open(runtimes_path, "w") as runtimes_output:
    runtimes_output.write("Runtimes (s) - max_community_size: " + str(max_community_size) + "\n")

for graph in graphs:

    # Read infection graph file
    print("##################################################")
    print("Reading infection graph " + graph)
    graph_path = "results/infection_graphs_big/" + infection_model + "/" + graph + ".csv"
    graph_df = pd.read_csv(graph_path, sep=";")

    G = nx.DiGraph()
    for row in graph_df.itertuples():
        G.add_edge(int(row[1]), int(row[2]), weight=float(row[3]))

    mean_edge_weight = np.mean([weight for _, _, weight in G.edges(data='weight')], dtype=np.float64)

    for c_p in connected_percent:
        for t_a in times_average:

            t.tic()

            communities = {frozenset([i]) for i in G.nodes}
            to_add = {frozenset([i]) for i in G.nodes}

            print("##################################################")
            print("Parameters - connected_percent: " + str(c_p) + " - times_average: " + str(t_a))
            print("Searching for communities in graph " + graph)
            for community_size in range(2, max_community_size + 1):
                print("Community size: " + str(community_size))
                last_iteration = 0
                communities_to_test = to_add.copy()
                to_add.clear()
                count = 0
                number_to_test = len(communities_to_test)
                print("Number of communities to test: " + str(number_to_test))
                for community in communities_to_test:
                    is_expanded = False
                    count += 1
                    if count % 1000 == 0:
                        print(str(community_size) + " - " + str(count) + "/" + str(number_to_test))
                    neighbors = set()
                    for node in community:
                        neighbors.update(G.predecessors(node))
                    neighbors -= community
                    ##### !!!!!!!!!!!!!!!!!!!!!!!!!!!!!! #####
                    if len(neighbors) > keep_neighbors:
                        neighbors = set(list(neighbors)[:keep_neighbors])
                    ##### !!!!!!!!!!!!!!!!!!!!!!!!!!!!!! #####
                    for node in neighbors:
                        community_temp = community.union([node])
                        H = G.subgraph(community_temp)
                        if len(H[node]) >= (community_size - 1) * c_p and \
                                np.mean([weight for _, _, weight in
                                         H.edges(data='weight')], dtype=np.float64) > mean_edge_weight * t_a:
                            last_iteration += 1
                            to_add.add(community_temp)
                            if not is_expanded:
                                communities.remove(community)
                                is_expanded = True

                if community_size == 2:
                    communities = [item for item in communities if len(item) != 1]

                if last_iteration == 0:
                    print("Break at community size: " + str(community_size))
                    break

                communities.extend(to_add)
                print("Total communities: " + str(len(communities)))

            communities_path = ("results/communities_gridsearch_big/" + infection_model + "/"
                                + graph + "_" + str(int(c_p * 100)) + "%_" + str(t_a) + "x.csv")
            with open(communities_path, 'w') as communities_output:
                for community in communities:
                    communities_output.write(str(community)
                                             .replace("frozenset({", "")
                                             .replace("})", "")
                                             .replace(", ", ";") + "\n")

            print("Communities for graph " + graph + " found: " + str(len(communities)))

            runtime = t.tocvalue()
            print("Runtime:", runtime, "s")
            with open(runtimes_path, "a") as runtimes_output:
                runtimes_output.write(graph + "_" + str(int(c_p * 100)) + "%_" + str(t_a) + "x: "
                                      + str(runtime) + "\n")
