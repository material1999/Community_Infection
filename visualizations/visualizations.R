############################## INITIALIZATIONS ##############################

library(dplyr)
library(tidyr)
library(ggplot2)
library(patchwork)
library(reshape2)

setwd("~/Documents/Projects/CommunityInfectionRework/")

############################## READ DATA ############################## ✅

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
                            header = FALSE)[, 1],
  decreasing = read.csv("_office/results/greedy_full/summary/decreasing.csv",
                            header = FALSE)[, 1]
)

############################## INDEPENDENT CASCADE NARROW ############################## ✅

greedy_narrow_20_cascade <- read.csv(
  "_office/results/greedy_narrow/summary/cascade.csv",
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

heatmap_data <- labels_max_greedy_narrow_20_cascade %>%
  separate(Column, into = c("Parameter1", "Parameter2"), sep = "--") %>%
  mutate(Parameter1 = as.factor(Parameter1), Parameter2 = as.factor(Parameter2))

plot1 <- ggplot(data = heatmap_data, aes(x = Parameter1, y = Parameter2, fill = Count)) +
  geom_tile(color = "black") +
  geom_text(aes(label = Count), color = "black", size = 6) +
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
    title = "Independent Cascade",
    x = "Connected Percent",
    y = "Times Average",
    fill = "Best Influence"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.title = element_text(angle = 90, vjust = 0.9, margin = margin(b=20)),
    legend.justification = c(0.6, 0.4),
    legend.title.position = "top",
    legend.key.height = unit(1.25, "cm")
  )

rm(heatmap_data)


############################## INDEPENDENT CASCADE COMMUNITY VALUE ############################## ✅

community_value_cascade <- read.csv(
  "_office/results/community_value/summary/cascade.csv",
  sep = ";", header = TRUE, check.names = FALSE
) %>% select(-ncol(.))

max_community_value_cascade <- as.data.frame(
  t(apply(community_value_cascade, 1, max_in_row)))
colnames(max_community_value_cascade) <- c("Max_Value", "Max_Column")

labels_max_community_value_cascade <- as.data.frame(
  table(max_community_value_cascade$Max_Column))
colnames(labels_max_community_value_cascade) <- c("Column", "Count")

greedy_labels <- colnames(community_value_cascade)
missing_labels <- setdiff(greedy_labels, labels_max_community_value_cascade$Column)
missing_df <- data.frame(Column = missing_labels, Count = 0)
labels_max_community_value_cascade <- rbind(
  labels_max_community_value_cascade, missing_df)
labels_max_community_value_cascade$Column <- as.character(
  labels_max_community_value_cascade$Column)
labels_max_community_value_cascade <- labels_max_community_value_cascade[
  order(labels_max_community_value_cascade$Column), ]

rm(greedy_labels)
rm(missing_labels)
rm(missing_df)

heatmap_data <- labels_max_community_value_cascade %>%
  separate(Column, into = c("Parameter1", "Parameter2"), sep = "--") %>%
  mutate(Parameter1 = as.factor(Parameter1), Parameter2 = as.factor(Parameter2))

plot6 <- ggplot(data = heatmap_data, aes(x = Parameter1, y = Parameter2, fill = Count)) +
  geom_tile(color = "black") +
  geom_text(aes(label = Count), color = "black", size = 6) +
  scale_fill_gradient(
    low = "white",
    high = "#0073B2",
    limits = c(min(labels_max_community_value_cascade$Count),
               max(labels_max_community_value_cascade$Count)),
    breaks = c(min(labels_max_community_value_cascade$Count),
               max(labels_max_community_value_cascade$Count)),
    labels = scales::label_number(accuracy = 1)
  ) +
  theme_minimal(base_size = 15) +
  labs(
    title = "Independent Cascade",
    x = "Connected Percent",
    y = "Times Average",
    fill = "Best Influence"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.title = element_text(angle = 90, vjust = 0.9, margin = margin(b=20)),
    legend.justification = c(0.6, 0.4),
    legend.title.position = "top",
    legend.key.height = unit(1.25, "cm")
  )

rm(heatmap_data)


############################## LINEAR THRESHOLD NARROW ############################## ✅

greedy_narrow_20_threshold <- read.csv(
  "_office/results/greedy_narrow/summary/threshold.csv",
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
  geom_text(aes(label = Count), color = "black", size = 6) +
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
    title = "Linear Threshold",
    x = "Connected Percent",
    y = "Times Average",
    fill = "Best Influence"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.title = element_text(angle = 90, vjust = 0.9, margin = margin(b=20)),
    legend.justification = c(0.6, 0.4),
    legend.title.position = "top",
    legend.key.height = unit(1.25, "cm")
  )

rm(heatmap_data)

############################## LINEAR THRESHOLD COMMUNITY VALUE ############################## ✅

community_value_threshold <- read.csv(
  "_office/results/community_value/summary/threshold.csv",
  sep = ";", header = TRUE, check.names = FALSE
) %>% select(-ncol(.))

max_community_value_threshold <- as.data.frame(
  t(apply(community_value_threshold, 1, max_in_row)))
colnames(max_community_value_threshold) <- c("Max_Value", "Max_Column")

labels_max_community_value_threshold <- as.data.frame(
  table(max_community_value_threshold$Max_Column))
colnames(labels_max_community_value_threshold) <- c("Column", "Count")

greedy_labels <- colnames(community_value_threshold)
missing_labels <- setdiff(greedy_labels, labels_max_community_value_threshold$Column)
missing_df <- data.frame(Column = missing_labels, Count = 0)
labels_max_community_value_threshold <- rbind(
  labels_max_community_value_threshold, missing_df)
labels_max_community_value_threshold$Column <- as.character(
  labels_max_community_value_threshold$Column)
labels_max_community_value_threshold <- labels_max_community_value_threshold[
  order(labels_max_community_value_threshold$Column), ]

rm(greedy_labels)
rm(missing_labels)
rm(missing_df)

heatmap_data <- labels_max_community_value_threshold %>%
  separate(Column, into = c("Parameter1", "Parameter2"), sep = "--") %>%
  mutate(Parameter1 = as.factor(Parameter1), Parameter2 = as.factor(Parameter2))

plot7 <- ggplot(data = heatmap_data, aes(x = Parameter1, y = Parameter2, fill = Count)) +
  geom_tile(color = "black") +
  geom_text(aes(label = Count), color = "black", size = 6) +
  scale_fill_gradient(
    low = "white",
    high = "#0073B2",
    limits = c(min(labels_max_community_value_threshold$Count),
               max(labels_max_community_value_threshold$Count)),
    breaks = c(min(labels_max_community_value_threshold$Count),
               max(labels_max_community_value_threshold$Count)),
    labels = scales::label_number(accuracy = 1)
  ) +
  theme_minimal(base_size = 15) +
  labs(
    title = "Linear Threshold",
    x = "Connected Percent",
    y = "Times Average",
    fill = "Best Influence"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.title = element_text(angle = 90, vjust = 0.9, margin = margin(b=20)),
    legend.justification = c(0.6, 0.4),
    legend.title.position = "top",
    legend.key.height = unit(1.25, "cm")
  )

rm(heatmap_data)

