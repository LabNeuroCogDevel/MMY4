library(ggplot2)
library(plyr)
readBehave <- function(csvfile) {
   bhd<-read.table(csvfile,header=F,sep=",")
   names(bhd)<-c('crct','RT','pushedkey','crctkey','tt','is.switch','is.probe')
   bhd$ttl <- factor( bhd$tt, levels=c("2","3","1"), labels=c("intf","cngr","nbk"))

   # colorDict=c('inft'=1,'cngr'=2,'nbk'=3)
   # bhd$ttl <- reorder( bhd$ttl, colorDict[bhd$ttl] )
   bhd$trial <- 1:nrow(bhd)
   return(bhd)
}
plotBehave <-function(bhd) {
 ggplot(bhd,aes(x=trial,y=RT,color=ttl,shape=as.factor(crct) ) )+geom_point()+theme_bw()
}
bhd<-readBehave('DM_4.csv')

bhd<-readBehave('behave/SOPH_4.csv')
plotBehave(bhd)
