graphs = 1080
mode = "greedy_full"
infection_model = "decreasing"

output_path = ("_office/results/" + mode + "/summary/" + infection_model + ".csv")

with open(output_path, 'w') as of:

    for graph_num in range(1, graphs + 1, 10):

        graph_path = "_office/results/" + mode + "/" + infection_model + "/" + str(graph_num) + ".csv"
        # print(graph_path)

        with open(graph_path, 'r') as gf:
            final_infection = gf.readlines()[-1].replace("\n", "").split(": ")[1]
            # print(final_infection)
            of.write(final_infection + "\n")
