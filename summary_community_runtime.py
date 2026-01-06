lines = 2700
infection_model = "decreasing"

input_path = ("_office/runtimes/communities_gridsearch/" + infection_model + ".txt")
output_path = ("_office/runtimes/communities_gridsearch/summary/" + infection_model + ".csv")

with open(input_path, 'r') as input, open(output_path, 'w') as output:

    next(input)

    for graph_num in range(1, lines + 1):
        runtime = str(input.readline().strip().split(': ')[1])
        output.write(runtime + ";")
        if graph_num % 25 == 0:
            output.write("\n")
