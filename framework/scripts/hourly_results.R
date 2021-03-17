library(here)
library(tidyverse)
library(openxlsx)
library(data.table)
library(readxl)

hourly_results_spreadsheet_com <- function(path, measures = NULL, cz = NULL, folder = NA, file = NA, remove_DHW = FALSE){
  ## For CBECC-Com
  
  ##path: String format, path to prototype results folder starting at framework ie. "analysis/hvac_autosizing"
  if(is.null(measures)){
    measures <- list.files(here::here(path, "runs"))
  }
  
  if(is.null(cz)){
    cz <- c("cz01", "cz02", "cz03", "cz04", "cz05", "cz06", "cz07",
            "cz08", "cz09", "cz10", "cz11", "cz12", "cz13", "cz14",
            "cz15", "cz16")
  }
  
  
  wb <- createWorkbook()
  
  for (measure in measures){
    
    
    
    cz_missing <- c()
    
    for(clim in cz){
      
      if(is.na(folder)){
        folder <- "instance - run"
        file <- "instance - ap - HourlyResults.csv"
      }
      
      if(!(paste(clim, folder, file, sep = "/") %in% list.files(here::here(path, "runs", measure), recursive = T))){
        cz_missing <- c(cz_missing, clim)
        next
      }
      
      hourly <- read_csv(here::here(path, "runs", measure, clim, folder, file), skip = 16)
      
      cfa_df <- read_csv(here::here(path, "runs", measure, clim, folder, file), skip = 10, col_names = FALSE)
      
      cfa <- as.numeric(cfa_df$X4[1])
      
      clim_num <- as.numeric(str_extract(clim, "\\d+"))
      
      hourly_totals_results <- hourly %>% select(Mo, Da, Hr, `(kWh)_5`, `(kWh)_14`, `(kBtu)_5`, `(kBtu)_12`, `(kWh)_13`, `(kBtu)_11`)
      
     
      
      
      
      names(hourly_totals_results) <- c("Month", "Day", "Hour", "DHW_kWh", "Elec_kWh", "DHW_kBtu", "NG_kBtu", "Elec_Comp_kWh", "NG_Comp_kBtu")
      
      if(remove_DHW){
        
        hourly_totals_results <- hourly_totals_results %>%
          mutate(Elec_kWh = Elec_kWh - DHW_kWh) %>%
          mutate(NG_kBtu = NG_kBtu - DHW_kBtu) %>%
          mutate(Elec_Comp_kWh = Elec_Comp_kWh - DHW_kWh) %>%
          mutate(NG_Comp_kBtu = NG_Comp_kBtu - DHW_kBtu) %>%
          select(-DHW_kWh, -DHW_kBtu)
        
      }
      
      
      hourly_results <- hourly_totals_results %>% rowwise() %>% 
        mutate(CZ = as.numeric(str_extract_all(clim, "\\d+"))) %>%
        select(Month, Day, Hour, CZ, Elec_kWh, NG_kBtu, Elec_Comp_kWh, NG_Comp_kBtu)  
      
      
      
      
      assign( clim, hourly_results, envir = .GlobalEnv)
      
    }
    
    cz_list <- cz[!(cz %in% cz_missing)]
    
    all_results <- data.table::rbindlist(lapply(cz_list, get)) %>% mutate(Measure = measure)
    
    
    
    assign(measure, all_results, envir = .GlobalEnv) 
    
    if(!(measure %in% names(wb))){
      
      addWorksheet(wb, measure)
      
      
    }
    
    writeData(wb, measure, all_results)
    
    
  }
  
  
  
  
  addWorksheet(wb, "Description")
  description_of_run <- paste( "DHW Removed: ", remove_DHW, "Date Produced:", Sys.Date(),  sep = " ")
  writeData(wb, "Description", description_of_run)
  
  saveWorkbook(wb, here::here(path, "HourlyResults.xlsx"), overwrite = TRUE)
  
}

