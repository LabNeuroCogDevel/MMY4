library(ggplot2)
library(plyr)
readBehave <- function(csvfile) {
   bhd<-read.table(csvfile,header=T,sep=",")

   bhd$subj.blk <- gsub('.csv','',basename(csvfile))

   # seqCrct,seqRT,pushed,crctKey,tt,is_switch,is_probe,sequence

   # want to use ggplot colors, want inft as red, cngr as green, nbk as blue
   bhd$trial.type   <- factor( bhd$tt, levels=c("2","3","1"), labels=c("intf","cngr","nbk"))

   # want to have meaningful labels on response type
   bhd$response.type <- factor( bhd$seqCrct, levels=c("-1","0","1"), labels=c("noresp","wrong","correct"))

   bhd$trial <- 1:nrow(bhd)

   return(bhd)
}

plotBehave <-function(bhd) {
 bhd$RT<-bhd$seqRT
 bhd$RT[is.infinite(bhd$seqRT)] <-  -.1
 prb   <- bhd[ !is.na(bhd$is_probe) & bhd$is_probe==1, ]
 swtch <- bhd[ c(0, diff(bhd$tt) ) != 0 , ]

 p <- ggplot(bhd,
    aes(x    = trial,
        y    = RT,
        color= trial.type,
        shape= response.type) )+
    geom_point()+
    theme_bw() + 
    ggtitle("RT and response for block") +
    ylab('RT (s)') + 
    xlab('Trial #')  
 
 # annotate probes
 if(nrow(swtch)>0){
  p<-p+ 
    annotate("point",x=prb$trial,y=prb$RT,shape=1,size=4) 
 }

 # annotate switches
 if(nrow(swtch)>0){
  p<-p+ geom_vline(xintercept=swtch$trial,alpha=.3) 
 }

 return(p)
    #annotate("point",x=swtch$trial,y=swtch$RT,shape=2,size=4) +
}

writeBigPdf <-function(){
   print("writing large pdf file to behave/behave.pdf")
   pdf('behave/behave.pdf',width=10,height=10/4.2,onefile=T)
   for(csv in Sys.glob('behave/csv/*csv')) {
      cn<-gsub('.csv','',basename(csv))
      bhd<-readBehave(csv)
      p<-plotBehave(bhd)+
       ggtitle(paste(sep="","RT+Resp for Block ",gsub('_',' ',cn)));
      
      print(p)
   }
   dev.off()
}

writeBigCSV <-function(outname="behave/all.csv"){
   big <- adply(Sys.glob('behave/csv/*csv'),1,readBehave )
   big <- big[,-1] # remove "X1" from adply
   write.table(big,file=outname,sep=",",row.names=F)
}
