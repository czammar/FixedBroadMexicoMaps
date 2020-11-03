# Instala paquete devtools
if (!require(devtools)) {
  install.packages("devtools")
}
devtools::install_github('diegovalle/mxmaps')

# Revisa si los paquetes necesarios estan instalados

list.of.packages <- c("tidyverse", "readr", "readxl", 
                      "dplyr","leaflet",
                      "viridis", "scales","htmlwidgets")
new.packages <- list.of.packages[!(list.of.packages %in%
                                   installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)


# Procesamiento de archivos para mapas
source("00-fixedbroadband-mexico.R")
source("01-population-intercensal.R")
source("02-households-intercensal.R")
source("03-names-municipalites.R")
source("04-socioeconomical-regions.R")
source("05-data-for-maps.R")
source("06-fixedbroadband-maps-mexico.R")

#  salva la version limpia de los datos al archivo
