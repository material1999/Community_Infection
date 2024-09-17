graphs = ["Cit-HepPh", "Email-EuAll", "soc-Epinions1"]

for graph in graphs:
    big_graph_path = "data/big_graphs/" + graph + ".txt"
    big_graph_formatted_path = "data/big_graphs_formatted/" + graph + ".csv"
    with open(big_graph_path, 'r') as big_graph_file, open(big_graph_formatted_path, 'w') as big_graph_formatted_file:
        next(big_graph_file)
        next(big_graph_file)
        next(big_graph_file)
        next(big_graph_file)
        for line in big_graph_file:
            big_graph_formatted_file.write(line.replace("\t", ";"))
