#####    #####     #####    #####     #####    #####     #####    #####     #####    #####     #####
# Code to Create the Aged in Place Classification
# 3. Create cluster profiles (e.g. radar plots) for supergroups and groups
# Author: Yuanxuan Yang | GitHub: yyuanxuan | twitter@yyuanxuan
#####    #####     #####    #####     #####    #####     #####    #####     #####    #####     #####

rm(list = ls()) 
gc()


# load packages
library(tidyverse)
library(fmsb) # for creating radar plot
library(ggradar)
library(sf)
library(caret)
library(reshape2)
library(RColorBrewer)


# Import data: aipc results and variables of each LSOA in England
aipc_df <- read.csv('data/output/AiPC.csv')
input_data_boxcox_scale <- read.csv('data/input/input-data-boxcox-scale.csv')

# rename the variables
input_data_boxcox_scale <- input_data_boxcox_scale %>%
  rename(
    #People domain
    `Single person hhold`	=people_single_person_household,
    `Female` 	=people_female,
    `White British`	=people_white_british,
    `Asian`	= people_asian,
    `Black, Mix and others` = people_black_mix_others,
    `85+`	=people_age_85_and_over,
    `Religion`	=people_religion,
    `75-84`	=people_age_75_84,
    `Living w/non-dep children`	=people_living_with_non_dependent_children,
    `Good ELP`	=people_good_english_proficiency,
    `Hhold residents`	=people_household_residents,
    `50-64`	=people_age_50_64,
    `65-74`	=people_age_65_74,
    `Older Person Ratio`	=people_older_person_ratio,
    `Living w/dep children`	=people_living_with_dependent_children,
    `Born overseas`	=people_born_overseas,
    `Median age`	=people_median_age,
    `Coupled hhold`	=people_coupled_household,
    `Married`	=people_marital_status,
    
    # Housing domain
    `Socially rented`	=housing_socially_rented,
    `Terraced`	=housing_terraced_housing,
    `Crowded`	=housing_crowded,
    `No Central Heating`	=housing_no_central_heating,
    `Flats`	=housing_flats,
    `Privately rented`	=housing_privately_rented,
    `Poor quality housing`	=housing_poor_quality_housing,
    `Mortgaged`	=housing_mortgage_shared_ownership,
    `House`	=housing_detached_semidetached_bungalow_housing,
    `Spare rooms`	=housing_spare_rooms,
    `Owned outright`	=housing_owned_outright,
    `Median house price`	=housing_median_house_price,
    
    # Work and education domain
    `Qual: high`	=work_edu_education_high,
    `Self-\nemp`	=work_edu_self_employed,
    `0-19hrs unpaid care`	=work_edu_care_0_19h,
    `Distance to work: 10km+`	=work_edu_t2work_10_above_km,
    `Qual: med`	=work_edu_education_medium,
    `PT \nemp`	=work_edu_pt_employed,
    `FT \nemp`	=work_edu_ft_employed,
    `Retired`	=work_edu_retired,
    `No unpaid care`	=work_edu_care_0h,
    `Unemp`=work_edu_unemployed,
    `20+hrs unpaid care`	=work_edu_care_20_aboveh,
    `Qual: low`=work_edu_education_low,
    
    # Mobility domain
    `Residential churn`	=mobility_mobility,
    `Vehicle access`	=mobility_car_access,
    
    # Health domain
    `LLTI: limited a lot`	=health_llti_lot,
    `General health: bad`	=health_genhealth_bad,
    `General health: fair`	=health_genhealth_fair,
    `LLTI: limited a little`	=health_llti_little,
    `Dementia prescribing: m`	=health_dementia_treatment_m,
    `Dementia prescribing: a`	=health_dementia_treatment_a,
    `Hospital access`	=health_hospital_access,
    `GP access`	=health_gp_access,
    `Pharmacy access`	=health_pharmacy_access,
    
    `Broadband access`	=digital_broadband_access,
    `ICT: information`	=digital_ict_use_information,
    `ICT: services`	=digital_ict_use_online_shopping_banking,
    `ICT: social`	=digital_ict_use_social,
    `Broadband speed`	=digital_broadband_speed,
    
    `Income deprivation`	=financial_security_income_deprivation,
    `Fuel poverty`	=financial_security_fuel_poverty,
    
    `Distance to: grocery`	=osle_grocery,
    `Distance to: town centre`	=osle_town_centre,
    `Distance to: leisure centre`	=osle_leisure_centre,
    `Distance to: active green space`	=osle_green_space_active,
    `Distance to: passive green space`	=osle_green_space_passive,
    `NO2`	=osle_air_quality_no2,
    `PM10`	=osle_air_quality_pm10,
    `SO2`	=osle_air_quality_so2,
    `Crime \nIndex`	=osle_crime_index,
    
    `Civic \nCapacity\n\n\n`	=civic_capacity_civic_participation) 


