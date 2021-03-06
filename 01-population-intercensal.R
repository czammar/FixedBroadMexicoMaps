######---- Carga base de datos de poblacion por municipio en Mexico (Encuesta Intercensal INEGI, 2015) ----######

# Directorio donde se localizan los archivos a unir

left_path = "./data/Intercensal2015/01_poblacion_"
right_path = ".xls"
states_list = c("ags","bc","bcs","cam","coah","col","chis","chih","cdmx","dgo",
                "gto","gro","hgo","jal","mex","mich","mor","nay","nl","oax",
                "pue","qro","qroo","slp","sin","son","tab","tamps","tlax","ver"
                ,"yuc","zac")

# Funcion para extraer los datos de poblacion

cleaning_pop_state<-function(name_state){
  # Carga el archivo con el path descrito
  test <-read_excel(paste0(left_path,name_state,right_path), sheet = 3, 
                    col_names = FALSE, col_types = NULL, na = "", skip = 10)
  
  # Nombres temporales de las variables
  colnames(test)<- c("X1","X2","X3","X4","X5","X6","X7")
  
  # Filtrado para obtener datos de poblacion en municipios
  test<-subset(test, X2 != "Total" & X3 == "Total" & X4 == "Valor")
  
  # seleccion de variables de estado, municipio y poblacion, para renombrarlas
  test<- test %>% select(X1,X2,X5)
  colnames(test)<- c("K_ENTIDAD","K_MUNICIPIO","POBLACION")
  
  # Obtiene claves de identificacion de estado y municipio
  test$K_ENTIDAD <- substr(test$K_ENTIDAD,1,2)
  test$K_MUNICIPIO<- substr(test$K_MUNICIPIO,1,3)
  
  # Crea nueva variable con clave y
  test <- test %>% mutate(K_ENTIDAD_MUNICIPIO = paste(K_ENTIDAD, K_MUNICIPIO, sep=""))
  test <-test %>% select(K_ENTIDAD_MUNICIPIO, POBLACION)
  
  return(test)
}

test = cleaning_pop_state("ags")

for (name_state in states_list ){
  test <- rbind(test,cleaning_pop_state(name_state))
  
}

# Elimina duplicados
test<-unique(test)
poblacion2015<-test

# Escribe la base de poblacion en el municipio
write_csv(poblacion2015,"data/processed/poblacion2015.csv")
