library(data.table)
#ETAPE 0 - IMPORT DES TABLES
#bien renommer les chemins en fonction de l'ordi utilis�
#et v�rifier les versions (date, import complet ou non)

LatMin=0
LatMax=90
LongMin=-180
LongMax=180


#table "donn�es"
DataTot=fread("C:/wamp64/www/export.txt")
Sys.time()
DataRP=subset(DataTot,substr(DataTot$donnee,1,3)=="Cir")
Sys.time()
rm(DataTot)

#table "participations"
Particip=fread("C:/wamp64/www/p_export.csv",encoding="UTF-8")
Particip=as.data.frame(Particip)
#table "localit�s"
SiteLoc=fread("C:/wamp64/www/sites_localites.txt",sep="\t")
SiteLocRP=subset(SiteLoc,SiteLoc$protocole!="POINT_FIXE")
#aggr�gation au tron�on
SiteLocRP$Tron=sapply(SiteLocRP$nom,FUN=function(x) if(nchar(x)>2){substr(x,3,nchar(x)-2)}else{x})
SiteLocRP$Secteur=sapply(SiteLocRP$nom,FUN=function(x) if(nchar(x)>2){substr(x,nchar(x),nchar(x))}else{3})
#cr�e une table avec une seule ligne par tron�on (un tron�on est donc r�duit � son 3�me secteur)
SiteLocRP_TronU=subset(SiteLocRP,SiteLocRP$Secteur=="3")





microdroitRP<-function(x)
{
  substr(x,nchar(x)-10,nchar(x)-10)=="1"
}

#pour afficher les milisecondes
op <- options(digits.secs=3)
#pour reset
#options(op)

#merge Localites et participations
PartProt=substr(Particip$site,1,22)
table(PartProt)
PartRP=subset(Particip,PartProt!="Vigiechiro - Point Fix")
table(PartRP$canal_expansion_temps)
LocaPart=merge(PartRP,SiteLocRP_TronU,by="site")


#DataTot=subset(DataTot,DataTot$espece!="noise")
colnames(DataRP)[10]="temps_fin"
LocaPartData=as.factor(substr(DataRP$donnee,1,27)) #r�cup�ration de l'identifiant du point/tron�on
Sys.time()
Datamicro=as.character(sapply(DataRP$donnee,FUN=microdroitRP)) # r�cup�ration du num�ro du micro (4 min)
Sys.time()

DataSel2=cbind(DataRP,LocaPartData,Datamicro)
rm(DataRP)
rm(LocaPartData)
rm(Datamicro)


FileInfo=as.data.table(tstrsplit(DataSel2$donnee,"-"))
DataSel2$Session=substr(FileInfo$V4,5,nchar(FileInfo$V4))
TimeSec=as.data.table(tstrsplit(FileInfo$V5,"_"))
TimeSec=as.data.frame(TimeSec)
#test=(is.na(as.numeric(TimeSec$V4)))
#DataBug=subset(DataSel2,test)
#TimeBug=subset(TimeSec,test)
Sys.time()
DataSel2$TimeTron=mapply(FUN=function(x,y,z) if(is.na(z))
  {as.numeric(x)+as.numeric(y)/1000}else{as.numeric(y)+as.numeric(z)/1000}
  ,TimeSec$V2,TimeSec$V3,TimeSec$V4) # 8 sec
Sys.time()
gc()

Sys.time()
DataLP_RP=merge(DataSel2,LocaPart
                ,by.x=c("participation","Session")
                ,by.y=c("participation","Tron")) # 2 sec
Sys.time()
rm(DataSel2)
gc()

#purge des champs inutiles pour gagner de la m�moire (� remonter ?)
ListePurge=c("proprietaire","num site",
             "observateur.x",
             "email.y",
             "id_protocole",
             "protocole",
             "localite",
             "date.y",
             "observateur.y",
             "nb_wav",
             "nb_ta",
             "nb_tc",
             "dif_wav_ta",
             "pourc_dif",
             "trait_fin",
             "detecteur_enregistreur_numero_serie",
             "canal_expansion_temps",
             "canal_enregistrement_direct",
             "micro0_numero_serie",
             "micro1_numero_serie",
             "commentaire")
Sys.time()
DataLP_RP[,(ListePurge):=NULL]
Sys.time()

Sys.time()
fwrite(DataLP_RP,"DataLP_RP.csv",row.names=F) # 1 sec
Sys.time()
#DataLP_R=subset(DataLP_RP,grepl("Routier",DataLP_RP$site))
#DataLP_P=subset(DataLP_RP,!grepl("Routier",DataLP_RP$site))

#fwrite(DataLP_R,"DataLP_R.csv",row.names=F) # 1 sec
#fwrite(DataLP_P,"DataLP_P.csv",row.names=F) # 1 sec
