graphs = 1
mode = "greedy_narrow"
infection_model = "cascade"

output_path = ("_office/runtimes/" + mode + "/summary/" + infection_model + ".csv")

with open(output_path, 'w') as of:

    runtime_path = "_office/runtimes/" + mode + "/" + infection_model + ".txt"

    # print(runtime_path)

    with open(runtime_path, 'r') as rf:
        next(rf)
        for line in rf:
            runtime = line.replace("\n", "").split(": ")[1]
            # print(runtime)
            of.write(runtime + ";")

    of.write("\n")
