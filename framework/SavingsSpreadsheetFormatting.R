library(here)
library(tidyverse)
library(openxlsx)

##Note: Update to include other prototypes
get_prototype <- function(runtitle){
  
  if(grepl("Mid-Rise", runtitle)){
    return("MidRiseMixedUse")
  }
  
}


write_results_savings_spreadsheet <- function(run_name){
  ##run_name: String format, name of the measure. Ie. "hvac" or "hvac_autosizing" 
  
  readin <- read_csv(here::here(paste("Analysis/", run_name, "/results.csv", sep = "")), skip = 2)
  
  necessary_columns <- c(1, 4, 97, 29, 139, 71, 110, 42, 140, 72, 177, 162 )
  sub_readin <- readin[,necessary_columns]
  names(sub_readin) <- c("Directory", "RunTitle", "Std_kWh", "Prop_kWh", "Std_TDV_kWh", "Prop_TDV_kWh", 
                         "Std_Therms", "Prop_Therms", "Std_TDV_Therms", "Prop_TDV_Therms", 
                         "Std_Demand", "Prop_Demand")
  
  
  cleaned_file <- sub_readin %>% rowwise() %>%
    mutate(ClimateZone = toupper(unlist(strsplit(Directory, split = "/"))[2])) %>%
    mutate(Prototype = get_prototype(RunTitle))
  
  wb <- createWorkbook()
  addWorksheet(wb, "Results")
  
  
  writeData(wb, "Results", "Select all data, and Paste Special into Savings Spreadsheet. Check `Skip blanks` and `Values`", startRow = 1)
  
  writeData(wb, "Results", "Climate Zone", startRow = 3, startCol = 1)
  writeData(wb, "Results", cleaned_file$ClimateZone, startRow = 4, startCol = 1)
  
  writeData(wb, "Results", "Prototype", startRow = 3, startCol = 2)
  writeData(wb, "Results", cleaned_file$Prototype, startRow = 4, startCol = 2)
  
  writeData(wb, "Results", "Standard Design Electricity Use", startRow = 3, startCol = 4)
  writeData(wb, "Results", cleaned_file$Std_kWh, startRow = 4, startCol = 4 )
  
  writeData(wb, "Results", "Proposed Design Electricity Use", startRow = 3, startCol = 5)
  writeData(wb, "Results", cleaned_file$Prop_kWh, startRow = 4, startCol = 5)
  
  writeData(wb, "Results", "Standard Design Electricity TDV", startRow = 3, startCol = 7)
  writeData(wb, "Results", cleaned_file$Std_TDV_kWh, startRow = 4, startCol = 7)
  
  writeData(wb, "Results", "Proposed Design Electricity TDV", startRow = 3, startCol = 8)
  writeData(wb, "Results", cleaned_file$Prop_TDV_kWh, startRow = 4, startCol = 8)
  
  
  writeData(wb, "Results", "Standard Design Natural Gas Use", startRow = 3, startCol = 10)
  writeData(wb, "Results", cleaned_file$Std_Therms, startRow = 4, startCol =10)
  
  writeData(wb, "Results", "Proposed Design Natural Gas Use", startRow = 3, startCol = 11)
  writeData(wb, "Results", cleaned_file$Prop_Therms, startRow = 4, startCol = 11)
  
  
  writeData(wb, "Results", "Standard Design Natural Gas TDV", startRow = 3, startCol = 13)
  writeData(wb, "Results", cleaned_file$Std_TDV_Therms, startRow = 4, startCol = 13)
  
  writeData(wb, "Results", "Proposed Design Natural Gas TDV", startRow = 3, startCol = 14)
  writeData(wb, "Results", cleaned_file$Prop_TDV_Therms, startRow = 4, startCol = 14)
  
  
  writeData(wb, "Results", "Standard Design Peak Demand", startRow = 3, startCol = 16)
  writeData(wb, "Results", cleaned_file$Std_Demand, startRow = 4, startCol = 16)
  
  writeData(wb, "Results", "Proposed Design Peak Demand", startRow = 3, startCol = 17)
  writeData(wb, "Results", cleaned_file$Prop_Demand, startRow = 4, startCol = 17)
  
  
  
  
  saveWorkbook(wb, paste("Analysis/", run_name, "/Results_Savings_Spreadsheet_Format.xlsx", sep = ""), overwrite = TRUE)
}
