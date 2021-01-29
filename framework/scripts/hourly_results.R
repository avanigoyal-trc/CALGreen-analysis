library(here)
library(tidyverse)
library(openxlsx)
library(data.table)
library(readxl)

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
  
  wb <- createWorkbook()
  
  for (measure in measures){
    
    addWorksheet(wb, measure)
    
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
      
      hourly_totals <- cbind(hourly_totals_results, tdv_2022_elec[,clim_num +1], tdv_2022_gas[, clim_num + 1])
      
      
      
      names(hourly_totals) <- c("Month", "Day", "Hour", "DHW_kWh", "Elec_kWh", "DHW_kBtu", "NG_kBtu", "Elec_Comp_kWh", "NG_Comp_kBtu", "kTDV/kWh", "kTDV/MBtu","kTDV/kWh_2022", "kTDV/Therm_2022")
      
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
                   kTDV_Total_NG_2022 = sum(NG_kBtu*`kTDV/Therm_2022`/100)/cfa)  # per therm
      
      
      
      assign( clim, hourly_totals_with_tdv, envir = .GlobalEnv)
      
    }
    
    cz_list <- cz[!(cz %in% cz_missing)]
    
    all_results <- data.table::rbindlist(lapply(cz_list, get))
    
    
    
    writeData(wb, measure, all_results)  
    
  }
  
  addWorksheet(wb, "Description")
  description_of_run <- paste("LifeTime: ", lifetime, "TDVMultiplier: ", res_or_nr, "DHW Removed: ", remove_DHW, sep = " ")
  writeData(wb, "Description", description_of_run)
  
  saveWorkbook(wb, here::here(path, "TDVAnnual.xlsx"), overwrite = TRUE)
  
}

tdv_2022_generate_res <- function(path, measures = NULL, cz = NULL, lifetime,  file = NA, res_or_nr = "nr", remove_DHW = FALSE){
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
  
  wb <- createWorkbook()
  
  for (measure in measures){
    
    addWorksheet(wb, measure)
    
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
      
      hourly_totals_results <- hourly %>% select(Mo, Da, Hr, `(kWh)_4`, `(kWh)_12`, `(Therms)_4`, `(Therms)_10`, `(TDV/Btu)`, `(TDV/Btu)_1`)
      
      hourly_totals <- cbind(hourly_totals_results, tdv_2022_elec[,clim_num +1], tdv_2022_gas[, clim_num + 1])
      
      
      
      names(hourly_totals) <- c("Month", "Day", "Hour", "DHW_kWh", "Elec_kWh", "DHW_Therm", "NG_Therm", "TDV/Btu_elec", "TDV/Btu_gas","kTDV/kWh_2022", "kTDV/Therm_2022")
      
      if(remove_DHW){
        
        hourly_totals <- hourly_totals %>%
          mutate(Elec_kWh = Elec_kWh - DHW_kWh) %>%
          mutate(NG_Therm = NG_Therm - DHW_Therm) %>%
          select(-DHW_kWh, -DHW_Therm)
        
      }
      
      
      hourly_totals_with_tdv <- hourly_totals %>% rowwise() %>% 
        mutate(CZ = as.numeric(str_extract_all(clim, "\\d+"))) %>%
        group_by(CZ) %>%
        summarise(kWh_Elec_Total = sum(Elec_kWh),
                  Therm_NG_Total = sum(NG_Therm),
                  kTDV_Total_Elec_2022 = sum(Elec_kWh*`kTDV/kWh_2022`)/cfa,
                  kTDV_Total_NG_2022 = sum(NG_Therm*`kTDV/Therm_2022`)/cfa)  # per therm
      
      
      
      assign( clim, hourly_totals_with_tdv, envir = .GlobalEnv)
      
    }
    
    cz_list <- cz[!(cz %in% cz_missing)]
    
    all_results <- data.table::rbindlist(lapply(cz_list, get)) %>% mutate(Measure = measure)
    
    
    
    assign(measure, all_results)  
    
  }
  addWorksheet(wb, "Description")
  description_of_run <- paste("LifeTime: ", lifetime, "TDVMultiplier: ", res_or_nr, "DHW Removed: ", remove_DHW, sep = ",")
  writeData(wb, "Description", description_of_run)
  
  saveWorkbook(wb, here::here(path, "TDVAnnual.xlsx"), overwrite = TRUE)
  
}