############################## ONLY-LISTEN-ONCE NARROW ############################## ✅

greedy_narrow_20_onlylistenonce <- read.csv(
  "_office/results/greedy_narrow/summary/onlylistenonce.csv",
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
  geom_text(aes(label = Count), color = "black", size = 6) +
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
    x = "Connected Percent",
    y = "Times Average",
    fill = "Best Influence"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.title = element_text(angle = 90, vjust = 0.9, margin = margin(b=20)),
    legend.justification = c(0.6, 0.4),
    legend.title.position = "top",
    legend.key.height = unit(1.25, "cm")
  )

rm(heatmap_data)

############################## ONLY-LISTEN-ONCE COMMUNITY VALUE ############################## ✅

community_value_onlylistenonce <- read.csv(
  "_office/results/community_value/summary/onlylistenonce.csv",
  sep = ";", header = TRUE, check.names = FALSE
) %>% select(-ncol(.))

max_community_value_onlylistenonce <- as.data.frame(
  t(apply(community_value_onlylistenonce, 1, max_in_row)))
colnames(max_community_value_onlylistenonce) <- c("Max_Value", "Max_Column")

labels_max_community_value_onlylistenonce <- as.data.frame(
  table(max_community_value_onlylistenonce$Max_Column))
colnames(labels_max_community_value_onlylistenonce) <- c("Column", "Count")

greedy_labels <- colnames(community_value_onlylistenonce)
missing_labels <- setdiff(greedy_labels, labels_max_community_value_onlylistenonce$Column)
missing_df <- data.frame(Column = missing_labels, Count = 0)
labels_max_community_value_onlylistenonce <- rbind(
  labels_max_community_value_onlylistenonce, missing_df)
labels_max_community_value_onlylistenonce$Column <- as.character(
  labels_max_community_value_onlylistenonce$Column)
labels_max_community_value_onlylistenonce <- labels_max_community_value_onlylistenonce[
  order(labels_max_community_value_onlylistenonce$Column), ]

rm(greedy_labels)
rm(missing_labels)
rm(missing_df)

heatmap_data <- labels_max_community_value_onlylistenonce %>%
  separate(Column, into = c("Parameter1", "Parameter2"), sep = "--") %>%
  mutate(Parameter1 = as.factor(Parameter1), Parameter2 = as.factor(Parameter2))

plot8 <- ggplot(data = heatmap_data, aes(x = Parameter1, y = Parameter2, fill = Count)) +
  geom_tile(color = "black") +
  geom_text(aes(label = Count), color = "black", size = 6) +
  scale_fill_gradient(
    low = "white",
    high = "#0073B2",
    limits = c(min(labels_max_community_value_onlylistenonce$Count),
               max(labels_max_community_value_onlylistenonce$Count)),
    breaks = c(min(labels_max_community_value_onlylistenonce$Count),
               max(labels_max_community_value_onlylistenonce$Count)),
    labels = scales::label_number(accuracy = 1)
  ) +
  theme_minimal(base_size = 15) +
  labs(
    title = "Only-Listen-Once",
    x = "Connected Percent",
    y = "Times Average",
    fill = "Best Influence"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.title = element_text(angle = 90, vjust = 0.9, margin = margin(b=20)),
    legend.justification = c(0.6, 0.4),
    legend.title.position = "top",
    legend.key.height = unit(1.25, "cm")
  )

rm(heatmap_data)

############################## DECREASING NARROW ############################## ❌

greedy_narrow_20_decreasing <- read.csv(
  "_office/results/greedy_narrow/summary/decreasing.csv",
  sep = ";", header = TRUE, check.names = FALSE
) %>% select(-ncol(.))

max_greedy_narrow_20_decreasing <- as.data.frame(
  t(apply(greedy_narrow_20_decreasing, 1, max_in_row)))
colnames(max_greedy_narrow_20_decreasing) <- c("Max_Value", "Max_Column")

labels_max_greedy_narrow_20_decreasing <- as.data.frame(
  table(max_greedy_narrow_20_decreasing$Max_Column))
colnames(labels_max_greedy_narrow_20_decreasing) <- c("Column", "Count")

greedy_labels <- colnames(greedy_narrow_20_decreasing)
missing_labels <- setdiff(greedy_labels, labels_max_greedy_narrow_20_decreasing$Column)
missing_df <- data.frame(Column = missing_labels, Count = 0)
labels_max_greedy_narrow_20_decreasing <- rbind(
  labels_max_greedy_narrow_20_decreasing, missing_df)
labels_max_greedy_narrow_20_decreasing$Column <- as.character(
  labels_max_greedy_narrow_20_decreasing$Column)
labels_max_greedy_narrow_20_decreasing <- labels_max_greedy_narrow_20_decreasing[
  order(labels_max_greedy_narrow_20_decreasing$Column), ]

rm(greedy_labels)
rm(missing_labels)
rm(missing_df)

heatmap_data <- labels_max_greedy_narrow_20_decreasing %>%
  separate(Column, into = c("Parameter1", "Parameter2"), sep = "--") %>%
  mutate(Parameter1 = as.factor(Parameter1), Parameter2 = as.factor(Parameter2))

plot18 <- ggplot(data = heatmap_data, aes(x = Parameter1, y = Parameter2, fill = Count)) +
  geom_tile(color = "black") +
  geom_text(aes(label = Count), color = "black", size = 6) +
  scale_fill_gradient(
    low = "white",
    high = "#0073B2",
    limits = c(min(labels_max_greedy_narrow_20_decreasing$Count),
               max(labels_max_greedy_narrow_20_decreasing$Count)),
    breaks = c(min(labels_max_greedy_narrow_20_decreasing$Count),
               max(labels_max_greedy_narrow_20_decreasing$Count)),
    labels = scales::label_number(accuracy = 1)
  ) +
  theme_minimal(base_size = 15) +
  labs(
    title = "Decreasing Cascade",
    x = "Connected Percent",
    y = "Times Average",
    fill = "Best Influence"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.title = element_text(angle = 90, vjust = 0.9, margin = margin(b=20)),
    legend.justification = c(0.6, 0.4),
    legend.title.position = "top",
    legend.key.height = unit(1.25, "cm")
  )

rm(heatmap_data)

############################## DECREASING COMMUNITY VALUE ############################## ✅

community_value_decreasing <- read.csv(
  "_office/results/community_value/summary/decreasing.csv",
  sep = ";", header = TRUE, check.names = FALSE
) %>% select(-ncol(.))

max_community_value_decreasing <- as.data.frame(
  t(apply(community_value_decreasing, 1, max_in_row)))
colnames(max_community_value_decreasing) <- c("Max_Value", "Max_Column")

labels_max_community_value_decreasing <- as.data.frame(
  table(max_community_value_decreasing$Max_Column))
colnames(labels_max_community_value_decreasing) <- c("Column", "Count")

greedy_labels <- colnames(community_value_decreasing)
missing_labels <- setdiff(greedy_labels, labels_max_community_value_decreasing$Column)
missing_df <- data.frame(Column = missing_labels, Count = 0)
labels_max_community_value_decreasing <- rbind(
  labels_max_community_value_decreasing, missing_df)
labels_max_community_value_decreasing$Column <- as.character(
  labels_max_community_value_decreasing$Column)
