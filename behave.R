library(ggplot2)
library(plyr)
readBehave <- function(csvfile) {
   bhd<-read.table(csvfile,header=F,sep=",")
   names(bhd)<-c('crct','RT','pushedkey','crctkey','tt','is.switch','is.probe')
   bhd$tt_l   <- factor( bhd$tt, levels=c("2","3","1"), labels=c("intf","cngr","nbk"))
   bhd$crct_l <- factor( bhd$crct, levels=c("-1","0","1"), labels=c("noresp","wrong","correct"))

   # colorDict=c('inft'=1,'cngr'=2,'nbk'=3)
   # bhd$ttl <- reorder( bhd$ttl, colorDict[bhd$ttl] )
   bhd$trial <- 1:nrow(bhd)
   return(bhd)
}
plotBehave <-function(bhd) {
 ggplot(bhd,aes(x=trial,y=RT,color=tt_l,shape=crct_l ) )+geom_point()+theme_bw()
}
#bhd<-readBehave('DM_4.csv')

bhd<-readBehave('behave/SOPH_4.csv')
plotBehave(bhd)
