import pandas as pd

graphs = 1080
iterations = 100000
model = "cascade"
for graph_num in range(1, graphs + 1):

    print("Filtering graph #" + str(graph_num))
    graph_path = "results/infection_graphs/" + str(model) + "/" + str(graph_num) + ".csv"
    graph_df = pd.read_csv(graph_path, sep=";")
    graph_df_filtered = graph_df[(graph_df["edgeweight"] >= 1000 / iterations)]

    filter_infection_graph_path = "results/infection_graphs_filtered/" + str(model) + "/" + str(graph_num) + ".csv"

    with open(filter_infection_graph_path, 'w') as filter_infection_graph_output:
        filter_infection_graph_output.write("\"V1\";\"V2\";\"edgeweight\"\n")
        for row in graph_df_filtered.itertuples():
            filter_infection_graph_output.write(str(row[1]) + ";" + str(row[2]) + ";" + str(row[3]) + "\n")