labels_max_community_value_decreasing <- labels_max_community_value_decreasing[
  order(labels_max_community_value_decreasing$Column), ]

rm(greedy_labels)
rm(missing_labels)
rm(missing_df)

heatmap_data <- labels_max_community_value_decreasing %>%
  separate(Column, into = c("Parameter1", "Parameter2"), sep = "--") %>%
  mutate(Parameter1 = as.factor(Parameter1), Parameter2 = as.factor(Parameter2))

plot19 <- ggplot(data = heatmap_data, aes(x = Parameter1, y = Parameter2, fill = Count)) +
  geom_tile(color = "black") +
  geom_text(aes(label = Count), color = "black", size = 6) +
  scale_fill_gradient(
    low = "white",
    high = "#0073B2",
    limits = c(min(labels_max_community_value_decreasing$Count),
               max(labels_max_community_value_decreasing$Count)),
    breaks = c(min(labels_max_community_value_decreasing$Count),
               max(labels_max_community_value_decreasing$Count)),
    labels = scales::label_number(accuracy = 1)
  ) +
  theme_minimal(base_size = 15) +
  labs(
    title = "Decreasing Cascade",
    x = "Connected Percent",
    y = "Times Average",
    fill = "Best Influence"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.title = element_text(angle = 90, vjust = 0.9, margin = margin(b=20)),
    legend.justification = c(0.6, 0.4),
    legend.title.position = "top",
    legend.key.height = unit(1.25, "cm")
  )

rm(heatmap_data)


############################## COMBINED PLOT NARROW ############################## add plot 18 ❌

combined_plot <- plot1 + plot2 + plot3 + plot18 +
  plot_layout(ncol = 2) +
  plot_annotation(tag_levels = 'A')

ggsave("visualizations/combined_plot_narrow.png", combined_plot, width = 12, height = 10)

############################## COMBINED PLOT COMMUNITY VALUE ############################## ✅

combined_plot <- plot6 + plot7 + plot8 + plot19 +
  plot_layout(ncol = 2) +
  plot_annotation(tag_levels = 'A')

ggsave("visualizations/combined_plot_community_value.png", combined_plot, width = 12, height = 10)

############################## NARROW BREAKDOWN CASCADE MU ############################## ✅
keep <- data.frame(
  ON = numeric(),
  OM = numeric(),
  VALUE = numeric()
)
num = 0
for (mu in seq(0.1, 0.6, 0.1)) {
  for (on in seq(0.1, 0.6, 0.1)) {
    for (om in seq(2, 4, 1)) {
      num = num + 1
      if (abs(mu - 0.3) < .Machine$double.eps^0.5) {
        new_row <- data.frame(ON = on, OM = om, VALUE = max_greedy_narrow_20_cascade[num, "Max_Value"])
        keep <- rbind(keep, new_row)
      }
    }
  }
}

min_value <- min(as.numeric(keep$VALUE))
max_value <- max(as.numeric(keep$VALUE))
heat_colors <- rev(heat.colors(length(unique(keep$VALUE))))
plot9 <- ggplot(data = keep, aes(x = ON, y = OM, fill = VALUE)) +
  geom_tile(color = "black") +
  geom_text(aes(label = sprintf("%.1f", as.numeric(VALUE))), color = "black", size = 6) +
  scale_fill_manual(values = heat_colors, labels = sprintf("%.1f", as.numeric(sort(unique(keep$VALUE))))) +
  scale_x_continuous(breaks = unique(keep$ON), labels = unique(keep$ON)) +
  scale_y_continuous(breaks = unique(keep$OM), labels = unique(keep$OM)) +
  theme_minimal(base_size = 15) +
  labs(
    title = bquote("Independent Cascade, " * italic(mu) * " = 0.3"),
    x = expression(italic(o[n])),
    y = expression(italic(o[m])),
    fill = "VALUE"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "none"
  )

############################## NARROW BREAKDOWN THRESHOLD MU ############################## ✅
keep <- data.frame(
  ON = numeric(),
  OM = numeric(),
  VALUE = numeric()
)
num = 0
for (mu in seq(0.1, 0.6, 0.1)) {
  for (on in seq(0.1, 0.6, 0.1)) {
    for (om in seq(2, 4, 1)) {
      num = num + 1
      if (abs(mu - 0.3) < .Machine$double.eps^0.5) {
        new_row <- data.frame(ON = on, OM = om, VALUE = max_greedy_narrow_20_threshold[num, "Max_Value"])
        keep <- rbind(keep, new_row)
      }
    }
  }
}

min_value <- min(as.numeric(keep$VALUE))
max_value <- max(as.numeric(keep$VALUE))
heat_colors <- rev(heat.colors(length(unique(keep$VALUE))))
plot10 <- ggplot(data = keep, aes(x = ON, y = OM, fill = VALUE)) +
  geom_tile(color = "black") +
  geom_text(aes(label = sprintf("%.1f", as.numeric(VALUE))), color = "black", size = 6) +
  scale_fill_manual(values = heat_colors, labels = sprintf("%.1f", as.numeric(sort(unique(keep$VALUE))))) +
  scale_x_continuous(breaks = unique(keep$ON), labels = unique(keep$ON)) +
  scale_y_continuous(breaks = unique(keep$OM), labels = unique(keep$OM)) +
  theme_minimal(base_size = 15) +
  labs(
    title = bquote("Linear Threshold, " * italic(mu) * " = 0.3"),
    x = expression(italic(o[n])),
    y = expression(italic(o[m])),
    fill = "VALUE"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "none"
  )

############################## NARROW BREAKDOWN ONLYLISTENONCE MU ############################## ✅
keep <- data.frame(
  ON = numeric(),
  OM = numeric(),
  VALUE = numeric()
)
num = 0
for (mu in seq(0.1, 0.6, 0.1)) {
  for (on in seq(0.1, 0.6, 0.1)) {
    for (om in seq(2, 4, 1)) {
      num = num + 1
      if (abs(mu - 0.3) < .Machine$double.eps^0.5) {
        new_row <- data.frame(ON = on, OM = om, VALUE = max_greedy_narrow_20_onlylistenonce[num, "Max_Value"])
        keep <- rbind(keep, new_row)
      }
    }
  }
}

min_value <- min(as.numeric(keep$VALUE))
max_value <- max(as.numeric(keep$VALUE))
heat_colors <- rev(heat.colors(length(unique(keep$VALUE))))
plot11 <- ggplot(data = keep, aes(x = ON, y = OM, fill = VALUE)) +
  geom_tile(color = "black") +
  geom_text(aes(label = sprintf("%.1f", as.numeric(VALUE))), color = "black", size = 6) +
  scale_fill_manual(values = heat_colors, labels = sprintf("%.1f", as.numeric(sort(unique(keep$VALUE))))) +
  scale_x_continuous(breaks = unique(keep$ON), labels = unique(keep$ON)) +
  scale_y_continuous(breaks = unique(keep$OM), labels = unique(keep$OM)) +
  theme_minimal(base_size = 15) +
  labs(
    title = bquote("Only-Listen-Once, " * italic(mu) * " = 0.3"),
    x = expression(italic(o[n])),
    y = expression(italic(o[m])),
    fill = "VALUE"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "none"
  )

