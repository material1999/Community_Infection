import os

graphs = 1080
mode = "greedy_narrow"
infection_model = "cascade"

connected_percent = [0.4, 0.45, 0.5, 0.55, 0.6]
times_average = [4, 4.5, 5, 5.5, 6]

output_path = ("_office/results/" + mode + "/summary/" + infection_model + ".csv")

with open(output_path, 'w') as of:

    for graph_num in range(1, graphs + 1, 10):
        for c_p in connected_percent:
            for t_a in times_average:

                graph_path = ("_office/results/" + mode + "/" + infection_model + "/" + str(graph_num)
                              + "_" + str(int(c_p*100)) + "%_" + str(t_a) + "x.csv")

                # print(graph_path)

                if not os.path.exists(graph_path):
                    of.write("xxxxx" + ";")
                    continue

                with open(graph_path, 'r') as gf:
                    final_infection = gf.readlines()[-1].replace("\n", "").split(": ")[1]
                    # print(final_infection)
                    of.write(final_infection + ";")

        of.write("\n")
