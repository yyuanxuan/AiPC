####################################################################################################
# Code to Create the Aged in Place Classification
# 1. Pre-clustering - Raw inputs to normalised and standardised inputs
# Author: Yuanxuan Yang | GitHub: yyuanxuan | twitter@yyuanxuan
####################################################################################################

rm(list = ls()) 
gc()

# Library packages required
library(tidyverse)
library(readxl)
library(sf)
library(caret)


# Data inputs

#AiPC_Lookup <- read.csv()
input_data<-read.csv("data/input/input-data.csv")

# normalisation and standardisation functions
# using boxcox transformation and range scale [0,1]

range01 <- function(x){(x-min(x))/(max(x)-min(x))}

get_trans<-function(df){
  input_data_boxcox_scale=df
  
  # crime index is derived from imd, and it is a z-score variable which contains negative values
  # BoxCox Transformation requires input values to be positive
  # add an constant (absolute value of the min value) to make the crime index all positive values
  input_data_boxcox_scale$osle_crime_index=(input_data_boxcox_scale$osle_crime_index+
                                              abs(min(input_data_boxcox_scale$osle_crime_index)))
  
  input_data_boxcox_scale[2:ncol(input_data_boxcox_scale)] <-input_data_boxcox_scale %>%
    dplyr::select(-geography_code) %>%
    mutate_all(function(x) x+0.0000001) %>%
    mutate_all(funs( BoxCoxTrans(.) %>% predict(.))) %>% # boxcox transformation
    mutate_all(funs(range01(.))) # range scale
  return(input_data_boxcox_scale)
}

# get preprocessed data: boxcox transformation and range scale
input_data_boxcox_scale<-get_trans(input_data)

summary(input_data_boxcox_scale)

corr = cor(input_data_boxcox_scale %>% dplyr::select(-geography_code))

# save/output preprocessed data for clustering and clustergram analysis
write.csv(input_data_boxcox_scale,"data/input/input-data-boxcox-scale.csv",row.names = F)