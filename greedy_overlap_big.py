import os

# graphs = ["Wiki-Vote", "Cit-HepPh", "soc-Epinions1", "Email-EuAll"]
graph = "Email-EuAll"
model = "decreasing"
connected_percent = [0.7, 0.75, 0.8]
times_average = [13, 13.5, 14]
k = 50

greedy_full_path = "_office/results/greedy_full_big/" + model + "/" + graph + ".csv"

greedy_full_file = open(greedy_full_path)
content_full = [int(x) for x in greedy_full_file.readlines()[50].split(" --- ")[1]
    .replace("[", "").replace("]", "").replace(" ", "").split(",")]

# print("greedy full:", content_full)

best = 0
best_path = ""

for c_p in connected_percent:
    for t_a in times_average:

        greedy_narrow_path = ("_office/results/greedy_narrow_big/" + model + "/" + graph + "_" +
                            str(int(c_p*100)) + "%_" + str(t_a) + "x.csv")
        if os.path.isfile(greedy_narrow_path):
            greedy_narrow_file = open(greedy_narrow_path)
            final = float(greedy_narrow_file.readlines()[51].split(": ")[1].strip())

            if final > best:
                best = final
                best_path = greedy_narrow_path

greedy_narrow_file = open(best_path)
content_narrow = [int(x) for x in greedy_narrow_file.readlines()[50].split(" --- ")[1]
    .replace("[", "").replace("]", "").replace(" ", "").split(",")]

# print("greedy narrow:", content_narrow)

inter = set(content_narrow).intersection(set(content_full))
# print("intersection:", inter)

overlap_sum = len(inter)

overlap_percent = overlap_sum / k * 100
print("average overlap between greedy full and greedy narrow:", overlap_percent, "%")