############################## NARROW BREAKDOWN DECREASING MU ############################## ❌
keep <- data.frame(
  ON = numeric(),
  OM = numeric(),
  VALUE = numeric()
)
num = 0
for (mu in seq(0.1, 0.6, 0.1)) {
  for (on in seq(0.1, 0.6, 0.1)) {
    for (om in seq(2, 4, 1)) {
      num = num + 1
      if (abs(mu - 0.3) < .Machine$double.eps^0.5) {
        new_row <- data.frame(ON = on, OM = om, VALUE = max_greedy_narrow_20_decreasing[num, "Max_Value"])
        keep <- rbind(keep, new_row)
      }
    }
  }
}

min_value <- min(as.numeric(keep$VALUE))
max_value <- max(as.numeric(keep$VALUE))
heat_colors <- rev(heat.colors(length(unique(keep$VALUE))))
plot20 <- ggplot(data = keep, aes(x = ON, y = OM, fill = VALUE)) +
  geom_tile(color = "black") +
  geom_text(aes(label = sprintf("%.1f", as.numeric(VALUE))), color = "black", size = 6) +
  scale_fill_manual(values = heat_colors, labels = sprintf("%.1f", as.numeric(sort(unique(keep$VALUE))))) +
  scale_x_continuous(breaks = unique(keep$ON), labels = unique(keep$ON)) +
  scale_y_continuous(breaks = unique(keep$OM), labels = unique(keep$OM)) +
  theme_minimal(base_size = 15) +
  labs(
    title = bquote("Decreasing Cascade, " * italic(mu) * " = 0.3"),
    x = expression(italic(o[n])),
    y = expression(italic(o[m])),
    fill = "VALUE"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "none"
  )

############################## NARROW BREAKDOWN CASCADE ON ############################## ✅
keep <- data.frame(
  MU = numeric(),
  OM = numeric(),
  VALUE = numeric()
)
num = 0
for (mu in seq(0.1, 0.6, 0.1)) {
  for (on in seq(0.1, 0.6, 0.1)) {
    for (om in seq(2, 4, 1)) {
      num = num + 1
      if (abs(on - 0.3) < .Machine$double.eps^0.5) {
        new_row <- data.frame(MU = mu, OM = om, VALUE = max_greedy_narrow_20_cascade[num, "Max_Value"])
        keep <- rbind(keep, new_row)
      }
    }
  }
}

min_value <- min(as.numeric(keep$VALUE))
max_value <- max(as.numeric(keep$VALUE))
heat_colors <- rev(heat.colors(length(unique(keep$VALUE))))
plot12 <- ggplot(data = keep, aes(x = MU, y = OM, fill = VALUE)) +
  geom_tile(color = "black") +
  geom_text(aes(label = sprintf("%.1f", as.numeric(VALUE))), color = "black", size = 6) +
  scale_fill_manual(values = heat_colors, labels = sprintf("%.1f", as.numeric(sort(unique(keep$VALUE))))) +
  scale_x_continuous(breaks = unique(keep$MU), labels = unique(keep$MU)) +
  scale_y_continuous(breaks = unique(keep$OM), labels = unique(keep$OM)) +
  theme_minimal(base_size = 15) +
  labs(
    title = bquote("Independent Cascade, " * italic(o[n]) * " = 0.3"),
    x = expression(italic(mu)),
    y = expression(italic(o[m])),
    fill = "VALUE"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "none"
  )

############################## NARROW BREAKDOWN THRESHOLD ON ############################## ✅
keep <- data.frame(
  MU = numeric(),
  OM = numeric(),
  VALUE = numeric()
)
num = 0
for (mu in seq(0.1, 0.6, 0.1)) {
  for (on in seq(0.1, 0.6, 0.1)) {
    for (om in seq(2, 4, 1)) {
      num = num + 1
      if (abs(on - 0.3) < .Machine$double.eps^0.5) {
        new_row <- data.frame(MU = mu, OM = om, VALUE = max_greedy_narrow_20_threshold[num, "Max_Value"])
        keep <- rbind(keep, new_row)
      }
    }
  }
}

min_value <- min(as.numeric(keep$VALUE))
max_value <- max(as.numeric(keep$VALUE))
heat_colors <- rev(heat.colors(length(unique(keep$VALUE))))
plot13 <- ggplot(data = keep, aes(x = MU, y = OM, fill = VALUE)) +
  geom_tile(color = "black") +
  geom_text(aes(label = sprintf("%.1f", as.numeric(VALUE))), color = "black", size = 6) +
  scale_fill_manual(values = heat_colors, labels = sprintf("%.1f", as.numeric(sort(unique(keep$VALUE))))) +
  scale_x_continuous(breaks = unique(keep$MU), labels = unique(keep$MU)) +
  scale_y_continuous(breaks = unique(keep$OM), labels = unique(keep$OM)) +
  theme_minimal(base_size = 15) +
  labs(
    title = bquote("Linear Threshold, " * italic(o[n]) * " = 0.3"),
    x = expression(italic(mu)),
    y = expression(italic(o[m])),
    fill = "VALUE"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "none"
  )

############################## NARROW BREAKDOWN ONLYLISTENONCE ON ############################## ✅
keep <- data.frame(
  MU = numeric(),
  OM = numeric(),
  VALUE = numeric()
)
num = 0
for (mu in seq(0.1, 0.6, 0.1)) {
  for (on in seq(0.1, 0.6, 0.1)) {
    for (om in seq(2, 4, 1)) {
      num = num + 1
      if (abs(on - 0.3) < .Machine$double.eps^0.5) {
        new_row <- data.frame(MU = mu, OM = om, VALUE = max_greedy_narrow_20_onlylistenonce[num, "Max_Value"])
        keep <- rbind(keep, new_row)
      }
    }
  }
}

min_value <- min(as.numeric(keep$VALUE))
max_value <- max(as.numeric(keep$VALUE))
heat_colors <- rev(heat.colors(length(unique(keep$VALUE))))
plot14 <- ggplot(data = keep, aes(x = MU, y = OM, fill = VALUE)) +
  geom_tile(color = "black") +
  geom_text(aes(label = sprintf("%.1f", as.numeric(VALUE))), color = "black", size = 6) +
  scale_fill_manual(values = heat_colors, labels = sprintf("%.1f", as.numeric(sort(unique(keep$VALUE))))) +
  scale_x_continuous(breaks = unique(keep$MU), labels = unique(keep$MU)) +
  scale_y_continuous(breaks = unique(keep$OM), labels = unique(keep$OM)) +
  theme_minimal(base_size = 15) +
  labs(
    title = bquote("Only-Listen-Once, " * italic(o[n]) * " = 0.3"),
    x = expression(italic(mu)),
    y = expression(italic(o[m])),
    fill = "VALUE"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "none"
  )

############################## NARROW BREAKDOWN DECREASING ON ############################## ❌
keep <- data.frame(
  MU = numeric(),
  OM = numeric(),
  VALUE = numeric()
)
num = 0
for (mu in seq(0.1, 0.6, 0.1)) {
  for (on in seq(0.1, 0.6, 0.1)) {
    for (om in seq(2, 4, 1)) {
      num = num + 1
      if (abs(on - 0.3) < .Machine$double.eps^0.5) {
        new_row <- data.frame(MU = mu, OM = om, VALUE = max_greedy_narrow_20_decreasing[num, "Max_Value"])
        keep <- rbind(keep, new_row)
      }
    }
  }
}

