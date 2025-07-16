library(readr)
library(dplyr)
library(ggplot2)

years_per_gen <- 28
mutation_type <- "TA/CT"

files <- list(
  POP1 = "Trial_MMN_mutratefin_chr20.rate.tsv",
  POP2 = "Trial_ATM_mutratefin_chr20.rate.tsv",
  POP3 = "Trial_ATL_mutratefin_chr20.rate.tsv",
  POP4 = "Trial_SLM_mutratefin_chr20.rate.tsv",
  POP5 = "Trial_APF_mutratefin_chr20.rate.tsv",
  POP6 = "Trial_ROL_mutratefin_chr20.rate.tsv"
)

data_list <- lapply(names(files), function(pop) {
  df <- read_table(files[[pop]])
  
  colnames(df)[1] <- "Epoch"
  df$Epoch <- as.numeric(df$Epoch)
  df$Time <- df$Epoch * years_per_gen
  
  # Convert all rate columns to numeric
  df[-c(1, ncol(df))] <- lapply(df[-c(1, ncol(df))], function(col) as.numeric(trimws(col)))
  
  # Normalize all mutation rate columns to mean = 1
  rate_cols <- setdiff(colnames(df), c("Epoch", "Time"))
  df[rate_cols] <- lapply(df[rate_cols], function(col) {
    if (mean(col, na.rm = TRUE) == 0) return(rep(0, length(col)))
    col / mean(col, na.rm = TRUE)
  })
  
  if (!(mutation_type %in% colnames(df))) {
    warning(paste("Mutation type", mutation_type, "not found in", files[[pop]]))
    return(NULL)
  }
  
  df <- df %>%
    mutate(
      MutationRate = .data[[mutation_type]],
      Population = recode(pop,
                          POP1 = "MMN",
                          POP2 = "ATM",
                          POP3 = "ATL",
                          POP4 = "SLM",
                          POP5 = "APF",
                          POP6 = "ROL")
    ) %>%
    filter(!is.na(Time) & !is.na(MutationRate) & MutationRate > 0)
  
  return(df)
})

# Combine all data
combined_df <- bind_rows(data_list)

# Plot
ggplot(combined_df, aes(x = Time, y = MutationRate, color = Population)) +
  geom_line(linewidth = 1) +
  #eom_hline(yintercept = 1, linetype = "dashed", color = "gray50") +
  scale_x_log10() +
  scale_y_log10() +
  labs(
    title = paste("Normalized Mutation Rate:", mutation_type),
    x = "Years Ago (log scale)",
    y = "Normalized Mutation Rate"
  ) +
  theme_minimal(base_size = 14) +
  scale_color_brewer(palette = "Set1") +
  theme(
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white")
  )