glimpse(input_data_boxcox_scale)

# get z-score of variables, the radar plot and bar plot will be created based on each supergroup/group's mean z-score 
z_scoremodel<-preProcess(input_data_boxcox_scale %>% dplyr::select(- geography_code) %>% as.data.frame(),method = c("center", "scale"))
result_z_score = input_data_boxcox_scale
result_z_score[,2:ncol(input_data_boxcox_scale)]<-predict(z_scoremodel,input_data_boxcox_scale %>% dplyr::select(- geography_code) %>% as.data.frame())

# create the radar plot for all supergroups
aipc_df %>%
  dplyr::select(geography_code, supergroup_name) %>% 
  left_join(result_z_score, by = c("geography_code"="geography_code")) %>%
  dplyr::select(-geography_code) %>%
  group_by(supergroup_name) %>%
  summarise_all(.funs=mean) %>%
  rename(group = supergroup_name) %>%
  mutate(group = str_wrap(group,width=26)) %>%
  ggradar(values.radar = c("-2.5" ,"0", "2"),
          grid.mid = 0, grid.max = 2, grid.min = -2.5,
          group.line.width = 0.5, 
          group.point.size = 2,
          group.colours = c("#ea7070", "#F9CE00", "#9dd3a8","#1F6ED4","#8134af"),
          axis.label.offset = 1.1,
          axis.label.size = 2.3,
          grid.line.width = 1,
          grid.label.size = 4,
          gridline.max.linetype = "solid",
          gridline.mid.linetype = "solid",
          gridline.min.linetype = "solid",
          background.circle.colour = "white",
          gridline.mid.colour = "grey",
          legend.position = "bottom",
  )+
  theme_minimal()+
  theme(legend.position = "bottom",
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.title.y=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
  )

ggsave(plot = last_plot(), 
       filename = "img/cluster-profiles/radar-plot/supergroups.jpg", 
       width = 25, 
       height = 20, 
       units = "cm",
       dpi=300)





#------------------------------------------------------------------------
#------------------------------------------------------------------------
# Radar Plots--------------------------------------------------------------
#------------------------------------------------------------------------
#------------------------------------------------------------------------

# create a vector to store supergroup code/names
# this will be used in a for loop to match and create radar plot for each supergroup
supergroup_nms = c( 
  "1 Struggling, More Vulnerable Urbanites",
  "2 Multicultural Central Urban Living",
  "3 Rurban Comfortable Ageing",
  "4 Retired Fringe and Residential Stability",
  "5 Cosmopolitan Comfort Ageing"     
)

# start the for loop of generating radar plots for each supergroup and the groups within



for (i in c(1:length(supergroup_nms))) {
  # radar plot for the supergroup
  aipc_df %>%
    filter(supergroup_name == supergroup_nms[i])%>%
    dplyr::select(geography_code, supergroup_name) %>% 
    left_join(result_z_score, by = c("geography_code"="geography_code")) %>% 
    dplyr::select(-geography_code) %>%
    group_by(supergroup_name) %>%
    summarise_all(.funs=mean) %>%
    rename(group = supergroup_name) %>% 
    ggradar(values.radar = c("-2.5" ,"0", "2"),
            grid.mid = 0, grid.max = 2, grid.min = -2.5,
            group.line.width = 0.5, 
            group.point.size = 2,
            group.colours = c("#ea7070", "#F9CE00", "#9dd3a8","#1F6ED4","#69619B"),
            axis.label.offset = 1.1,
            axis.label.size = 2.3,
            grid.line.width = 1,
            grid.label.size = 4,
            gridline.max.linetype = "solid",
            gridline.mid.linetype = "solid",
            gridline.min.linetype = "solid",
            background.circle.colour = "white",
            gridline.mid.colour = "grey",
            legend.position = "bottom",
    )+
    theme_minimal()+
    theme(legend.position = "bottom",
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          axis.title.y=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks.y=element_blank(),
          legend.title = element_blank()
          
    )
  
  ggsave(plot = last_plot(), 
         filename = "img/cluster-profiles/radar-plot/supergroup-"%>% paste0(i) %>% paste0(".jpg"), 
         width = 25, 
         height = 20, 
         units = "cm",
         dpi=300)
}


