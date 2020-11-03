# Load data for households, population and fixed broadband access in Mexico
hogares2015<- read_csv("./data/processed/hogares2015.csv")
poblacion2015<- read_csv("./data/processed/poblacion2015.csv")
BAF_062019 <- read_csv("./data/processed/BAF_062019.csv")

# Consolidamos las bases
df <- left_join(hogares2015,poblacion2015, by = "K_ENTIDAD_MUNICIPIO")
df <- left_join(df,BAF_062019, by = "K_ENTIDAD_MUNICIPIO")
df <- left_join(df,Nombres, by = "K_ENTIDAD_MUNICIPIO")


# Imputamos ceros donde no hay datos de penetracion
df <- df %>% mutate_all(~replace(., is.na(.), 0))

# Seleccionamos variables de interes y creamos otras
df <- df %>% select(K_ENTIDAD_MUNICIPIO, K_ENTIDAD, K_MUNICIPIO,
                    nom_ent, nom_mun, HOGARES, POBLACION, ALL_ACCESS, COAX_FO)
df <- df %>% mutate(PEN_BAF_HOGS = 100*COAX_FO/HOGARES) # Penetracion por cada 100 hogares
df <- df %>% mutate(PEN_BAF_HABS = 100*COAX_FO/POBLACION) # Penetracion por cada 100 habitantes

# Agregamos una columna que nos diga la region socioecnomica a la que pertenece el municipio
df <- df %>% mutate(K_ENTIDAD = substr(K_ENTIDAD_MUNICIPIO,1,2))
df <- left_join(df,RegionesSocioEcono, by = "K_ENTIDAD")

for (index in 1:nrow(df)){
  df$REG_SOCIOECONOM[index] <- if_else(df$REG_SOCIOECONOM[index]=="Centronorte",1, 
                                       if_else(df$REG_SOCIOECONOM[index]=="Centrosur",2,
                                               if_else(df$REG_SOCIOECONOM[index]=="Noreste",3,
                                                       if_else(df$REG_SOCIOECONOM[index]=="Noroeste",4,
                                                               if_else(df$REG_SOCIOECONOM[index]=="Occidente",5,
                                                                       if_else(df$REG_SOCIOECONOM[index]=="Oriente",6,
                                                                               if_else(df$REG_SOCIOECONOM[index]=="Sureste",7,8)))))))
}