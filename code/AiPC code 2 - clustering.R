#####    #####     #####    #####     #####    #####     #####    #####     #####    #####     #####
# Code to Create the Aged in Place Classification
# 2. Clustering - preprocessed data to cluster results
# Author: Yuanxuan Yang | GitHub: yyuanxuan | twitter@yyuanxuan
#####    #####     #####    #####     #####    #####     #####    #####     #####    #####     #####

rm(list = ls()) 
gc()

# load packages
library(tidyverse)
library(readxl)
library(sf)
library(caret)


# import/read data inputs
input_data <- read.csv("data/input/input-data.csv")
input_data_boxcox_scale<-read.csv("data/input/input-data-boxcox-scale.csv")

# set the number of clusters (num_k)
# the number of clusters is determined majorly with clustergram (see ancillary 1 - clustergram.ipynb)
num_k = 5
set.seed(123)

# get clustering results with kmeans
# first tier - supergroups
cluster_results = kmeans(x = input_data_boxcox_scale %>% dplyr::select(-geography_code),
                         centers = num_k ,
                         iter.max = 100000,
                         nstart=10000
                         
)

cluster_result_df = data.frame(geography_code=input_data_boxcox_scale$geography_code,
                               supergroup_code = as.character(cluster_results$cluster)) %>%
  mutate(supergroup_code = paste0("sgroup_",supergroup_code))

cluster_result_df %>%
  dplyr::group_by(supergroup_code) %>%
  dplyr::summarise(count = n())


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

# derive and output the subset of each supergroup
# each subset will be examined with clustergram (see ancillary 1 - clustergram.ipynb) and other interpretation (e.g. number of members, mean and median z-score of each variable)
# to determin the number of sub-clusters (groups) in the second tier classification
for (i in c(1:num_k)) {
  df_sub_cluster = cluster_result_df %>% left_join(input_data,by = c("geography_code"="geography_code")) %>% 
    filter(supergroup_code == paste0("sgroup_",i)) %>%
    dplyr::select(-supergroup_code) %>% get_trans() %>%
    write.csv(file =  'data/input/input_data_trans_sgroup_' %>% paste0(i) %>% paste0('.csv'),row.names = FALSE)
}

# function for obtaining second-tier classification
fun_get_sub_cluster <- function(supergroups_df,supergroup_no_i,k,seed_i) {
  cluster_results_sub_c = supergroups_df %>% left_join(input_data,by = c("geography_code"="geography_code")) %>% 
    filter(supergroup_code == paste0("sgroup_",supergroup_no_i)) %>%
    dplyr::select(-supergroup_code) %>% get_trans()  %>%  select_if(~sum(!is.na(.)) > 0) %>%
    dplyr::select(-geography_code) %>% 
    kmeans(centers = k,iter.max = 100000,nstart=10000)
  cluster_results_sub_c <- data.frame(geography_code = supergroups_df %>% filter(supergroup_code == paste0("sgroup_",supergroup_no_i)) %>%
                                        dplyr::select(geography_code) %>% unlist() %>% as.vector()
                                      , group_code= "group_" %>% 
                                        paste0(supergroup_no_i) %>% 
                                        paste0(".") %>% 
                                        paste0(cluster_results_sub_c$cluster))
  
  return(cluster_results_sub_c)
}

# get the second-tier classification 
# the number of sub-clusters (groups) in the second tier
# are determined by checking clustergram (see ancillary 1 - clustergram.ipynb) and 
# other characteristics (e.g. number of members, mean and median z-score of each variable) of possible grouping solutions
sg1_groups <- fun_get_sub_cluster(cluster_result_df,supergroup_no_i=1,k=3,seed_i = 123)
sg2_groups <- fun_get_sub_cluster(cluster_result_df,supergroup_no_i=2,k=2,seed_i = 123)
sg3_groups <- fun_get_sub_cluster(cluster_result_df,supergroup_no_i=3,k=2,seed_i = 123)
sg4_groups <- fun_get_sub_cluster(cluster_result_df,supergroup_no_i=4,k=3,seed_i = 123)
sg5_groups <- fun_get_sub_cluster(cluster_result_df,supergroup_no_i=5,k=3,seed_i = 123)


# combine all results and gather tier 1 (supergroups) and tier 2 (groups) results
# Please note that the genereated supergroup and group code are tentative, and new order(code) and names will be assigned.
aipc_df<- sg1_groups %>% left_join(cluster_result_df) %>%
  rbind(sg2_groups %>% left_join(cluster_result_df)) %>%
  rbind(sg3_groups %>% left_join(cluster_result_df)) %>%
  rbind(sg4_groups %>% left_join(cluster_result_df)) %>%
  rbind(sg5_groups %>% left_join(cluster_result_df)) %>%
  dplyr::select(geography_code, supergroup_code, group_code)
  

# assign names and new code (orders) for the clusters (supergroups and groups)
# read name files
supergroup_names <- read.csv("data/input/supergroup_names_lookup.csv")
group_names <- read.csv("data/input/group_names_lookup.csv")

# creat lookup table for matching new code and names (supergroups)
supergroup_number_lookup<-aipc_df %>% 
  group_by(supergroup_code) %>%
  summarise(count=n()) %>%
  left_join(supergroup_names, by = c("count"="count"))

# creat lookup table for matching new code and names (groups)
group_number_lookup<-aipc_df %>% 
  group_by(group_code) %>%
  summarise(count=n()) %>%
  left_join(group_names, by = c("count"="count"))

# add names and modify the order (code) for AiPC supergroups and groups
aipc_df <- aipc_df %>%
  left_join(supergroup_number_lookup %>% dplyr::select(supergroup_code,supergroup_name),
            by = c("supergroup_code" = "supergroup_code")) %>%
  left_join(group_number_lookup %>% dplyr::select(group_code,group_name),
            by = c("group_code" = "group_code")) %>%
  mutate(supergroup_code = str_sub(supergroup_name,start = 1, end =2)) %>%
  mutate(group_code = str_sub(group_name, start = 1, end = 3))


head(aipc_df)

# save AiPC as .csv file
write.csv(aipc_df,file = "data/output/AiPC.csv",row.names = FALSE)