group_colors = data.frame(sg1_color = c("#FBAF90","#FC6A4A","#CB1C1E"),
                          sg2_color = c("#FECC5E","#FD8D3B",NA),
                          sg3_color = c("#BAE4B4","#75C477",NA),
                          sg4_color = c("#BCD7E8","#6BAED5","#2271B5"),
                          sg5_color = c("#CBACDC","#9068BF","#661467")
)  

# radar plot for the groups within the parent supergroup
for (i in c(1:length(supergroup_nms))) {
  aipc_df %>%
    filter(supergroup_name == supergroup_nms[i]) %>%
    dplyr::select(geography_code, group_name) %>% 
    left_join(result_z_score, by = c("geography_code"="geography_code")) %>%
    dplyr::select(-geography_code) %>%
    group_by(group_name) %>%
    summarise_all(.funs=mean) %>%
    rename(group = group_name) %>%
    ggradar(values.radar = c("-2.5" ,"0", "2"),
            grid.mid = 0, grid.max = 2, grid.min = -2.5,
            group.line.width = 0.5, 
            group.point.size = 2,
            #group.colours = brewer.pal(n=4,name = "Reds")[2:4],
            group.colours = group_colors[,i],
            axis.label.offset = 1.1,
            axis.label.size = 2.3,
            grid.line.width = 1,
            grid.label.size = 4,
            gridline.max.linetype = "solid",
            gridline.mid.linetype = "solid",
            gridline.min.linetype = "solid",
            background.circle.colour = "white",
            gridline.mid.colour = "grey",
            legend.position = "bottom",
    )+
    theme_minimal()+
    theme(legend.position = "bottom",
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          axis.title.y=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks.y=element_blank(),
          legend.title = element_blank()
    )
  
  ggsave(plot = last_plot(), 
         filename = "img/cluster-profiles/radar-plot/supergroup-"%>% paste0(i) %>% paste0("-groups.jpg"), 
         width = 25, 
         height = 20, 
         units = "cm",
         dpi=300)
  
}




#------------------------------------------------------------------------
#------------------------------------------------------------------------
# Bar Plots--------------------------------------------------------------
#------------------------------------------------------------------------
#------------------------------------------------------------------------

colnames(result_z_score) <- str_remove_all(colnames(result_z_score), "\n")


# read the input variables names and match the associated domains
input_var_nms <- read.csv('data/input/input-var-nms.csv')
domains_df = data.frame(var_nm = colnames(result_z_score %>% dplyr::select(-geography_code)),
                        dom_nm = c(
                          rep("1:People",19),
                          rep("2:Housing",12),
                          rep("3:Work and Education",12),
                          rep("4:Mobility",2),
                          rep("5:Health",9),
                          rep("6:Digital",5),
                          rep("7:Financial Security",2 ),
                          rep("8:Outdoor Space and Living Environment",9),
                          rep("9:Civc Participation",1)
                        )
)


# get the order of variables (for bar plot) based on supergroup 1
var_order= aipc_df %>%
  filter(supergroup_name =="1 Struggling, More Vulnerable Urbanites") %>%
  dplyr::select(geography_code, supergroup_name) %>% 
  left_join(result_z_score, by = c("geography_code"="geography_code")) %>% 
  dplyr::select(-geography_code) %>%
  group_by(supergroup_name) %>%
  summarise_all(.funs=mean) %>%  
  rename(group = supergroup_name) %>%
  mutate(group = str_wrap(group,width=25)) %>% 
  dplyr::select(-group) %>% 
  melt() %>% as.data.frame() %>% left_join(domains_df,by = c("variable"="var_nm")) %>% 
  dplyr::arrange(dom_nm,desc(value)) %>% 
  mutate(var_order= c(1:nrow(input_var_nms))) %>%
  dplyr::select(variable,dom_nm,var_order)



