# Cargamos la base de datos de nombre de estados y municipios para usarla 
# en los mapas
Nombres <- read_csv("./data/Nombres_entidad_municipio.csv", 
                    locale = locale(encoding = "ISO-8859-1"))
Nombres <- Nombres %>% select(K_ENTIDAD_MUNICIPIO,nom_ent,nom_mun)