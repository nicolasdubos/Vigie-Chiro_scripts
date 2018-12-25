library(data.table)
library(sp)
library(raster)
library(maptools)
#library(Rnightlights)
#OccSL=fread("./vigiechiro/Traits/GBIF/OccSL_bush-cricket.csv")
FOccSL="./vigiechiro/GIS/carre_stoc"
OccSL=fread(paste0(FOccSL,".csv"))
CoordH=c("Group.1", "Group.2")
BufferMedium=500
BufferLarge=5000

Sys.time()
#r�cup�ration de la BD Alti
asc_files<- list.files("C:/Users/Yves Bas/Downloads/BDALTIV2_2-0_75M_ASC_LAMB93-IGN69_FRANCE_2018-01-15/BDALTIV2/1_DONNEES_LIVRAISON_2018-01-00245/BDALTIV2_MNT_75M_ASC_LAMB93_IGN69_FRANCE"
                       ,pattern =".asc$",full.names=T)
Sys.time()

testH=match(CoordH,names(OccSL))
OccSL=subset(OccSL,!is.na(as.data.frame(OccSL)[,testH[1]]))
OccSL=subset(OccSL,!is.na(as.data.frame(OccSL)[,testH[2]]))


#coordinates(OccSL) <- c("decimalLongitude", "decimalLatitude")
coordinates(OccSL) <- CoordH
proj4string(OccSL) <- CRS("+init=epsg:4326") # WGS 84

#CRS.new <- CRS(proj4string(CarthageP))
OccSL_L93=spTransform(OccSL,CRS("+init=epsg:2154"))


#extraction des donn�es alti
rast.list <- list()
for(i in 1:length(asc_files)) { rast.list[i] <- raster(asc_files[i]) }
rast.list$fun <- mean
Sys.time()
AltiTot <- do.call(mosaic,rast.list) # 8 min
Sys.time()
#plot(AltiTot)
Sys.time()
#extraction des altitudes ponctuelles
Sys.time()
SpAltiS=extract(AltiTot,OccSL_L93) # < 0.001 sec / points
OccSL=spCbind(OccSL,SpAltiS)
spplot(OccSL,zcol="SpAltiS",main="SpAltiS")

Sys.time()
SpAltiM=extract(AltiTot,OccSL_L93,buffer=BufferMedium,fun=mean) # 0.01 sec / points
OccSL=spCbind(OccSL,SpAltiM)
spplot(OccSL,zcol="SpAltiM",main="SpAltiM")

Sys.time()
SpAltiL=extract(AltiTot,OccSL_L93,buffer=BufferLarge,fun=mean) # 0.02 sec / points
Sys.time()

OccSL=spCbind(OccSL,SpAltiL)
spplot(OccSL,zcol="SpAltiL",main="SpAltiL")


Alti=data.frame(cbind(coordinates(OccSL),SpAltiS,SpAltiM,SpAltiL))

fwrite(Alti,paste0(FOccSL,"_Alti.csv"))

coordinates(Alti) <- CoordH

SelCol=sample(c("SpAltiS","SpAltiM","SpAltiL"),1)
spplot(Alti,zcol=SelCol,main=SelCol)
