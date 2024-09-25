setwd("~/Documents/Projects/CommunityInfectionRework/visualizations/")

greedy_full <- data.frame(matrix(ncol = 3, nrow = 0))

greedy_full <- data.frame(
  cascade = read.csv("results/greedy_full/cascade.csv", header = FALSE)[, 1],
  threshold = read.csv("results/greedy_full/threshold.csv", header = FALSE)[, 1],
  onlylistenonce = read.csv("results/greedy_full/onlylistenonce.csv", header = FALSE)[, 1]
  )

greedy_narrow_20_cascade <- read.csv(
  "results/greedy_narrow_20/cascade.csv", sep = ";", header = TRUE
  )
greedy_narrow_20_threshold <- read.csv(
  "results/greedy_narrow_20/threshold.csv", sep = ";", header = TRUE
  )
greedy_narrow_20_onlylistenonce <- read.csv(
  "results/greedy_narrow_20/onlylistenonce.csv", sep = ";", header = TRUE
  )