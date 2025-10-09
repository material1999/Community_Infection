graphs = ["ego-Facebook"]

for graph in graphs:
    big_graph_path = "data/big_graphs/" + graph + ".txt"
    big_graph_directed_path = "data/big_graphs_directed/" + graph + ".csv"
    with open(big_graph_path, 'r') as big_graph_file, open(big_graph_directed_path, 'w') as big_graph_directed_file:
        for line in big_graph_file:
            nodes = line.strip().split(" ")
            big_graph_directed_file.write(nodes[0] + "\t" + nodes[1] + "\n")
            big_graph_directed_file.write(nodes[1] + "\t" + nodes[0] + "\n")