tdv_2022_generate_com <- function(path, measures = NULL, cz = NULL, lifetime, folder = NA, file = NA, res_or_nr = "nr", remove_DHW = FALSE){
  ## For CBECC-Com
  
  ##path: String format, path to prototype results folder starting at framework ie. "analysis/hvac_autosizing"
  if(is.null(measures)){
    measures <- list.files(here::here(path, "runs"))
  }
  
  if(is.null(cz)){
    cz <- c("cz01", "cz02", "cz03", "cz04", "cz05", "cz06", "cz07",
            "cz08", "cz09", "cz10", "cz11", "cz12", "cz13", "cz14",
            "cz15", "cz16")
  }
  
  if (lifetime == 15){
    
    elec_sheet_name =  "Elec Non-Res (15 Year)"
    gas_sheet_name = "Gas Non-Res (15 Year)"
    
  }
  if (lifetime == 30){
    if(res_or_nr == "nr"){
      elec_sheet_name =  "Elec Non-Res (30 Year)"
      gas_sheet_name = "Gas Non-Res (30 Year)"
    }else if (res_or_nr == "res"){
      elec_sheet_name =  "Elec Res (30 Year)"
      gas_sheet_name = "Gas Res (30 Year)"
    }
    
  }
  
  
  
  tdv_2022_elec <- read_excel(here::here("scripts/2022_TDV_Multipliers.xlsx"), skip = 2, sheet = elec_sheet_name)
  tdv_2022_gas <- read_excel(here::here("scripts/2022_TDV_Multipliers.xlsx"), skip = 2, sheet = gas_sheet_name)
  
  source_elec <- read_excel(here::here("scripts/2022_Source_Energy.xlsx"), skip = 2, sheet = elec_sheet_name)
  source_gas <- read_excel(here::here("scripts/2022_Source_Energy.xlsx"), skip = 2, sheet = gas_sheet_name)
  
  co2_elec <- read_excel(here::here("scripts/2022_CO2_Multipliers.xlsx"), skip = 2, sheet = elec_sheet_name)
  co2_gas <- read_excel(here::here("scripts/2022_CO2_Multipliers.xlsx"), skip = 2, sheet = gas_sheet_name)
  
  wb <- createWorkbook()
  
  for (measure in measures){
    
    
    
    cz_missing <- c()
    
    for(clim in cz){
      
      if(is.na(folder)){
        folder <- "instance - run"
        file <- "instance - ap - HourlyResults.csv"
      }
      
      if(!(paste(clim, folder, file, sep = "/") %in% list.files(here::here(path, "runs", measure), recursive = T))){
        cz_missing <- c(cz_missing, clim)
        next
      }
      
      hourly <- read_csv(here::here(path, "runs", measure, clim, folder, file), skip = 16)
      
      cfa_df <- read_csv(here::here(path, "runs", measure, clim, folder, file), skip = 10, col_names = FALSE)
      
      cfa <- as.numeric(cfa_df$X4[1])
      
      clim_num <- as.numeric(str_extract(clim, "\\d+"))
      
      hourly_totals_results <- hourly %>% select(Mo, Da, Hr, `(kWh)_5`, `(kWh)_14`, `(kBtu)_5`, `(kBtu)_12`, `(kWh)_13`, `(kBtu)_11`, `(kTDV/kWh)`, `(kTDV/MBtu)`)
      
      hourly_totals <- cbind(hourly_totals_results, tdv_2022_elec[,clim_num +1], tdv_2022_gas[, clim_num + 1], source_elec[,clim_num +1], source_gas[, clim_num + 1], co2_elec[,clim_num +1], co2_gas[, clim_num + 1])
      
      
      
      names(hourly_totals) <- c("Month", "Day", "Hour", "DHW_kWh", "Elec_kWh", "DHW_kBtu", "NG_kBtu", "Elec_Comp_kWh", "NG_Comp_kBtu", "kTDV/kWh", "kTDV/MBtu","kTDV/kWh_2022", "kTDV/Therm_2022", "Source kBtu/kwh", "Source kBtu/Therm", "CO2 Ton/kwh", "CO2 Ton/Therm")
      
      if(remove_DHW){
        
        hourly_totals <- hourly_totals %>%
          mutate(Elec_kWh = Elec_kWh - DHW_kWh) %>%
          mutate(NG_kBtu = NG_kBtu - DHW_kBtu) %>%
          mutate(Elec_Comp_kWh = Elec_Comp_kWh - DHW_kWh) %>%
          mutate(NG_Comp_kBtu = NG_Comp_kBtu - DHW_kBtu) %>%
          select(-DHW_kWh, -DHW_kBtu)
        
      }
      
      
      hourly_totals_with_tdv <- hourly_totals %>% rowwise() %>% 
        mutate(CZ = as.numeric(str_extract_all(clim, "\\d+"))) %>%
        group_by(CZ) %>%
        summarise(kWh_Elec_Total = sum(Elec_kWh),
                  kBtu_NG_Total = sum(NG_kBtu),
                  kTDV_Total_Elec_2022 = sum(Elec_kWh*`kTDV/kWh_2022`)/cfa,
                  kTDV_Total_NG_2022 = sum(NG_kBtu*`kTDV/Therm_2022`/100)/cfa, # per therm
                  kWh_Elec_Comp = sum(Elec_Comp_kWh),
                  kBtu_NG_Comp = sum(NG_Comp_kBtu),
                  kTDV_Comp_Elec_2022 = sum(Elec_Comp_kWh*`kTDV/kWh_2022`)/cfa,
                  kTDV_Comp_NG_2022 = sum(NG_Comp_kBtu*`kTDV/Therm_2022`/100)/cfa,
                  Source_kBtu_Elec = sum(Elec_kWh*`Source kBtu/kwh`),
                  Source_kBtu_NG = sum(NG_kBtu*`Source kBtu/Therm`/100),
                  Source_kBtu_Total = Source_kBtu_Elec + Source_kBtu_NG,
                  CO2_ton_Elec = sum(Elec_kWh*`CO2 Ton/kWh`),
                  CO2_ton_NG = sum(NG_kBtu*`CO2 Ton/Therm`/100),
                  CO2_ton_Total = CO2_ton_Elec + CO2_ton_NG)  
      
      
      
      
      assign( clim, hourly_totals_with_tdv, envir = .GlobalEnv)
      
    }
    
    cz_list <- cz[!(cz %in% cz_missing)]
    
    all_results <- data.table::rbindlist(lapply(cz_list, get)) %>% mutate(Measure = measure)
    
    
    
    assign(measure, all_results, envir = .GlobalEnv)  
    
  }
  
  all_measures <- data.table::rbindlist(lapply(measures, get))
  
  addWorksheet(wb, "Results")
  writeData(wb, "Results", all_measures)
  
  
  addWorksheet(wb, "Description")
  description_of_run <- paste("LifeTime: ", lifetime, "TDVMultiplier: ", res_or_nr, "DHW Removed: ", remove_DHW, "Date Produced:", Sys.Date(),  sep = " ")
  writeData(wb, "Description", description_of_run)
  
  saveWorkbook(wb, here::here(path, "TDVAnnual.xlsx"), overwrite = TRUE)
  
}

