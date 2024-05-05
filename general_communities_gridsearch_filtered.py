from pytictoc import TicToc
import pandas as pd
import networkx as nx
import statistics

graphs = 1
infection_model = "cascade"

max_community_size = 20
connected_percent = [0.2, 0.25, 0.3, 0.35, 0.4]
times_average = [2, 2.5, 3, 3.5, 4]

t = TicToc()
runtimes_path = "runtimes/communities_gridsearch_filtered/" + infection_model + ".txt"
with open(runtimes_path, "w") as runtimes_output:
    runtimes_output.write("Runtimes (s) - max_community_size: " + str(max_community_size) + "\n")

for graph_num in range(1, graphs + 1, 10):
    for c_p in connected_percent:
        for t_a in times_average:

            t.tic()

            # Read infection graph file
            print("##################################################")
            print("Reading infection graph #" + str(graph_num))
            graph_path = "results/infection_graphs_filtered/" + infection_model + "/" + str(graph_num) + ".csv"
            graph_df = pd.read_csv(graph_path, sep=";")

            # df = pd.read_csv(graph_path, sep=";")
            # graph_df = df[df['edgeweight'] >= 0.05]

            # print(graph_df)
            # print(graph_df._get_value(0, "edgeweight"))

            G = nx.DiGraph()
            for row in graph_df.itertuples():
                G.add_edge(int(row[1]), int(row[2]), weight=float(row[3]))
            # print(G)

            mean_edge_weight = statistics.mean(weight for _, _, weight in G.edges(data='weight'))
            # print(mean_edge_weight)
            communities = list({i} for i in range(1, 1000 + 1))
            # print(communities)

            print("Parameters - connected_percent: " + str(c_p) + " - times_average: " + str(t_a))
            print("Searching for communities in graph #" + str(graph_num))
            for community_size in range(2, max_community_size + 1):
                print("Community size: " + str(community_size))
                last_iteration = 0
                to_add = list()
                to_delete = list()
                for community in communities:
                    if len(community) != community_size - 1:
                        continue
                    neighbors = set()
                    for node in community:
                        neighbors.update(G.neighbors(node))
                        # print(node)
                        # print(neighbors)
                    neighbors = [item for item in neighbors if item not in community]
                    # print(neighbors)
                    for node in neighbors:
                        community_temp = list(community.copy())
                        community_temp.append(node)
                        H = G.subgraph(community_temp)
                        # print(community)
                        # print(community_temp)
                        # print(statistics.mean(weight for _, _, weight in H.edges(data='weight')))
                        # print(len([h for h in H.neighbors(node)]))
                        if statistics.mean(weight for _, _, weight in H.edges(data='weight')) \
                                > mean_edge_weight * t_a and \
                                len([h for h in H.neighbors(node)]) >= (community_size - 1) * c_p:
                            # print("old: " + str(community))
                            # print("new: " + str(community_temp))
                            last_iteration += 1
                            if community not in to_delete:
                                to_delete.append(community)
                            if set(community_temp) not in to_add and set(community_temp) not in communities:
                                to_add.append(set(community_temp))
                if last_iteration == 0:
                    print("Break at community size: " + str(community_size))
                    break
                # print(to_add)
                # print(to_delete)
                communities = [item for item in communities if item not in to_delete]
                communities.extend(to_add)
                # print(communities)

            communities = [item for item in communities if len(item) != 1]
            # print(communities)

            communities_path = ("results/communities_gridsearch_filtered/" + infection_model + "/"
                                + str(graph_num) + "_" + str(int(c_p*100)) + "%_" + str(t_a) + "x.csv")
            with open(communities_path, 'w') as communities_output:
                for community in communities:
                    communities_output.write(str(community)
                                             .replace("{", "")
                                             .replace("}", "")
                                             .replace(", ", ";") + "\n")

            print("Communities for graph #" + str(graph_num) + " found")
            runtime = t.tocvalue()
            print("Runtime:", runtime, "s")
            with open(runtimes_path, "a") as runtimes_output:
                runtimes_output.write(str(graph_num) + "_" + str(int(c_p*100)) + "%_" + str(t_a) + "x: "
                                      + str(runtime) + "\n")

            # print("##################################################")