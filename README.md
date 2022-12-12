# Ageing in Place Classification
AiPC (Ageing in Place Classification) is a two-tiered hierarchical geodemographic classification of older people in England using 2011 UK Census data and a number of other secondary datasets. It consists of 5 Supergroups (first tier) and 13 Groups (second tier).

You can access the online map for free from CDRC (Consumer Data Research Centre) Mapmaker platform [here](https://mapmaker.cdrc.ac.uk/#/ageing-in-place-classification).
[![CDRC Mapmaker](https://github.com/yyuanxuan/AiPC/blob/main/img/readme-img/CDRC-Mapmaker.png)](https://mapmaker.cdrc.ac.uk/#/ageing-in-place-classification)

The paper describing the approach of creating AiPC is open access and freely available [here](https://link.springer.com/article/10.1007/s12061-022-09490-y).

[![AiPC method paper screenshot](https://github.com/yyuanxuan/AiPC/blob/main/img/readme-img/AiPC-paper.png)](https://link.springer.com/article/10.1007/s12061-022-09490-y)

## Download the data
You can have access to different formats of AiPC and documentations from CDRC [(Link)](https://data.cdrc.ac.uk/dataset/ageing-place-classification-aipc), these include:
* Pen Portraits
* Data Profile
* Ageing in Place Classification (.csv file)
* AiPC GeoPackage
* AiPC Shapefile


## Repository
This GitHub repository contains the codes (in R) for creating the AiPC, focusing on the two-tier clustering analysis and profiling.

## Acknowledgement
This research is funded by [Nuffield Foundation; grant ref: WEL/44091.2](https://www.nuffieldfoundation.org/project/older-people-in-england-geography-of-challenges-and-opportunities)

The BPS (British Population Survey) data in this research has been provided by the Consumer Data Research Centre (CDRC), an ESRC Data Investment, under project ID CDRC 119, ES/L011840/1; ES/L011891/1. AHAH (Access to Healthy Assets & Hazards) dataset, broadband download speed data and CDRC Residential Mobility index are also provided by CDRC and have been used in this work. 

We would like to thank Ordnance Survey for providing the Point of Interests (POI) data, and thanks to the Department for Transport for the JTS (Journey Time Statistics) dataset. The Median House Price Dataset from ONS has also been used in this work. Thanks to the Department for Communities and Local Government for providing the English Index of Multiple Deprivation (IMD) 2019 dataset, where several variables in the IMD are included in this work for classification. The English Prescribing Data (EPD) and the associated Registered Patients Data are openly available from NHS Business Services Authority and NHS Digital. Thanks also go to Department for Business, Energy and Industrial Strategy for providing the fuel poverty data, which is the Low Income Low Energy Efficiency indicator.