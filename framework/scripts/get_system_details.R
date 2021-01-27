library(tidyverse)
library(here)


get_system_details <- function(path){
  ##path: String format, path to results spreadsheet starting at framework ie. "analysis/hvac_autosizing"
  
  #get list of case files
  cases <- list.files(here::here(path, "runs"))
  climate_zones <- c("cz01", "cz02", "cz03", "cz04", "cz05", "cz06", "cz07", "cz08", "cz09",
                     "cz10", "cz11", "cz12", "cz13", "cz14", "cz15", "cz16")
  
  #test cz01 of first case to get parameters 
  
  first_files <- list.files(here::here(path, "runs", cases[1], "cz01"))
  first_t_files <- grep(".txt", first_files, value = T)
  
  #initialize arrays for each of the .txt files
  case_list <- c()
  climate_list <- c()
  col_names <- gsub(".txt", "", first_t_files)
  
  for(name in col_names){
    
    assign(name, c())
    
  }
  
  for (case in cases){
    
    for (cz in climate_zones){
      
      all_files <- list.files(here::here(path, "runs", case, cz))
      
      text_files <- grep(".txt", all_files, value = T)
      
      case_list <- c(case_list, case)
      climate_list <- c(climate_list, cz)
      
      for(tfile in text_files){
        
        val <- read_file(here::here(path, "runs", case, cz, tfile))
        name <- gsub(".txt", "", tfile)
        assign(name, c(get(name), val) )
        
        
      }
      
    }
    
  }
  
  df <- data.frame(case_list, climate_list)
  names(df) <- c("case", "climate_zone")
  
  parameters <- data.frame(do.call(cbind, lapply( col_names, get) ))
  names(parameters) <- col_names
  
  final_df <- cbind(df, parameters)
  
  write_csv(final_df, here::here(path, "system_details.csv"))
  
  
}