min_value <- min(as.numeric(keep$VALUE))
max_value <- max(as.numeric(keep$VALUE))
heat_colors <- rev(heat.colors(length(unique(keep$VALUE))))
plot21 <- ggplot(data = keep, aes(x = MU, y = OM, fill = VALUE)) +
  geom_tile(color = "black") +
  geom_text(aes(label = sprintf("%.1f", as.numeric(VALUE))), color = "black", size = 6) +
  scale_fill_manual(values = heat_colors, labels = sprintf("%.1f", as.numeric(sort(unique(keep$VALUE))))) +
  scale_x_continuous(breaks = unique(keep$MU), labels = unique(keep$MU)) +
  scale_y_continuous(breaks = unique(keep$OM), labels = unique(keep$OM)) +
  theme_minimal(base_size = 15) +
  labs(
    title = bquote("Decreasing Cascade, " * italic(o[n]) * " = 0.3"),
    x = expression(italic(mu)),
    y = expression(italic(o[m])),
    fill = "VALUE"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "none"
  )

############################## NARROW BREAKDOWN CASCADE OM ############################## ✅
keep <- data.frame(
  MU = numeric(),
  OM = numeric(),
  VALUE = numeric()
)
num = 0
for (mu in seq(0.1, 0.6, 0.1)) {
  for (on in seq(0.1, 0.6, 0.1)) {
    for (om in seq(2, 4, 1)) {
      num = num + 1
      if (abs(om - 3) < .Machine$double.eps^0.5) {
        new_row <- data.frame(MU = mu, ON = on, VALUE = max_greedy_narrow_20_cascade[num, "Max_Value"])
        keep <- rbind(keep, new_row)
      }
    }
  }
}

min_value <- min(as.numeric(keep$VALUE))
max_value <- max(as.numeric(keep$VALUE))
heat_colors <- rev(heat.colors(length(unique(keep$VALUE))))
plot15 <- ggplot(data = keep, aes(x = MU, y = ON, fill = VALUE)) +
  geom_tile(color = "black") +
  geom_text(aes(label = sprintf("%.1f", as.numeric(VALUE))), color = "black", size = 6) +
  scale_fill_manual(values = heat_colors, labels = sprintf("%.1f", as.numeric(sort(unique(keep$VALUE))))) +
  scale_x_continuous(breaks = unique(keep$MU), labels = unique(keep$MU)) +
  scale_y_continuous(breaks = unique(keep$ON), labels = unique(keep$ON)) +
  theme_minimal(base_size = 15) +
  labs(
    title = bquote("Independent Cascade, " * italic(o[m]) * " = 3"),
    x = expression(italic(mu)),
    y = expression(italic(o[n])),
    fill = "VALUE"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "none"
  )

############################## NARROW BREAKDOWN THRESHOLD OM ############################## ✅
keep <- data.frame(
  MU = numeric(),
  OM = numeric(),
  VALUE = numeric()
)
num = 0
for (mu in seq(0.1, 0.6, 0.1)) {
  for (on in seq(0.1, 0.6, 0.1)) {
    for (om in seq(2, 4, 1)) {
      num = num + 1
      if (abs(om - 3) < .Machine$double.eps^0.5) {
        new_row <- data.frame(MU = mu, ON = on, VALUE = max_greedy_narrow_20_threshold[num, "Max_Value"])
        keep <- rbind(keep, new_row)
      }
    }
  }
}

min_value <- min(as.numeric(keep$VALUE))
max_value <- max(as.numeric(keep$VALUE))
heat_colors <- rev(heat.colors(length(unique(keep$VALUE))))
plot16 <- ggplot(data = keep, aes(x = MU, y = ON, fill = VALUE)) +
  geom_tile(color = "black") +
  geom_text(aes(label = sprintf("%.1f", as.numeric(VALUE))), color = "black", size = 6) +
  scale_fill_manual(values = heat_colors, labels = sprintf("%.1f", as.numeric(sort(unique(keep$VALUE))))) +
  scale_x_continuous(breaks = unique(keep$MU), labels = unique(keep$MU)) +
  scale_y_continuous(breaks = unique(keep$ON), labels = unique(keep$ON)) +
  theme_minimal(base_size = 15) +
  labs(
    title = bquote("Linear Threshold, " * italic(o[m]) * " = 3"),
    x = expression(italic(mu)),
    y = expression(italic(o[n])),
    fill = "VALUE"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "none"
  )

############################## NARROW BREAKDOWN ONLYLISTENONCE OM ############################## ✅
keep <- data.frame(
  MU = numeric(),
  OM = numeric(),
  VALUE = numeric()
)
num = 0
for (mu in seq(0.1, 0.6, 0.1)) {
  for (on in seq(0.1, 0.6, 0.1)) {
    for (om in seq(2, 4, 1)) {
      num = num + 1
      if (abs(om - 3) < .Machine$double.eps^0.5) {
        new_row <- data.frame(MU = mu, ON = on, VALUE = max_greedy_narrow_20_onlylistenonce[num, "Max_Value"])
        keep <- rbind(keep, new_row)
      }
    }
  }
}

min_value <- min(as.numeric(keep$VALUE))
max_value <- max(as.numeric(keep$VALUE))
heat_colors <- rev(heat.colors(length(unique(keep$VALUE))))
plot17 <- ggplot(data = keep, aes(x = MU, y = ON, fill = VALUE)) +
  geom_tile(color = "black") +
  geom_text(aes(label = sprintf("%.1f", as.numeric(VALUE))), color = "black", size = 6) +
  scale_fill_manual(values = heat_colors, labels = sprintf("%.1f", as.numeric(sort(unique(keep$VALUE))))) +
  scale_x_continuous(breaks = unique(keep$MU), labels = unique(keep$MU)) +
  scale_y_continuous(breaks = unique(keep$ON), labels = unique(keep$ON)) +
  theme_minimal(base_size = 15) +
  labs(
    title = bquote("Only-Listen-Once, " * italic(o[m]) * " = 3"),
    x = expression(italic(mu)),
    y = expression(italic(o[n])),
    fill = "VALUE"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "none"
  )

############################## NARROW BREAKDOWN ONLYLISTENONCE OM ############################## ❌
keep <- data.frame(
  MU = numeric(),
  OM = numeric(),
  VALUE = numeric()
)
num = 0
for (mu in seq(0.1, 0.6, 0.1)) {
  for (on in seq(0.1, 0.6, 0.1)) {
    for (om in seq(2, 4, 1)) {
      num = num + 1
      if (abs(om - 3) < .Machine$double.eps^0.5) {
        new_row <- data.frame(MU = mu, ON = on, VALUE = max_greedy_narrow_20_decreasing[num, "Max_Value"])
        keep <- rbind(keep, new_row)
      }
    }
  }
}

