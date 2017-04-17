

setwd("~/stwur_private/STWUR-2017-04-19/")

library(ggplot2) #funkcja fortify, przekształcenie do SpatialPolygons do data.frame
library(dplyr)
require(rgdal) #funkcja readOGR
require(rgeos) #funkcja gSimplify i spTransform

# ściągamy dane, których właścicielem jest UE
# © EuroGeographics for the administrative boundaries

# download.file(url = "http://ec.europa.eu/eurostat/cache/GISCO/geodatafiles/NUTS_2010_03M_SH.zip", 
# 							destfile = "NUTS_2010_03M_SH.zip")
# unzip("NUTS_2010_03M_SH.zip", exdir = paste0(getwd(), "/data"))

# metadane można pobrać ze strony http://ec.europa.eu/eurostat/ramon/nomenclatures/index.cfm?TargetUrl=LST_CLS_DLD&StrNom=NUTS_33&StrLanguageCode=EN
nuts_dict <- read.csv("data/NUTS_33_20170310_202719.csv", stringsAsFactors = FALSE)

EU_NUTS <- readOGR(dsn = "data/NUTS_2010_03M_SH/Data/", layer = "NUTS_RG_03M_2010")
kody <- data.frame(id=as.character(0:1919), kod=EU_NUTS@data$NUTS_ID, stringsAsFactors = FALSE)
PL_NUTS <- EU_NUTS[grepl("PL", EU_NUTS@data$NUTS_ID), ]
PL_NUTS <- spTransform(PL_NUTS, CRS("+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs"))
PL_NUTS <- gSimplify(PL_NUTS, tol = 100, topologyPreserve=TRUE)
PL_NUTS <- spTransform(PL_NUTS, CRS("+proj=longlat +datum=WGS84"))

#plot(PL_NUTS)
podregiony <- fortify(PL_NUTS)

podregiony_nazwy_kody <- kody %>%
  inner_join(nuts_dict, by = c("kod" = "NUTS.Code")) %>%
  filter(grepl(pattern="PL", kod)) %>%
  mutate(Description = tolower(Description),
         Description = gsub(pattern = "miasto (.*)", replacement = "\\1", Description))
podregiony_nazwy_kody$Description <- enc2utf8(podregiony_nazwy_kody$Description)

save(podregiony, podregiony_nazwy_kody, file = "data/ksztalt_podregionow_data_frame.Rdata")


