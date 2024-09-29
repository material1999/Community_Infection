library(dplyr)
library(tidyr)
library(ggplot2)

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

ggplot(data = labels_max_greedy_narrow_20_cascade, aes(x = Column, y = Count)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = Count), vjust = -0.5, size = 4) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 7.5),
    axis.text.y = element_text(size = 10),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  ) +
  labs(
    title = "Max Counts by Parameter Combinations",
    x = "Parameter Combinations",
    y = "Max Count"
  ) +
  ylim(0, max(labels_max_greedy_narrow_20_cascade$Count) + 2)

heatmap_data <- labels_max_greedy_narrow_20_cascade %>%
  separate(Column, into = c("Parameter1", "Parameter2"), sep = "--") %>%
  mutate(Parameter1 = as.factor(Parameter1), Parameter2 = as.factor(Parameter2))

ggplot(data = heatmap_data, aes(x = Parameter1, y = Parameter2, fill = Count)) +
  geom_tile(color = "black") +
  geom_text(aes(label = Count), color = "black", size = 4) +
  scale_fill_gradient(
    low = "white",
    high = "#0073B2",
    limits = c(min(labels_max_greedy_narrow_20_cascade$Count),
               max(labels_max_greedy_narrow_20_cascade$Count)),
    breaks = c(min(labels_max_greedy_narrow_20_cascade$Count),
               max(labels_max_greedy_narrow_20_cascade$Count)),
    labels = scales::label_number(accuracy = 1)
  ) +
  theme_minimal(base_size = 15) +
  labs(
    title = "Max Counts by Parameter Combinations",
    x = "Times Average",
    y = "Connected Percent",
    fill = "Count"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
    axis.text.y = element_text(size = 10),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )

