library(dplyr)
library(tidyr)
library(ggplot2)
library(patchwork)
library(reshape2)

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
  cascade = read.csv("_office/results/greedy_full/summary/cascade.csv",
                     header = FALSE)[, 1],
  threshold = read.csv("_office/results/greedy_full/summary/threshold.csv",
                       header = FALSE)[, 1],
  onlylistenonce = read.csv("_office/results/greedy_full/summary/onlylistenonce.csv",
                            header = FALSE)[, 1]
  )

############################## CASCADE ##############################

greedy_narrow_20_cascade <- read.csv(
  "_office/results/greedy_narrow_20/summary/cascade.csv",
  sep = ";", header = TRUE, check.names = FALSE
) %>% select(-ncol(.))

max_greedy_narrow_20_cascade <- as.data.frame(
  t(apply(greedy_narrow_20_cascade, 1, max_in_row)))
colnames(max_greedy_narrow_20_cascade) <- c("Max_Value", "Max_Column")

labels_max_greedy_narrow_20_cascade <- as.data.frame(
  table(max_greedy_narrow_20_cascade$Max_Column))
colnames(labels_max_greedy_narrow_20_cascade) <- c("Column", "Count")

greedy_labels <- colnames(greedy_narrow_20_cascade)
missing_labels <- setdiff(greedy_labels, labels_max_greedy_narrow_20_cascade$Column)
missing_df <- data.frame(Column = missing_labels, Count = 0)
labels_max_greedy_narrow_20_cascade <- rbind(
  labels_max_greedy_narrow_20_cascade, missing_df)
labels_max_greedy_narrow_20_cascade$Column <- as.character(
  labels_max_greedy_narrow_20_cascade$Column)
labels_max_greedy_narrow_20_cascade <- labels_max_greedy_narrow_20_cascade[
  order(labels_max_greedy_narrow_20_cascade$Column), ]

rm(greedy_labels)
rm(missing_labels)
rm(missing_df)

# ggplot(data = labels_max_greedy_narrow_20_cascade, aes(x = Column, y = Count)) +
#   geom_bar(stat = "identity") +
#   geom_text(aes(label = Count), vjust = -0.5, size = 4) +
#   theme(
#     axis.text.x = element_text(angle = 45, hjust = 1, size = 7.5),
#     axis.text.y = element_text(size = 10),
#     panel.grid.major = element_blank(),
#     panel.grid.minor = element_blank()
#   ) +
#   labs(
#     title = "Max Counts by Parameter Combinations",
#     x = "Parameter Combinations",
#     y = "Max Count"
#   ) +
#   ylim(0, max(labels_max_greedy_narrow_20_cascade$Count) + 2)

heatmap_data <- labels_max_greedy_narrow_20_cascade %>%
  separate(Column, into = c("Parameter1", "Parameter2"), sep = "--") %>%
  mutate(Parameter1 = as.factor(Parameter1), Parameter2 = as.factor(Parameter2))

plot1 <- ggplot(data = heatmap_data, aes(x = Parameter1, y = Parameter2, fill = Count)) +
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
    title = "Cascade",
    x = "Times Average",
    y = "Connected Percent",
    fill = "Best Influence"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
    axis.text.y = element_text(size = 10),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.title = element_text(angle = 90, vjust = 0.9, margin = margin(b=20)),
    legend.justification = c(0.6, 0.4),
    legend.title.position = "top",
    legend.key.height = unit(1.25, "cm")
  )

rm(heatmap_data)

############################## THRESHOLD ##############################

greedy_narrow_20_threshold <- read.csv(
  "_office/results/greedy_narrow_20/summary/threshold.csv",
  sep = ";", header = TRUE, check.names = FALSE
) %>% select(-ncol(.))

max_greedy_narrow_20_threshold <- as.data.frame(
  t(apply(greedy_narrow_20_threshold, 1, max_in_row)))
colnames(max_greedy_narrow_20_threshold) <- c("Max_Value", "Max_Column")

labels_max_greedy_narrow_20_threshold <- as.data.frame(
  table(max_greedy_narrow_20_threshold$Max_Column))
colnames(labels_max_greedy_narrow_20_threshold) <- c("Column", "Count")

greedy_labels <- colnames(greedy_narrow_20_threshold)
missing_labels <- setdiff(greedy_labels, labels_max_greedy_narrow_20_threshold$Column)
missing_df <- data.frame(Column = missing_labels, Count = 0)
labels_max_greedy_narrow_20_threshold <- rbind(
  labels_max_greedy_narrow_20_threshold, missing_df)
labels_max_greedy_narrow_20_threshold$Column <- as.character(
  labels_max_greedy_narrow_20_threshold$Column)
labels_max_greedy_narrow_20_threshold <- labels_max_greedy_narrow_20_threshold[
  order(labels_max_greedy_narrow_20_threshold$Column), ]

rm(greedy_labels)
rm(missing_labels)
rm(missing_df)

heatmap_data <- labels_max_greedy_narrow_20_threshold %>%
  separate(Column, into = c("Parameter1", "Parameter2"), sep = "--") %>%
  mutate(Parameter1 = as.factor(Parameter1), Parameter2 = as.factor(Parameter2))

plot2 <- ggplot(data = heatmap_data, aes(x = Parameter1, y = Parameter2, fill = Count)) +
  geom_tile(color = "black") +
  geom_text(aes(label = Count), color = "black", size = 4) +
  scale_fill_gradient(
    low = "white",
    high = "#0073B2",
    limits = c(min(labels_max_greedy_narrow_20_threshold$Count),
               max(labels_max_greedy_narrow_20_threshold$Count)),
    breaks = c(min(labels_max_greedy_narrow_20_threshold$Count),
               max(labels_max_greedy_narrow_20_threshold$Count)),
    labels = scales::label_number(accuracy = 1)
  ) +
  theme_minimal(base_size = 15) +
  labs(
    title = "Threshold",
    x = "Times Average",
    y = "Connected Percent",
    fill = "Best Influence"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
    axis.text.y = element_text(size = 10),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.title = element_text(angle = 90, vjust = 0.9, margin = margin(b=20)),
    legend.justification = c(0.6, 0.4),
    legend.title.position = "top",
    legend.key.height = unit(1.25, "cm")
  )

rm(heatmap_data)

############################## ONLY-LISTEN-ONCE ##############################

greedy_narrow_20_onlylistenonce <- read.csv(
  "_office/results/greedy_narrow_20/summary/onlylistenonce.csv",
  sep = ";", header = TRUE, check.names = FALSE
) %>% select(-ncol(.))

max_greedy_narrow_20_onlylistenonce <- as.data.frame(
  t(apply(greedy_narrow_20_onlylistenonce, 1, max_in_row)))
colnames(max_greedy_narrow_20_onlylistenonce) <- c("Max_Value", "Max_Column")

labels_max_greedy_narrow_20_onlylistenonce <- as.data.frame(
  table(max_greedy_narrow_20_onlylistenonce$Max_Column))
colnames(labels_max_greedy_narrow_20_onlylistenonce) <- c("Column", "Count")

greedy_labels <- colnames(greedy_narrow_20_onlylistenonce)
missing_labels <- setdiff(greedy_labels, labels_max_greedy_narrow_20_onlylistenonce$Column)
missing_df <- data.frame(Column = missing_labels, Count = 0)
labels_max_greedy_narrow_20_onlylistenonce <- rbind(
  labels_max_greedy_narrow_20_onlylistenonce, missing_df)
labels_max_greedy_narrow_20_onlylistenonce$Column <- as.character(
  labels_max_greedy_narrow_20_onlylistenonce$Column)
labels_max_greedy_narrow_20_onlylistenonce <- labels_max_greedy_narrow_20_onlylistenonce[
  order(labels_max_greedy_narrow_20_onlylistenonce$Column), ]