hourly_results_spreadsheet_res <- function(path, measures = NULL, cz = NULL,  file = NA,  remove_DHW = FALSE, remove_PVB = FALSE){
  ## For CBECC-Res
  
  ##path: String format, path to prototype results folder starting at framework ie. "analysis/hvac_autosizing"
  if(is.null(measures)){
    measures <- list.files(here::here(path, "runs"))
  }
  
  if(is.null(cz)){
    cz <- c("cz01", "cz02", "cz03", "cz04", "cz05", "cz06", "cz07",
            "cz08", "cz09", "cz10", "cz11", "cz12", "cz13", "cz14",
            "cz15", "cz16")
  }
  
  
  
  wb <- createWorkbook()
  
  for (measure in measures){
    
    
    
    cz_missing <- c()
    
    for(clim in cz){
      
      if(is.na(file)){
        file <- "instance - Prop - HourlyResults.csv"
      }
      
      if(!(paste(clim, file, sep = "/") %in% list.files(here::here(path, "runs", measure), recursive = T))){
        cz_missing <- c(cz_missing, clim)
        next
      }
      
      hourly <- read_csv(here::here(path, "runs", measure, clim,  file), skip = 14)
      
      cfa_df <- read_csv(here::here(path, "runs", measure, clim,  file), skip = 7, col_names = FALSE)
      
      cfa <- as.numeric(cfa_df$X4[1])
      
      clim_num <- as.numeric(str_extract(clim, "\\d+"))
      
      hourly_totals <- hourly %>%
        select(Mo, Da, Hr, `(kWh)`,`(kWh)_1`,`(kWh)_2`,`(kWh)_3`,`(kWh)_4`,`(kWh)_5`,`(kWh)_10`,`(kWh)_11`, `(kWh)_12`, `(Therms)`,`(Therms)_1`,`(Therms)_2`,`(Therms)_3`,`(Therms)_4`,`(Therms)_5`, `(Therms)_10`, `(TDV/Btu)`, `(TDV/Btu)_1`) %>%
        rowwise() %>%
        mutate(Elec_kWh_Comp = sum(`(kWh)`,`(kWh)_1`,`(kWh)_2`,`(kWh)_3`,`(kWh)_4`,`(kWh)_5`)) %>%
        mutate(NG_Therm_Comp = sum(`(Therms)`,`(Therms)_1`,`(Therms)_2`,`(Therms)_3`,`(Therms)_4`,`(Therms)_5`)) %>%
        mutate(Elec_kWh_PVB = sum(`(kWh)_10`,`(kWh)_11`)) %>%
        select(Mo, Da, Hr,`(kWh)_4`, Elec_kWh_PVB, `(kWh)_12`, Elec_kWh_Comp, `(Therms)_4`, `(Therms)_10`,NG_Therm_Comp)
      
      
      
      names(hourly_totals) <- c("Month", "Day", "Hour", "DHW_kWh", "Elec_kWh_PVB", "Elec_kWh", "Elec_kWh_Comp", "DHW_Therm", "NG_Therm", "NG_Therm_Comp")
      
      if(remove_DHW){
        
        hourly_totals <- hourly_totals %>%
          mutate(Elec_kWh = Elec_kWh - DHW_kWh) %>%
          mutate(NG_Therm = NG_Therm - DHW_Therm) %>%
          mutate(Elec_kWh_Comp = Elec_kWh_Comp - DHW_kWh) %>%
          mutate(NG_Therm_Comp = NG_Therm_Comp - DHW_Therm) %>%
          select(-DHW_kWh, -DHW_Therm)
        
      }
      
      if(remove_PVB){
        
        hourly_totals <- hourly_totals %>%
          mutate(Elec_kWh = Elec_kWh - Elec_kWh_PVB) %>%
          select(-Elec_kWh_PVB)
        
        
      }
      
      
      hourly_totals_with_tdv <- hourly_totals %>% rowwise() %>% 
        mutate(CZ = as.numeric(str_extract_all(clim, "\\d+"))) %>%
        select(Month, Day, Hour, CZ, Elec_kWh, NG_Therm, Elec_kWh_Comp, NG_Therm_Comp)
      
      
      
      assign( clim, hourly_totals_with_tdv, envir = .GlobalEnv)
      
    }
    
    cz_list <- cz[!(cz %in% cz_missing)]
    
    all_results <- data.table::rbindlist(lapply(cz_list, get)) %>% mutate(Measure = measure)
    
    
    
    assign(measure, all_results, envir = .GlobalEnv) 
    
    if(!(measure %in% names(wb))){
      
      addWorksheet(wb, measure)
      
      
    }
    
    writeData(wb, measure, all_results) 
    
  }
  
  
  
  addWorksheet(wb, "Description")
  description_of_run <- paste("DHW Removed: ", remove_DHW, "; PVB Removed: ", remove_PVB, "; Date Produced: ", Sys.Date(), sep = " ")
  writeData(wb, "Description", description_of_run)
  
  saveWorkbook(wb, here::here(path, "HourlyResults.xlsx"), overwrite = TRUE)
  
}


