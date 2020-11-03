######---- Carga base de datos de accesos de banda ancha fija en Mexico ----######

BAF_raw <- read_csv("data/TODO_BAF/TD_ACC_BAF_ITE_VA.csv", 
                    col_types = cols(ANIO = col_character(), 
                                     K_ACCESO_INTERNET = col_character(), 
                                     K_ENTIDAD = col_character(), 
                                     K_MUNICIPIO = col_character(), 
                                     MES = col_character()), 
                    locale = locale(encoding = "ISO-8859-1"))

# Modificacmos los datos atipicos de de Mayapan (Yucatan) y Rayon (Estado de 
# Mexico) 

# Los municipios circundates a Mayapan no tienen penetracion de BAF en cable 
# coaxial ni fibra optica. Nota: Se considera que Mayapan tampoco (error en la 
# base del Banco de informacion de Telecomunicaciones de Mexico)

indice_mayapan = (BAF_raw$ANIO == "2019")*(BAF_raw$ENTIDAD == "Yucatan")*(BAF_raw$MUNICIPIO == "Mayapan")

for (i in which(indice_mayapan==1)){
  BAF_raw$A_TOTAL_E[i]<-0
}

rm(indice_mayapan)
rm(i)

# El nivel reportado de penetracion para Rayon es muy alto debido a 
# incosistencias con los accesos reportados por Megacable en los meses 04, 05 y 
# 06 de 2019. Se les imputa el valor historico mas reciente, que es congruente 
# con los datos historicos previos.


indice_rayon = (BAF_raw$ANIO == "2019")*(BAF_raw$ENTIDAD == "Mexico.")*(BAF_raw$MUNICIPIO == "Rayon..") *(BAF_raw$EMPRESA == "MEGACABLE")*(BAF_raw$TECNO_ACCESO_INTERNET == "Cable Coaxial")

indice_rayon_03 = which((indice_rayon*(BAF_raw$MES == "03"))==1)
indice_rayon_04 = which((indice_rayon*(BAF_raw$MES == "04"))==1)
indice_rayon_05 = which((indice_rayon*(BAF_raw$MES == "05"))==1)
indice_rayon_06 = which((indice_rayon*(BAF_raw$MES == "06"))==1)

BAF_raw$A_TOTAL_E[indice_rayon_04] <- BAF_raw$A_TOTAL_E[indice_rayon_03] 
BAF_raw$A_TOTAL_E[indice_rayon_05] <- BAF_raw$A_TOTAL_E[indice_rayon_03] 
BAF_raw$A_TOTAL_E[indice_rayon_06] <- BAF_raw$A_TOTAL_E[indice_rayon_03] 


### Transformacion y limpieza de la base de accesos

## Crea una llave para cruzar con las otras bases
BAF_study <- BAF_raw 
BAF_study$K_MUNICIPIO <- substr(BAF_study$K_MUNICIPIO,3,5)
BAF_study <- BAF_study  %>% mutate(K_ENTIDAD_MUNICIPIO = paste(K_ENTIDAD, 
                                                        K_MUNICIPIO, sep = ""))

## seleccion variable y alarga la bases de accesos por tecnologia

# suma los accesos de todos los operadores en el municipio por tecnologia
BAF_study <- BAF_study %>%  select(K_ENTIDAD_MUNICIPIO,K_ENTIDAD,K_MUNICIPIO, 
                                   ANIO, MES,K_ACCESO_INTERNET, A_TOTAL_E) %>% 
  group_by(K_ENTIDAD_MUNICIPIO,K_ENTIDAD,K_MUNICIPIO, ANIO, MES, 
           K_ACCESO_INTERNET) %>% summarise_all(funs(sum))

BAF_study <- BAF_study %>% ungroup()

BAF_study<- BAF_study %>% spread(K_ACCESO_INTERNET, A_TOTAL_E)

## El detalle de accesos a nivel municipal con NA se imputa con cero
BAF_study <- BAF_study %>% mutate_all(~replace(., is.na(.), 0))

# Renombramos columnas de accesos segun su tecnologia
names(BAF_study)[6] <- "CABLE_COAXIAL"
names(BAF_study)[7] <- "DSL"
names(BAF_study)[8] <- "FIBRA_OPTICA"
names(BAF_study)[9] <- "SATELITAL"
names(BAF_study)[10] <- "TERRESTRE_FIJO_INALAMBRICO"
names(BAF_study)[11] <- "OTRAS_TECNOLOGIAS"
names(BAF_study)[12] <- "SIN_TECNOLOGIA_ESPECIFICADA"

# Agregamos columna de todos los accesos del municipio
BAF_study <- BAF_study %>% mutate(ALL_ACCESS = 
  CABLE_COAXIAL
  +DSL
  +FIBRA_OPTICA
  +SATELITAL
  +TERRESTRE_FIJO_INALAMBRICO
  +OTRAS_TECNOLOGIAS
  +SIN_TECNOLOGIA_ESPECIFICADA)

# Agregamos columna de todos los accesos cable coaxial y fibra optica del 
# municipio
BAF_study <- BAF_study %>% mutate(COAX_FO = CABLE_COAXIAL+FIBRA_OPTICA)

# Se excluyen los datos de accesos que no tienen ubicacion de municipio
BAF_062019 <-  subset(BAF_study, ANIO == "2019" & MES == "06" & 
                        K_ENTIDAD != "99"  & K_MUNICIPIO != "999" )

# ----- Contamos la cantidad de empresas presentes en el municipio

# Filtramos la base en crudo para junio de 2019
BAF_raw062019<- BAF_raw %>%filter(ANIO=="2019" & MES == "06" & 
                                    K_ENTIDAD != "99"  & K_MUNICIPIO != "999" )

## Crea una llave para cruzar con las otras bases
BAF_raw062019$K_MUNICIPIO <- substr(BAF_raw062019$K_MUNICIPIO,3,5)
BAF_raw062019 <- BAF_raw062019  %>% mutate(K_ENTIDAD_MUNICIPIO = 
                                      paste(K_ENTIDAD, K_MUNICIPIO, sep = ""))

# Crea la base auxiliar que tiene por clave de municipio la cantidad de empresas
# de BAF en esta 
BAF_study_ops <- BAF_raw062019 %>% select(K_ENTIDAD_MUNICIPIO) %>% unique()
BAF_study_ops$NUM_OPS <-NA

for (i in 1:nrow(BAF_study_ops)){
  folio =BAF_study_ops$K_ENTIDAD_MUNICIPIO[i]
  n <- BAF_raw062019 %>% select(EMPRESA,K_ENTIDAD_MUNICIPIO) %>% filter(K_ENTIDAD_MUNICIPIO == BAF_study_ops$K_ENTIDAD_MUNICIPIO[i]) %>% unique() %>% nrow()
  BAF_study_ops$NUM_OPS[i]= n
}

# Agrega un columna de la cantidad total de empresas que cuentan con al menos 
# un acceso de BAF en cada municipio
BAF_062019 <- left_join(BAF_062019,BAF_study_ops, by = "K_ENTIDAD_MUNICIPIO")

#----- Escribe la base final
write_csv(BAF_062019, "data/processed/BAF_062019.csv")

# Eliminamos objetos auxiliares
rm(list = c("BAF_062019","BAF_raw","BAF_raw062019", "BAF_study",
            "BAF_study_ops","folio","i","indice_rayon",
            "indice_rayon_03","indice_rayon_04","indice_rayon_05",
            "indice_rayon_06","n"))