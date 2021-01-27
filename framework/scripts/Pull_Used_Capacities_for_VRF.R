library(here)
library(tidyverse)
dir <- "analysis/baseline-mumr/runs/mumr-baseline/"
cz <- c("cz01", "cz02", "cz03", "cz04", "cz05", "cz06", "cz07", "cz08", "cz09", "cz10", "cz11", "cz12", "cz13",
        "cz14", "cz15", "cz16")

Name <- c()
Cool_Capacity <- c()
Heat_Capacity <- c()
ClimateZone <- c()

df <- data.frame(Name, Cool_Capacity, Heat_Capacity, ClimateZone)


for(climate_zone in cz){
  
  read_in <- read_csv(here::here(paste(dir, climate_zone, "/instance - run/instance - ap - HVACSecondary.csv", sep = "")), skip = 12)
  
  filtered <- read_in %>% filter(Name %in% c("ZnSys F5 Studio SE", "ZnSys F2-4 1-Bed North",
                                             "ZnSys F2-4 2-Bed East", "ZnSys F5 3-Bed NE")) %>%
    select(Name, `Net Capacity`, `Net Capacity_1`) %>% 
    mutate(`Climate Zone` = climate_zone)
  
  names(filtered) <- c("Name", "Cool_Capacity", "Heat_Capacity", "ClimateZone")
  
  df <- rbind(df, filtered)
  
}

df_sorted <- df %>% arrange(Name)

write_csv(df_sorted, here::here("autosizing/mixed-use-mid-rise/autosizing_summary.csv"))