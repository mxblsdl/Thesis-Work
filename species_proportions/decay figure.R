
## Script for loading species decay values and plotting in box plot 

# Load libraries
library(tidyverse)

proportions <- read.csv("species_props.csv", stringsAsFactors = F)

spec <- read_csv("../ResidualTreeLists/csv/Species.csv", col_types = cols()) %>%
  dplyr::select(c(PlantsCode, FVSCode)) %>%
  rename(Spp = FVSCode)

proportions <- left_join(proportions, spec)
rm(spec)
# Load final data FIXME
# Get all individual data frames and join into one long df
# dfs <- dir("decay_by_species", full.names = T)
# dfs <- lapply(dfs, read_rds)
# dfs <- bind_rows(dfs)

#saveRDS(dfs, "rasterValuesAll.RDS")

# plotting

# Subset data for plot construction
dfs <- read_rds("rasterValuesAll.rds")

# take random sample for quicker iterations in constructin plots 
dfs <- dfs[sample(nrow(dfs), 100000000, replace = F), ]

# clear gc() to free memory
gc()
gc()

## Prepare data
# arrange by species
dfs <- dfs %>% arrange(species)

# add class distinction
dfs <- dfs %>% 
  mutate(class = case_when(species == "QUKE" ~ "Angiosperm",
                           species == "QUCH2" ~ "Angiosperm",
                           TRUE ~ "Gymnosperm"))


# add names to df to make more readable
dfs <- left_join(dfs, proportions %>% select(PlantsCode, name), by = c("species" = "PlantsCode"))

# drop species column for space
dfs <- dfs %>% 
  select(-species)

# reorder by factor to match % prominence
dfs$name <- factor(dfs$name, levels = c("Douglas-fir",
                                        "Ponderosa Pine", 
                                        "White Fir", 
                                        "Incense Cedar", 
                                        "Jeffrey Pine",
                                        "California Black Oak",
                                        "California Red Fir",
                                        "Sugar Pine",
                                        "Canyon Live Oak",
                                        "Grand Fir"), ordered = T)

# TODO look into fst package
# write out prepared data for quicker plotting 



# *consider* Taking a sample of the data as the whole dataset is too large and not a lot may be gained from looking at everything as opposed to a smaple

# Plotting

ggplot(dfs) +
  geom_boxplot(aes(name, value, fill = class)) +
  theme_minimal() +
  labs(y = "Decay Values",
       x = "Species",
       fill = "Class") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


#consider using a groub_by_all %>% count to determine hwo many rows I could possibly remove by using some type of factor. I have lots of duplicate rows, but I want to retain the same ratio of unique values. 

memory.limit()

t <- dfs %>% group_by_all() %>% count()

gc()
t %>% arrange(name)


t$n %>% sum()

ggplot(t) +
  geom_boxplot(aes(name, value))

