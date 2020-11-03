# Creamos una variable para hacer mapas de penetracion de cable coaxial y fibra optica
PenetrationBAF_Habitantes <- df

# Crea nombres de columnas value y region que se necesita para usan alimentar la función mxmunicipio_choropleth
PenetrationBAF_Habitantes$value <- PenetrationBAF_Habitantes$PEN_BAF_HOGS # Valores para escala de colores
PenetrationBAF_Habitantes$region <- PenetrationBAF_Habitantes$K_ENTIDAD_MUNICIPIO # Llave principal de municipios de INEGI

# Definicion de paleta de colores a partir de valores de penetracion
# http://www.di.fc.ul.pt/~jpn/r/GraphicalTools/colorPalette.html
# "RdYlBu", "Accent", or "Greens"
#"viridis", "magma", "inferno", or "plasma".

# Spectral para el mapa de BAF para hogares
pal <- colorNumeric(palette = "Spectral", domain = PenetrationBAF_Habitantes$value) 

mymap<-mxmunicipio_leaflet(PenetrationBAF_Habitantes,
                    pal,
                    ~ pal(value),
                    ~ sprintf("Estado: %s<br/>Municipio : %s<br/>Penetración: %s ",
                              nom_ent, nom_mun, round(value,1))) %>%
  addLegend(position = "topright", 
            pal = pal, 
            values = PenetrationBAF_Habitantes$value,
            title = "Accesos de cable coaxial y fibra <br/>  óptica por cada 100 hogares",
            labFormat = labelFormat(suffix = "",
                                    transform = function(x) {x})) %>%
  addProviderTiles("CartoDB.Positron")

# Salva el mapa
saveWidget(mymap, file="fixed-broadband-map-mexico.html")