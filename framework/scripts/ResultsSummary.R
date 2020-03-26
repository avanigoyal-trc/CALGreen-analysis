library(here)
library(tidyverse)
library(openxlsx)



results_spreadsheet <- function(path){
  ##path: String format, path to results spreadsheet starting at framework ie. "analysis/hvac_autosizing"
  
  readin <- read_csv(here::here(paste(path, "/results.csv", sep = "")), skip = 2)
  
  necessary_columns <- c(1, 8, 16:43, 57:73 )
  sub_readin <- readin[,necessary_columns]
  
  header <- read_csv(here::here("scripts/Header_Results.csv"))
  
  names(sub_readin) <- names(header)
  
  cleaned_file <- sub_readin %>% rowwise() %>%
    mutate(ClimateZone = toupper(unlist(strsplit(Directory, split = "/"))[2])) %>%
    mutate(Prototype = toupper(unlist(strsplit(Directory, split = "-"))[1])) %>%
    mutate(Measure = toupper(unlist(strsplit(unlist(strsplit(Directory, split = "-"))[2], split = "/"))[1]))
  
  annual_energy <- cleaned_file %>% select(Prototype, Measure, CFA, ClimateZone, `kWh TOTAL`, `Therms TOTAL`, `TDV TOTAL`) %>%
    mutate(`Electricity (kWh)` = `kWh TOTAL`/CFA,
           `Natural Gas (kBTU)` = 99976.1*`Therms TOTAL`/(CFA*(1000)),
           `TDV` = `TDV TOTAL`) %>%
    select(Prototype, Measure, CFA, ClimateZone, `Electricity (kWh)`, `Natural Gas (kBTU)`, `TDV`) %>%
    pivot_longer(cols = c("Electricity (kWh)", "Natural Gas (kBTU)", "TDV"), names_to = "AnnualUsage") %>%
    pivot_wider(names_from = ClimateZone, values_from = value) 
  
  
  end_use_kwh <- cleaned_file %>% select(Prototype, Measure, CFA, ClimateZone, contains("kWh") ) %>%
    pivot_longer(cols = contains("kWh"), names_to = "EndUse") %>%
    mutate(value = value/CFA) %>%
    pivot_wider(names_from = ClimateZone, values_from = value) %>%
    mutate(EndUse = gsub("kWh ", "", EndUse))
  
  end_use_therms <- cleaned_file %>% select(Prototype, Measure, CFA, ClimateZone, contains("Therms") ) %>%
    pivot_longer(cols = contains("Therms"), names_to = "EndUse") %>%
    mutate(value = 99976.1*value/(CFA*1000)) %>% #convert to kBTU
    pivot_wider(names_from = ClimateZone, values_from = value) %>%
    mutate(EndUse = gsub("Therms ", "", EndUse))
  
  end_use_tdv <- cleaned_file %>% select(Prototype, Measure, CFA, ClimateZone, contains("TDV") ) %>%
    pivot_longer(cols = contains("TDV"), names_to = "EndUse") %>%
    pivot_wider(names_from = ClimateZone, values_from = value) %>%
    mutate(EndUse = gsub("TDV ", "", EndUse))
  
  
  wb <- createWorkbook()
  addWorksheet(wb, "Results")
  s <- createStyle(numFmt = "0.0")
  addStyle(wb, "Results", style = s, cols = 6:22, rows = 6:61, gridExpand = TRUE)

  writeData(wb, "Results", "Annual Results per square foot", startRow = 4, startCol = 2)
  writeData(wb, "Results", annual_energy, startRow = 5, startCol = 2)
 
  
  writeData(wb, "Results", "Electricity (kWh) by End-Use per square foot", startRow = 11, startCol = 2)
  writeData(wb, "Results", end_use_kwh, startRow = 12, startCol = 2)
  
  writeData(wb, "Results", "Natural Gas (kBTU) by End-Use per square foot", startRow = 30, startCol = 2)
  writeData(wb, "Results", end_use_therms, startRow = 31, startCol = 2)
  
  writeData(wb, "Results", "kTDV by End-Use per square foot", startRow = 47, startCol = 2)
  writeData(wb, "Results", end_use_tdv, startRow = 48, startCol = 2)
  
  
  saveWorkbook(wb, paste(path, "/Results_Reformatted.xlsx", sep = ""), overwrite = TRUE)
}
