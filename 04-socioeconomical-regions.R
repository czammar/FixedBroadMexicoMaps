RegionesSocioEcono <- read_csv("./data/RegionesSocioEcono.csv", 
                               col_types = cols(NOM_ABRE_ENTIDAD = col_skip(), 
                                  NOM_ENTIDAD = col_skip(), NUM = col_skip()))