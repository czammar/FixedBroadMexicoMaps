# Penetration of Fixed Broadband for high speed technologies
A map to analize [fixed broadband data for Mexico](https://github.com/czammar/BandaAnchaFija) considering penetration for technologies that can bring high speed services (optical fiber and coaxial cable) at municipal level for Mexico at June 2019.

It is based on an OCDE metric to quantify penetration within a zone (http://www.oecd.org/internet/broadband/broadband-faqs.htm](http://www.oecd.org/internet/broadband/broadband-faqs.htm):

$$Penetration Fixed Broadband per Habitans = \frac{\# Access }{\# Habitants} \times 100$$

**Notes:**

* It considers all broadband access technologies for local loop deployed in Mexico until June 2019
* Demographical data is limited to census exercises of 2015, due to COVID 2019.
* There is no public data for VDSL access, so comparative is limited.
* We use R library *mapsmx* (https://www.diegovalle.net/mxmaps/)

## 1. Instructions

Data gathering and wrangling and map generation are base mostly on Bash and Rscripts. Please do as follows:

## 1.1 Data Sources

**Household and population data for Mexico in 2015**

Source: Encuesta Intercensal 2015, from INEGI, Mexico. You can dowload it using the following terminal commands:

```
# Dowload household and population data for Mexico in 2015
wget -i ./data/Intercensal2015/urls_hogares.txt -P ./data/Intercensal2015/
wget -i ./data/Intercensal2015/urls_poblacion.txt -P ./data/Intercensal2015/
```

**Fixed Broadband access data for Mexico**

Source: Banco de Información de Telecomunicacion of Instituto Federal de Telecomunicaciones (México, https://bit.ift.org.mx/BitWebApp/). This give data for all local loop technologies present in Mexican Market (e.g xDSL, Optical Fibre, Coaxial Cable). Data was placed in **/data/TODO_BAF**

**Geografic information for Mexico**

Source: Marco Geoestadístico, INEGI https://www.inegi.org.mx/temas/mg/

## 1.2 Generation Maps

Just run R script

```
Maps-FixedBroadBand.R
```

An interactive map named as [**fixed-broadband-map-mexico.html**](https://rpubs.com/czammar/fixedbroadbandMX) is generated in current directory.

## 2. Highlights

* Within OCDE Countries, Fixed broadband subscriptions per 100 inhabitants (considering all posible technologies for local loop) was close to 30.9 (http://www.oecd.org/sti/broadband/1.1-TotalBBSubs-bars-2019-12.xls), at December 2018. In case of Mexico, Fixed broadband subscriptions per 100 inhabitants was close to 14.8.
* 