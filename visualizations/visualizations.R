library(dplyr)

setwd("~/Documents/Projects/CommunityInfectionRework/")

max_in_row <- function(row) {
  numeric_row <- as.numeric(suppressWarnings(as.numeric(row)))
  if (all(is.na(numeric_row))) {
    return(c(NA, NA))
  }
  max_value <- max(numeric_row, na.rm = TRUE)
  max_col <- names(row)[which.max(numeric_row)]
  return(c(max_value, max_col))
}

greedy_full <- data.frame(
  cascade = read.csv("_office/results/greedy_full/summary/cascade.csv", header = FALSE)[, 1],
  threshold = read.csv("_office/results/greedy_full/summary/threshold.csv", header = FALSE)[, 1],
  onlylistenonce = read.csv("_office/results/greedy_full/summary/onlylistenonce.csv", header = FALSE)[, 1]
  )

greedy_narrow_20_cascade <- read.csv(
  "_office/results/greedy_narrow_20/summary/cascade.csv", sep = ";", header = TRUE, check.names = FALSE
) %>% select(-ncol(.))

max_greedy_narrow_20_cascade <- as.data.frame(t(apply(greedy_narrow_20_cascade, 1, max_in_row)))
colnames(max_greedy_narrow_20_cascade) <- c("Max_Value", "Max_Column")

labels_max_greedy_narrow_20_cascade <- as.data.frame(table(max_greedy_narrow_20_cascade$Max_Column))
colnames(labels_max_greedy_narrow_20_cascade) <- c("Column", "Count")

greedy_labels <- colnames(greedy_narrow_20_cascade)
missing_labels <- setdiff(greedy_labels, labels_max_greedy_narrow_20_cascade$Column)
missing_df <- data.frame(Column = missing_labels, Count = 0)
labels_max_greedy_narrow_20_cascade <- rbind(labels_max_greedy_narrow_20_cascade, missing_df)
labels_max_greedy_narrow_20_cascade$Column <- as.character(labels_max_greedy_narrow_20_cascade$Column)
labels_max_greedy_narrow_20_cascade <- labels_max_greedy_narrow_20_cascade[
  order(labels_max_greedy_narrow_20_cascade$Column), ]

rm(greedy_labels)
rm(missing_labels)
rm(missing_df)