rm(greedy_labels)
rm(missing_labels)
rm(missing_df)

heatmap_data <- labels_max_greedy_narrow_20_onlylistenonce %>%
  separate(Column, into = c("Parameter1", "Parameter2"), sep = "--") %>%
  mutate(Parameter1 = as.factor(Parameter1), Parameter2 = as.factor(Parameter2))

plot3 <- ggplot(data = heatmap_data, aes(x = Parameter1, y = Parameter2, fill = Count)) +
  geom_tile(color = "black") +
  geom_text(aes(label = Count), color = "black", size = 4) +
  scale_fill_gradient(
    low = "white",
    high = "#0073B2",
    limits = c(min(labels_max_greedy_narrow_20_onlylistenonce$Count),
               max(labels_max_greedy_narrow_20_onlylistenonce$Count)),
    breaks = c(min(labels_max_greedy_narrow_20_onlylistenonce$Count),
               max(labels_max_greedy_narrow_20_onlylistenonce$Count)),
    labels = scales::label_number(accuracy = 1)
  ) +
  theme_minimal(base_size = 15) +
  labs(
    title = "Only-Listen-Once",
    x = "Times Average",
    y = "Connected Percent",
    fill = "Best Influence"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
    axis.text.y = element_text(size = 10),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.title = element_text(angle = 90, vjust = 0.9, margin = margin(b=20)),
    legend.justification = c(0.6, 0.4),
    legend.title.position = "top",
    legend.key.height = unit(1.25, "cm")
  )

rm(heatmap_data)

############################## COMBINED PLOT ##############################

combined_plot <- plot1 + plot_spacer() + plot2 + plot_spacer() + plot3 +
  plot_layout(ncol = 5, widths = c(1, 0.1, 1, 0.1, 1)) +
  plot_annotation(tag_levels = 'A')

ggsave("visualizations/combined_plot.png", combined_plot, width = 21, height = 6)

############################## FULL VS NARROW ##############################

long_data <- melt(greedy_narrow_20_cascade, variable.name = "parameters", value.name = "result")
long_data <- subset(long_data, result != "xxxxx")
long_data$result <- as.numeric(long_data$result)
long_data$row <- rep(1:nrow(greedy_narrow_20_cascade),
                     times = ncol(greedy_narrow_20_cascade))[1:nrow(long_data)]

plot4 <- ggplot(long_data, aes(x = factor(row), y = result)) +
  geom_boxplot(outlier.color = "red") +
  labs(x = "Graphs", y = "Result",
       title = "Range of Results per Graph Across Parameter Combinations") +
  scale_x_discrete(breaks = seq(1, 108, by = 107)) +
  theme_minimal() +
  theme(plot.background = element_rect(fill = "white"))

summary_data <- long_data %>%
  group_by(row) %>%
  summarise(min_result = min(result, na.rm = TRUE),
            max_result = max(result, na.rm = TRUE))

target_values <- greedy_full[[1]]
summary_data$target <- target_values

plot5 <- ggplot(summary_data, aes(x = row)) +
  geom_ribbon(aes(ymin = min_result, ymax = max_result, fill = "Result Range"), alpha = 0.5) +
  geom_line(aes(y = (min_result + max_result) / 2, color = "Average Result"), size = 0.5) +
  geom_line(aes(y = target, color = "Target Value"), size = 0.5) +
  labs(x = "Graphs", y = "Result Range",
       title = "Range of Results per Graph Across Parameter Combinations", 
       fill = "Legend", color = "Legend") +
  scale_x_continuous(breaks = seq(1, 108, by = 107)) +
  theme_minimal() +
  theme(plot.background = element_rect(fill = "white"))

ggsave("visualizations/plot4.png", plot4, width = 21, height = 6)
ggsave("visualizations/plot5.png", plot5, width = 21, height = 6)