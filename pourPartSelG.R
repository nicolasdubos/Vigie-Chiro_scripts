library(data.table)
#r�cup�ration des donn�es participation
Particip=fread("C:/wamp64/www/p_export.csv")
#r�cup�ration des localit�s
SiteLoc=fread("C:/wamp64/www/sites_localites.txt")


#liste des coordonn�es existantes dans ce jeu de donn�es
PartPF=subset(Particip,grepl("Fixe",Particip$site))
SelParSL=merge(SiteLoc,PartPF,by.x=c("site","nom"),by.y=c("site","point"))

SelParSL$Mois=as.numeric(substr(SelParSL$date_debut,4,5))

fwrite(SelParSL,"PartSelG.csv")