min_value <- min(as.numeric(keep$VALUE))
max_value <- max(as.numeric(keep$VALUE))
heat_colors <- rev(heat.colors(length(unique(keep$VALUE))))
plot22 <- ggplot(data = keep, aes(x = MU, y = ON, fill = VALUE)) +
  geom_tile(color = "black") +
  geom_text(aes(label = sprintf("%.1f", as.numeric(VALUE))), color = "black", size = 6) +
  scale_fill_manual(values = heat_colors, labels = sprintf("%.1f", as.numeric(sort(unique(keep$VALUE))))) +
  scale_x_continuous(breaks = unique(keep$MU), labels = unique(keep$MU)) +
  scale_y_continuous(breaks = unique(keep$ON), labels = unique(keep$ON)) +
  theme_minimal(base_size = 15) +
  labs(
    title = bquote("Decreasing Cascade, " * italic(o[m]) * " = 3"),
    x = expression(italic(mu)),
    y = expression(italic(o[n])),
    fill = "VALUE"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "none"
  )

############################## COMBINED PLOT GRAPH VARIABLES ############################## add plots 20, 21, 22 ❌

combined_plot <- plot9 + plot10 + plot11 +
  plot12 + plot13 + plot14 +
  plot15 + plot16 + plot17 +
  plot_layout(ncol = 3) +
  plot_annotation(tag_levels = 'A')

ggsave("visualizations/combined_plot_3x3.png", combined_plot, width = 16, height = 12)

############################## COMPARISON OF INFLUENCE VALUES ############################## ❌

data <- data.frame(
  Settings = rep(c("Community values (best)", "Narrow greedy (best)", "Full greedy"), each = 4),
  Model = rep(c("Independent Cascade", "Linear Threshold", "Only-Listen-Once", "Decreasing Cascade"), times = 3),
  #Value = c(147.82, 156.96, 65.63, 170.32, 183.30, 74.49, 173.42, 186.09, 78.55)
  Value = c(147.82, 156.96, 65.63, 0, 170.32, 183.30, 74.49, 0, 173.42, 186.09, 78.55, 0)
)

data$Settings <- factor(data$Settings, levels = c("Community values (best)", "Narrow greedy (best)", "Full greedy"))
data$Model <- factor(data$Model, levels = c("Independent Cascade", "Linear Threshold", "Only-Listen-Once", "Decreasing Cascade"))

