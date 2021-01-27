library(tidyverse)
library(here)


path <- "baselines/QSRes/t24-2019.csv"
file <- read_csv(here::here(path))
  
head(file)

## Metal wall
metal_wall <- file$`:metal_frame_wall`
materials <- c()
for(cz in metal_wall){
  
  materials <- c(materials, unlist(str_split(cz, pattern=";")))
  
}

unique_materials <- unique(materials)

cz12_materials <- unlist(str_split(metal_wall[12], pattern = ";"))

add_materials <- unique_materials[!(unique_materials %in% cz12_materials)]


## Roof

roof <- file$`:wood_roof`
materials <- c()
for(cz in roof){
  
  materials <- c(materials, unlist(str_split(cz, pattern=";")))
  
}

unique_materials <- unique(materials)

cz12_materials <- unlist(str_split(roof[12], pattern = ";"))

add_materials <- unique_materials[!(unique_materials %in% cz12_materials)]