# creating bar plots for each supergroup
for (i in c(1: length(supergroup_nms))) {
  aipc_df %>%
    filter(supergroup_name == supergroup_nms[i])%>%
    dplyr::select(geography_code, supergroup_name) %>% 
    left_join(result_z_score, by = c("geography_code"="geography_code")) %>% 
    dplyr::select(-geography_code) %>%
    group_by(supergroup_name) %>%
    summarise_all(.funs=mean) %>%  
    rename(group = supergroup_name) %>%
    mutate(group = str_wrap(group,width=25)) %>% 
    dplyr::select(-group) %>% 
    melt() %>% as.data.frame() %>% 
    right_join(var_order,by = c("variable"="variable")) %>%
    dplyr::arrange(var_order) %>% 
    ggplot()+
    geom_bar(aes(x=var_order, y=value,fill = dom_nm),stat='identity')+
    scale_x_continuous(breaks = c(1:71),labels = var_order$variable)+
    scale_fill_manual(name = "Variable \nDomain", values = brewer.pal(9,"Set3"),
                      labels = c("People", "Housing", "Work and \nEducation",
                                 "Mobility","Health","Digital",
                                 "Financial Security", "Outdoor Space and \nLiving Environment","Civic Participation"
                      ))+
    theme_minimal()+
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
    xlab("Variable")+
    ylab("mean value of z-score")+
    ylim(-2.7,2)+
    #ggtitle("Mean value of z-sore: " %>% paste0(supergroup_nms[i]))+
    theme(legend.position = c(0.5, -0.35),
          legend.direction = "horizontal",
          axis.title.x = element_blank(),
          
    )
  
  ggsave(plot = last_plot(), 
         filename = "img/cluster-profiles/bar-plot/reorder-vars-supergroup" %>% paste0(substr( supergroup_nms[i],1,2)) %>% paste0( ".jpg"), 
         width = 35, 
         height = 17, 
         units = "cm",
         dpi=300)
}


# create a vector to store group code/names
# this will be used in a for loop to match and create bar plot for each group
group_nms = c("1.1 Disadvantaged Single Households",
              "1.2 Struggling White British",
              "1.3 Terraced Mix, Relative Stability",
              "2.1 Inner City Diverse Living",
              "2.2 Peripheral Constrained Diverse Living",
              "3.1 Rural Comfortable Ageing",
              "3.2 Ageing in the Affluent Fringe",
              "4.1 Retired Country and Coastal Living",
              "4.2 Comfortable Rural/Suburban Ageing Workers and Retirees",
              "4.3 Constrained Semi-Rural Ageing and Retirement",
              "5.1 Cosmopolitan Family Ageing",
              "5.2 Coastal Later Aged Retirees",
              "5.3 Cosmopolitan Ageing"
)

for (i in c(1: length(group_nms))) {
  aipc_df%>%
    filter(group_name == group_nms[i]) %>%
    left_join(result_z_score, by = c("geography_code"="geography_code")) %>%
    dplyr::select(-geography_code,-supergroup_code,-group_code,-supergroup_name) %>%
    group_by(group_name) %>%
    group_by(group_name) %>%
    summarise_all(.funs=mean) %>%
    rename(group = group_name) %>%
    mutate(group = str_wrap(group,width=25)) %>% 
    dplyr::select(-group) %>%
    melt() %>% as.data.frame() %>% 
    right_join(var_order,by = c("variable"="variable")) %>%
    dplyr::arrange(var_order) %>% 
    ggplot()+
    geom_bar(aes(x=var_order, y=value,fill = dom_nm),stat='identity')+
    scale_x_continuous(breaks = c(1:71),labels = var_order$variable)+
    scale_fill_manual(name = "Variable \nDomain", values = brewer.pal(9,"Set3"),
                      labels = c("People", "Housing", "Work and \nEducation",
                                 "Mobility","Health","Digital",
                                 "Financial Security", "Outdoor Space and \nLiving Environment","Civic Participation"
                      ))+
    theme_minimal()+
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
    xlab("Variable")+
    ylab("mean value of z-score")+
    ylim(-2.7,2)+
    theme(legend.position = c(0.5, -0.35),
          legend.direction = "horizontal",
          axis.title.x = element_blank())
  
  ggsave(plot = last_plot(), 
         filename = "img/cluster-profiles/bar-plot/reorder-vars-group" %>% paste0(substr(group_nms[i],1,3) %>% paste0( ".jpg")), 
         width = 35, 
         height = 17, 
         units = "cm",
         dpi=300)
  
  
}