plot_comparison_of_influence_values <- ggplot(data, aes(x = Model, y = Value, fill = Settings)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_minimal(base_size = 15) +
  labs(
    x = "Model",
    y = "Average Influence Value"
  ) +
  scale_fill_manual(
    values = c("#70AD47", "#FFC000", "#ED7D31")
  ) +
  theme(
    legend.position = "bottom"
  )

ggsave("visualizations/plot_performance.png", plot_comparison_of_influence_values, width = 8, height = 6)

############################## COMPARISON OF RUNTIMES ############################## ❌

data <- data.frame(
  Steps = c(
    "Influence graphs", "Community detection", "Narrow greedy",
    "Full greedy", "Influence graphs", "Community detection",
    "Narrow greedy", "Full greedy", "Influence graphs",
    "Community detection", "Narrow greedy", "Full greedy",
    "Influence graphs", "Community detection", "Narrow greedy",
    "Full greedy"
  ),
  Model = rep(c("Independent Cascade", "Linear Threshold", "Only-Listen-Once", "Decreasing Cascade"), each = 4),
  #Value = c(103, 16, 158, 374, 48, 34, 74, 262, 31, 139, 51, 128),
  Value = c(103, 16, 158, 374, 48, 34, 74, 262, 31, 139, 51, 128, 0, 0, 0, 0),
  Type = rep(c("Stacked", "Stacked", "Stacked", "Full greedy"), times = 4)
)

data$Steps <- factor(data$Steps, levels = c("Narrow greedy", "Community detection", "Influence graphs", "Full greedy"))
data$Model <- factor(data$Model, levels = c("Independent Cascade", "Linear Threshold", "Only-Listen-Once", "Decreasing Cascade"))

plot_comparison_of_runtimes <- ggplot(data, aes(x = Model, y = Value, fill = Steps)) +
  geom_bar(data = subset(data, Type == "Stacked"), 
           aes(x = Model, fill = Steps), 
           stat = "identity", position = "stack", width = 0.4,
           just = 1) +
  geom_bar(data = subset(data, Type == "Full greedy"), 
           aes(x = Model, fill = "Full greedy"),
           stat = "identity", position = position_dodge(width = 1), width = 0.4,
           just = 0) +
  theme_minimal(base_size = 15) +
  labs(
    x = "Model",
    y = "Runtime (seconds)",
    fill = "Steps"
  ) +
  scale_fill_manual(
    values = c(
      "Influence graphs" = "#5F5F5F",
      "Community detection" = "#5A9BD5",
      "Narrow greedy" = "#FFC000",
      "Full greedy" = "#ED7D31"
    )
  ) +
  theme(
    legend.position = "bottom"
  )

ggsave("visualizations/plot_runtime.png", plot_comparison_of_runtimes, width = 8, height = 6)

############################## COMPARISON OF INFLUENCE VALUES CITHEP ############################## ❌

data <- data.frame(
  Settings = rep(c("Community values (best)", "Narrow greedy (best)", "Full greedy"), each = 4),
  Model = rep(c("Independent Cascade", "Linear Threshold", "Only-Listen-Once", "Decreasing Cascade"), times = 3),
  #Value = c(1776.47, 691.80, 247.16, 4304.14, 1013.97, 657.99, 4289.16, 1006.66, 720.45)
  Value = c(1776.47, 691.80, 247.16, 1069.33,
            4304.14, 1013.97, 657.99, 988.08,
            4289.16, 1006.66, 720.45, 1021.58)
)

data$Settings <- factor(data$Settings, levels = c("Community values (best)", "Narrow greedy (best)", "Full greedy"))
data$Model <- factor(data$Model, levels = c("Independent Cascade", "Linear Threshold", "Only-Listen-Once", "Decreasing Cascade"))

plot_comparison_of_influence_values <- ggplot(data, aes(x = Model, y = Value, fill = Settings)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_minimal(base_size = 15) +
  labs(
    x = "Model",
    y = "Average Influence Value"
  ) +
  scale_fill_manual(
    values = c("#70AD47", "#FFC000", "#ED7D31")
  ) +
  theme(
    legend.position = "bottom"
  )

ggsave("visualizations/plot_performance_cithep.png", plot_comparison_of_influence_values, width = 8, height = 6)



############################## COMPARISON OF RUNTIMES CITHEP ############################## ❌

data <- data.frame(
  Steps = c(
    "Influence graphs", "Community detection", "Narrow greedy",
    "Full greedy", "Influence graphs", "Community detection",
    "Narrow greedy", "Full greedy", "Influence graphs",
    "Community detection", "Narrow greedy", "Full greedy",
    "Influence graphs", "Community detection", "Narrow greedy",
    "Full greedy"
  ),
  Model = rep(c("Independent Cascade", "Linear Threshold", "Only-Listen-Once", "Decreasing Cascade"), each = 5),
  #Value = c(5966, 348, 4743, 35857, 1654, 484, 1095, 5094, 2181, 1343, 665, 4857),
  Value = c(5966, 348, 4743, 35857, 1654, 484, 1095, 5094, 2181, 1343, 665, 4857, 0, 0, 0, 0),
  Type = rep(c("Stacked", "Stacked", "Stacked", "Full greedy"), times = 4)
)

data$Steps <- factor(data$Steps, levels = c("Narrow greedy", "Community detection", "Influence graphs", "Full greedy"))
data$Model <- factor(data$Model, levels = c("Independent Cascade", "Linear Threshold", "Only-Listen-Once", "Decreasing Cascade"))

plot_comparison_of_runtimes <- ggplot(data, aes(x = Model, y = Value, fill = Steps)) +
  geom_bar(data = subset(data, Type == "Stacked"), 
           aes(x = Model, fill = Steps), 
           stat = "identity", position = "stack", width = 0.4,
           just = 1) +
  geom_bar(data = subset(data, Type == "Full greedy"), 
           aes(x = Model, fill = "Full greedy"),
           stat = "identity", position = position_dodge(width = 1), width = 0.4,
           just = 0) +
  theme_minimal(base_size = 15) +
  labs(
    x = "Model",
    y = "Runtime (seconds)",
    fill = "Steps"
  ) +
  scale_fill_manual(
    values = c(
      "Influence graphs" = "#5F5F5F",
      "Community detection" = "#5A9BD5",
      "Narrow greedy" = "#FFC000",
      "Full greedy" = "#ED7D31"
    )
  ) +
  theme(
    legend.position = "bottom"
  )

ggsave("visualizations/plot_runtime_cithep.png", plot_comparison_of_runtimes, width = 8, height = 6)

############################## COMPARISON OF INFLUENCE VALUES SOCEPINIONS ############################## ❌

data <- data.frame(
  Settings = rep(c("Community values (best)", "Narrow greedy (best)", "Full greedy"), each = 4),
  Model = rep(c("Independent Cascade", "Linear Threshold", "Only-Listen-Once", "Decreasing Cascade"), times = 3),
  #Value = c(10343.85, 232.29, 839.56, 10337.01, 3037.17, 838.89, 10464.61, 3615.53, 1386.21)
  Value = c(10343.85, 232.29, 839.56, 0, 10337.01, 3037.17, 838.89, 0, 10464.61, 3615.53, 1386.21, 0)
)

data$Settings <- factor(data$Settings, levels = c("Community values (best)", "Narrow greedy (best)", "Full greedy"))
data$Model <- factor(data$Model, levels = c("Independent Cascade", "Linear Threshold", "Only-Listen-Once", "Decreasing Cascade"))

plot_comparison_of_influence_values <- ggplot(data, aes(x = Model, y = Value, fill = Settings)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_minimal(base_size = 15) +
  labs(
    x = "Model",
    y = "Average Influence Value"
  ) +
  scale_fill_manual(
    values = c("#70AD47", "#FFC000", "#ED7D31")
  ) +
  theme(
    legend.position = "bottom"
  )

ggsave("visualizations/plot_performance_socepinions.png", plot_comparison_of_influence_values, width = 8, height = 6)



############################## COMPARISON OF RUNTIMES SOCEPINIONS ############################## ❌

data <- data.frame(
  Steps = c(
    "Influence graphs", "Community detection", "Narrow greedy",
    "Full greedy", "Influence graphs", "Community detection",
    "Narrow greedy", "Full greedy", "Influence graphs",
    "Community detection", "Narrow greedy", "Full greedy",
    "Influence graphs", "Community detection", "Narrow greedy",
    "Full greedy"
  ),
  Model = rep(c("Independent Cascade", "Linear Threshold", "Only-Listen-Once", "Decreasing Cascade"), each = 4),
  #Value = c(10443, 9212, 575, 294897, 2564, 2436, 8711, 48087, 5302, 4272, 169, 26481),
  Value = c(10443, 9212, 575, 294897, 2564, 2436, 8711, 48087, 5302, 4272, 169, 26481, 0, 0, 0, 0),
  Type = rep(c("Stacked", "Stacked", "Stacked", "Full greedy"), times = 4)
)

data$Steps <- factor(data$Steps, levels = c("Narrow greedy", "Community detection", "Influence graphs", "Full greedy"))
data$Model <- factor(data$Model, levels = c("Independent Cascade", "Linear Threshold", "Only-Listen-Once", "Decreasing Cascade"))

plot_comparison_of_runtimes <- ggplot(data, aes(x = Model, y = Value, fill = Steps)) +
  geom_bar(data = subset(data, Type == "Stacked"), 
           aes(x = Model, fill = Steps), 
           stat = "identity", position = "stack", width = 0.4,
           just = 1) +
  geom_bar(data = subset(data, Type == "Full greedy"), 
           aes(x = Model, fill = "Full greedy"),
           stat = "identity", position = position_dodge(width = 1), width = 0.4,
           just = 0) +
  theme_minimal(base_size = 15) +
  labs(
    x = "Model",
    y = "Runtime (seconds)",
    fill = "Steps"
  ) +
  scale_fill_manual(
    values = c(
      "Influence graphs" = "#5F5F5F",
      "Community detection" = "#5A9BD5",
      "Narrow greedy" = "#FFC000",
      "Full greedy" = "#ED7D31"
    )
  ) +
  theme(
    legend.position = "bottom"
  )

ggsave("visualizations/plot_runtime_socepinions.png", plot_comparison_of_runtimes, width = 8, height = 6)

############################## COMPARISON OF INFLUENCE VALUES EMAILEUALL ############################## ❌

data <- data.frame(
  Settings = rep(c("Community values (best)", "Narrow greedy (best)", "Full greedy"), each = 4),
  Model = rep(c("Independent Cascade", "Linear Threshold", "Only-Listen-Once", "Decreasing Cascade"), times = 3),
  #Value = c(7021.69, 563.97, 949.39, 7371.71, 2317.14, 1328.67, 7410.67, 2290.82, 1620.68)
  Value = c(7021.69, 563.97, 949.39, 0, 7371.71, 2317.14, 1328.67, 0, 7410.67, 2290.82, 1620.68, 0)
)

data$Settings <- factor(data$Settings, levels = c("Community values (best)", "Narrow greedy (best)", "Full greedy"))
data$Model <- factor(data$Model, levels = c("Independent Cascade", "Linear Threshold", "Only-Listen-Once", "Decreasing Cascade"))

plot_comparison_of_influence_values <- ggplot(data, aes(x = Model, y = Value, fill = Settings)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_minimal(base_size = 15) +
  labs(
    x = "Model",
    y = "Average Influence Value"
  ) +
  scale_fill_manual(
    values = c("#70AD47", "#FFC000", "#ED7D31")
  ) +
  theme(
    legend.position = "bottom"
  )

ggsave("visualizations/plot_performance_emaileuall.png", plot_comparison_of_influence_values, width = 8, height = 6)



############################## COMPARISON OF RUNTIMES EMAILEUALL ############################## ❌

data <- data.frame(
  Steps = c(
    "Influence graphs", "Community detection", "Narrow greedy",
    "Full greedy", "Influence graphs", "Community detection",
    "Narrow greedy", "Full greedy", "Influence graphs",
    "Community detection", "Narrow greedy", "Full greedy",
    "Influence graphs", "Community detection", "Narrow greedy",
    "Full greedy"
  ),
  Model = rep(c("Independent Cascade", "Linear Threshold", "Only-Listen-Once", "Decreasing Cascade"), each = 4),
  #Value = c(10663, 6917, 13598, 561009, 5358, 3145, 16982, 91434, 10666, 3018, 527, 82637),
  Value = c(10663, 6917, 13598, 561009, 5358, 3145, 16982, 91434, 10666, 3018, 527, 82637, 0, 0, 0, 0),
  Type = rep(c("Stacked", "Stacked", "Stacked", "Full greedy"), times = 4)
)

data$Steps <- factor(data$Steps, levels = c("Narrow greedy", "Community detection", "Influence graphs", "Full greedy"))
data$Model <- factor(data$Model, levels = c("Independent Cascade", "Linear Threshold", "Only-Listen-Once", "Decreasing Cascade"))

plot_comparison_of_runtimes <- ggplot(data, aes(x = Model, y = Value, fill = Steps)) +
  geom_bar(data = subset(data, Type == "Stacked"), 
           aes(x = Model, fill = Steps), 
           stat = "identity", position = "stack", width = 0.4,
           just = 1) +
  geom_bar(data = subset(data, Type == "Full greedy"), 
           aes(x = Model, fill = "Full greedy"),
           stat = "identity", position = position_dodge(width = 1), width = 0.4,
           just = 0) +
  theme_minimal(base_size = 15) +
  labs(
    x = "Model",
    y = "Runtime (seconds)",
    fill = "Steps"
  ) +
  scale_fill_manual(
    values = c(
      "Influence graphs" = "#5F5F5F",
      "Community detection" = "#5A9BD5",
      "Narrow greedy" = "#FFC000",
      "Full greedy" = "#ED7D31"
    )
  ) +
  theme(
    legend.position = "bottom"
  )

ggsave("visualizations/plot_runtime_emaileuall.png", plot_comparison_of_runtimes, width = 8, height = 6)

############################## COMPARISON OF INFLUENCE VALUES WIKIVOTE ############################## ❌

data <- data.frame(
  Settings = rep(c("Community values (best)", "Narrow greedy (best)", "Full greedy"), each = 4),
  Model = rep(c("Independent Cascade", "Linear Threshold", "Only-Listen-Once", "Decreasing Cascade"), times = 3),
  #Value = c(7021.69, 563.97, 949.39, 7371.71, 2317.14, 1328.67, 7410.67, 2290.82, 1620.68)
  Value = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
)

data$Settings <- factor(data$Settings, levels = c("Community values (best)", "Narrow greedy (best)", "Full greedy"))
data$Model <- factor(data$Model, levels = c("Independent Cascade", "Linear Threshold", "Only-Listen-Once", "Decreasing Cascade"))

plot_comparison_of_influence_values <- ggplot(data, aes(x = Model, y = Value, fill = Settings)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_minimal(base_size = 15) +
  labs(
    x = "Model",
    y = "Average Influence Value"
  ) +
  scale_fill_manual(
    values = c("#70AD47", "#FFC000", "#ED7D31")
  ) +
  theme(
    legend.position = "bottom"
  )

ggsave("visualizations/plot_performance_wikivote.png", plot_comparison_of_influence_values, width = 8, height = 6)



############################## COMPARISON OF RUNTIMES WIKIVOTE ############################## ❌

data <- data.frame(
  Steps = c(
    "Influence graphs", "Community detection", "Narrow greedy",
    "Full greedy", "Influence graphs", "Community detection",
    "Narrow greedy", "Full greedy", "Influence graphs",
    "Community detection", "Narrow greedy", "Full greedy",
    "Influence graphs", "Community detection", "Narrow greedy",
    "Full greedy"
  ),
  Model = rep(c("Independent Cascade", "Linear Threshold", "Only-Listen-Once", "Decreasing Cascade"), each = 4),
  #Value = c(10663, 6917, 13598, 561009, 5358, 3145, 16982, 91434, 10666, 3018, 527, 82637),
  Value = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  Type = rep(c("Stacked", "Stacked", "Stacked", "Full greedy"), times = 4)
)

data$Steps <- factor(data$Steps, levels = c("Narrow greedy", "Community detection", "Influence graphs", "Full greedy"))
data$Model <- factor(data$Model, levels = c("Independent Cascade", "Linear Threshold", "Only-Listen-Once", "Decreasing Cascade"))

plot_comparison_of_runtimes <- ggplot(data, aes(x = Model, y = Value, fill = Steps)) +
  geom_bar(data = subset(data, Type == "Stacked"), 
           aes(x = Model, fill = Steps), 
           stat = "identity", position = "stack", width = 0.4,
           just = 1) +
  geom_bar(data = subset(data, Type == "Full greedy"), 
           aes(x = Model, fill = "Full greedy"),
           stat = "identity", position = position_dodge(width = 1), width = 0.4,
           just = 0) +
  theme_minimal(base_size = 15) +
  labs(
    x = "Model",
    y = "Runtime (seconds)",
    fill = "Steps"
  ) +
  scale_fill_manual(
    values = c(
      "Influence graphs" = "#5F5F5F",
      "Community detection" = "#5A9BD5",
      "Narrow greedy" = "#FFC000",
      "Full greedy" = "#ED7D31"
    )
  ) +
  theme(
    legend.position = "bottom"
  )

ggsave("visualizations/plot_runtime_wikivote.png", plot_comparison_of_runtimes, width = 8, height = 6)

############################## COMPARISON OF OVERLAPS ############################## ❌

data <- data.frame(
  Model = rep(c("Independent Cascade", "Linear Threshold", "Only-Listen-Once", "Decreasing Cascade"), each = 5),
  Graph = rep(c("Artificial (avg)", "Wiki-Vote", "cit-HepPh", "soc-Epinions1", "email-EuAll"), times = 4),
  #Value = c(36.64815, 54, 0, 52,
            #38.25926, 80, 44, 84,
            #16.76636, 44, 12, 52)
  Value = c(36.64815, 0, 54, 0, 52,
            38.25926, 0, 80, 44, 84,
            16.76636, 0, 44, 12, 52,
            0, 0, 0, 0, 0)
)

data$Model <- factor(data$Model, levels = c("Independent Cascade", "Linear Threshold", "Only-Listen-Once", "Decreasing Cascade"))
data$Graph <- factor(data$Graph, levels = c("Artificial (avg)", "Wiki-Vote", "cit-HepPh", "soc-Epinions1", "email-EuAll"))

plot_overlap <- ggplot(data, aes(x = Model, y = Value, fill = Graph)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  labs(x = "Model",
       y = "Overlap (percentage)",
       fill = "Graph") +
  scale_fill_manual(
    values = c(
      "Artificial (avg)" = "#E8DCD0",
      "Wiki-Vote" = "#6F4E37",
      "cit-HepPh" = "#D4C0AB",
      "soc-Epinions1" = "#C19E77",
      "email-EuAll" = "#91683C"
    )
  ) +
  theme_minimal(base_size = 15)

ggsave("visualizations/plot_overlap.png", plot_overlap, width = 12, height = 6)
