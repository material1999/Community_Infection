import os

mode = "greedy_narrow_20"
infection_model = "threshold"

graphs = 1080
connected_percent = [0.4, 0.45, 0.5, 0.55, 0.6]
times_average = [4, 4.5, 5, 5.5, 6]

runtime_path = "_office/runtimes/" + mode + "/" + infection_model + ".txt"
output_path = ("_office/runtimes/" + mode + "/summary/" + infection_model + ".csv")

with open(output_path, 'w') as of, open(runtime_path, 'r') as rf:

    next(rf)

    for graph_num in range(1, graphs + 1, 10):
        for c_p in connected_percent:
            for t_a in times_average:
                community_path = ("_office/results/communities_gridsearch/" + infection_model + "/" +
                                  str(graph_num) + "_" + str(int(c_p*100)) + "%_" + str(t_a) + "x.csv")
                if os.path.exists(community_path):
                    runtime = rf.readline().replace("\n", "").split(": ")[1]
                    of.write(runtime + ";")
                else:
                    of.write("xxxxx;")

        of.write("\n")