tdv_2022_generate_res <- function(path, measures = NULL, cz = NULL, lifetime,  file = NA, res_or_nr = "nr", remove_DHW = FALSE, remove_PVB = FALSE){
  ## For CBECC-Res
  
  ##path: String format, path to prototype results folder starting at framework ie. "analysis/hvac_autosizing"
  if(is.null(measures)){
    measures <- list.files(here::here(path, "runs"))
  }
  
  if(is.null(cz)){
    cz <- c("cz01", "cz02", "cz03", "cz04", "cz05", "cz06", "cz07",
            "cz08", "cz09", "cz10", "cz11", "cz12", "cz13", "cz14",
            "cz15", "cz16")
  }
  
  if (lifetime == 15){
    
    elec_sheet_name =  "Elec Non-Res (15 Year)"
    gas_sheet_name = "Gas Non-Res (15 Year)"
    
  }
  if (lifetime == 30){
    if(res_or_nr == "nr"){
      elec_sheet_name =  "Elec Non-Res (30 Year)"
      gas_sheet_name = "Gas Non-Res (30 Year)"
    }else if (res_or_nr == "res"){
      elec_sheet_name =  "Elec Res (30 Year)"
      gas_sheet_name = "Gas Res (30 Year)"
    }
    
  }
  
  tdv_2022_elec <- read_excel(here::here("scripts/2022_TDV_Multipliers.xlsx"), skip = 2, sheet = elec_sheet_name)
  tdv_2022_gas <- read_excel(here::here("scripts/2022_TDV_Multipliers.xlsx"), skip = 2, sheet = gas_sheet_name)
  
  source_elec <- read_excel(here::here("scripts/2022_Source_Energy.xlsx"), skip = 2, sheet = elec_sheet_name)
  source_gas <- read_excel(here::here("scripts/2022_Source_Energy.xlsx"), skip = 2, sheet = gas_sheet_name)
  
  co2_elec <- read_excel(here::here("scripts/2022_CO2_Multipliers.xlsx"), skip = 2, sheet = elec_sheet_name)
  co2_gas <- read_excel(here::here("scripts/2022_CO2_Multipliers.xlsx"), skip = 2, sheet = gas_sheet_name)
  
  wb <- createWorkbook()
  
  for (measure in measures){
    
    
    
    cz_missing <- c()
    
    for(clim in cz){
      
      if(is.na(file)){
        file <- "instance - Prop - HourlyResults.csv"
      }
      
      if(!(paste(clim, file, sep = "/") %in% list.files(here::here(path, "runs", measure), recursive = T))){
        cz_missing <- c(cz_missing, clim)
        next
      }
      
      hourly <- read_csv(here::here(path, "runs", measure, clim,  file), skip = 14)
      
      cfa_df <- read_csv(here::here(path, "runs", measure, clim,  file), skip = 7, col_names = FALSE)
      
      cfa <- as.numeric(cfa_df$X4[1])
      
      clim_num <- as.numeric(str_extract(clim, "\\d+"))
      
      hourly_totals_results <- hourly %>%
        select(Mo, Da, Hr, `(kWh)`,`(kWh)_1`,`(kWh)_2`,`(kWh)_3`,`(kWh)_4`,`(kWh)_5`,`(kWh)_10`,`(kWh)_11`, `(kWh)_12`, `(Therms)`,`(Therms)_1`,`(Therms)_2`,`(Therms)_3`,`(Therms)_4`,`(Therms)_5`, `(Therms)_10`, `(TDV/Btu)`, `(TDV/Btu)_1`) %>%
        rowwise() %>%
        mutate(Elec_kWh_Comp = sum(`(kWh)`,`(kWh)_1`,`(kWh)_2`,`(kWh)_3`,`(kWh)_4`,`(kWh)_5`)) %>%
        mutate(NG_Therm_Comp = sum(`(Therms)`,`(Therms)_1`,`(Therms)_2`,`(Therms)_3`,`(Therms)_4`,`(Therms)_5`)) %>%
        mutate(Elec_kWh_PVB = sum(`(kWh)_10`,`(kWh)_11`)) %>%
        select(Mo, Da, Hr,`(kWh)_4`, Elec_kWh_PVB, `(kWh)_12`, Elec_kWh_Comp, `(Therms)_4`, `(Therms)_10`,NG_Therm_Comp, `(TDV/Btu)`, `(TDV/Btu)_1` )
      
      
      hourly_totals <- cbind(hourly_totals_results, tdv_2022_elec[,clim_num +1], tdv_2022_gas[, clim_num + 1], source_elec[,clim_num + 1], source_gas[, clim_num + 1], co2_elec[,clim_num + 1], co2_gas[, clim_num + 1])
      
      
      
      names(hourly_totals) <- c("Month", "Day", "Hour", "DHW_kWh", "Elec_kWh_PVB", "Elec_kWh", "Elec_kWh_Comp", "DHW_Therm", "NG_Therm", "NG_Therm_Comp","TDV/Btu_elec", "TDV/Btu_gas","kTDV/kWh_2022", "kTDV/Therm_2022", "Source kBtu/kwh", "Source kBtu/Therm", "CO2 Ton/kwh", "CO2 Ton/Therm")
      
      if(remove_DHW){
        
        hourly_totals <- hourly_totals %>%
          mutate(Elec_kWh = Elec_kWh - DHW_kWh) %>%
          mutate(NG_Therm = NG_Therm - DHW_Therm) %>%
          mutate(Elec_kWh_Comp = Elec_kWh_Comp - DHW_kWh) %>%
          mutate(NG_Therm_Comp = NG_Therm_Comp - DHW_Therm) %>%
          select(-DHW_kWh, -DHW_Therm)
        
      }
      
      if(remove_PVB){
        
        hourly_totals <- hourly_totals %>%
          mutate(Elec_kWh = Elec_kWh - Elec_kWh_PVB) %>%
          select(-Elec_kWh_PVB)
        
        
      }
      
      
      hourly_totals_with_tdv <- hourly_totals %>% rowwise() %>% 
        mutate(CZ = as.numeric(str_extract_all(clim, "\\d+"))) %>%
        group_by(CZ) %>%
        summarise(kWh_Elec_Total = sum(Elec_kWh),
                  Therm_NG_Total = sum(NG_Therm),
                  kTDV_Total_Elec_2022 = sum(Elec_kWh*`kTDV/kWh_2022`)/cfa,
                  kTDV_Total_NG_2022 = sum(NG_Therm*`kTDV/Therm_2022`)/cfa, 
                  kWh_Elec_Comp = sum(Elec_kWh_Comp),
                  Therm_NG_Comp = sum(NG_Therm_Comp),
                  kTDV_Comp_Elec_2022 = sum(Elec_kWh_Comp*`kTDV/kWh_2022`)/cfa,
                  kTDV_Comp_NG_2022 = sum(NG_Therm_Comp*`kTDV/Therm_2022`)/cfa, # per therm
                  Source_kBtu_Elec = sum(Elec_kWh*`Source kBtu/kwh`),
                  Source_kBtu_NG = sum(NG_Therm*`Source kBtu/Therm`),
                  Source_kBtu_Total = sum(Source_kBtu_Elec, Source_kBtu_NG),
                  CO2_ton_Elec = sum(Elec_kWh*`CO2 Ton/kwh`),
                  CO2_ton_NG = sum(NG_Therm*`CO2 Ton/Therm`),
                  CO2_ton_Total = sum(CO2_ton_Elec, CO2_ton_NG))  
      
      
      
      assign( clim, hourly_totals_with_tdv, envir = .GlobalEnv)
      
    }
    
    cz_list <- cz[!(cz %in% cz_missing)]
    
    all_results <- data.table::rbindlist(lapply(cz_list, get)) %>% mutate(Measure = measure)
    
    
    
    assign(measure, all_results, envir = .GlobalEnv)  
    
  }
  
  all_measures <- data.table::rbindlist(lapply(measures, get))
  
  addWorksheet(wb, "Results")
  writeData(wb, "Results", all_measures)
  
  
  addWorksheet(wb, "Description")
  description_of_run <- paste("LifeTime: ", lifetime, "TDVMultiplier: ", res_or_nr, "DHW Removed: ", remove_DHW, "PVB Removed: ", remove_PVB, "Date Produced: ", Sys.Date(), sep = " ")
  writeData(wb, "Description", description_of_run)
  
  saveWorkbook(wb, here::here(path, "TDVAnnual.xlsx"), overwrite = TRUE)
  
}


