# source('behave.R')
# writeBigCSV(outname="behave/all-behavepilot.csv")
# l<-genStats("behave/all-behavepilot.csv")
#
library(ggplot2)
library(plyr)
library(reshape2)
readBehave <- function(csvfile) {
   # read in from output of behave.m matlab script to parse *.mat
   # ... should be the csv file dumped out after a successful run

   # seqCrct,seqRT,pushed,crctKey,tt,is_switch,is_probe,sequence
   bhd<-read.table(csvfile,header=T,sep=",")

   # add subj block and start time to dataframe
   splits <- strsplit(gsub('.csv','',basename(csvfile)), '_' )
   bhd$subj  <- sapply(splits,'[',1)
   bhd$block <- sapply(splits,'[',2)
   bhd$sttime <- sapply(splits,'[',3)


   # want to use ggplot colors, want inft as red, cngr as green, nbk as blue
   bhd$trial.type   <- factor( bhd$tt, levels=c("2","3","1"), labels=c("intf","cngr","nbk"))

   # want to have meaningful labels on response type
   bhd$response.type <- factor( bhd$seqCrct, levels=c("-1","0","1"), labels=c("noresp","wrong","correct"))

   # good to have trial numbers
   bhd$trial <- 1:nrow(bhd)

   return(bhd)
}


# 
# plot RT against trial number
# color by trial type
# use shape to indicate response type (correct, incorrect)
# put circles around nback probes during working memory
# TODO: put shapes around congruent trials within interfence blocks

plotBehave <-function(bhd) {
 bhd$RT<-bhd$seqRT
 bhd$RT[is.infinite(bhd$seqRT)] <-  -.1
 # where is there a nback probe (in nback/WM trials)
 prb   <- bhd[ !is.na(bhd$is_probe) & bhd$is_probe==1, ]
 # where is there a switch from one block type to another
 swtch <- bhd[ c(0, diff(bhd$tt) ) != 0 , ]
 # where do we have congruent inside an interference block
 # congInf <- bhd[ ?? , ]

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

 #if(nrow(congInf)>0){
 # p<-p+ 
 #   annotate("point",x=prb$trial,y=prb$RT,shape=2,size=4) 
 #}

 # annotate switches
 if(nrow(swtch)>0){
  p<-p+ geom_vline(xintercept=swtch$trial,alpha=.3) 
  #annotate("point",x=swtch$trial,y=swtch$RT,shape=2,size=4) +
 }

 return(p)
}

# for each csv matching pattern, make a graph as a page in the pdf "outname"
writeBigPdf <-function(pattern='behave/csv/*csv',outname="behave/behave.pdf"){
   print("writing large pdf file to behave/behave.pdf")
   pdf(outname,width=10,height=10/4.2,onefile=T)
   for(csv in Sys.glob(pattern)) {
      cn<-gsub('.csv','',basename(csv))
      bhd<-readBehave(csv)
      p<-plotBehave(bhd)+
       ggtitle(paste(sep="","RT+Resp for Block ",gsub('_',' ',cn)));
      
      print(p)
   }
   dev.off()
}

# reads in all the csv files and matching pattern and writes them to outname
writeBigCSV <-function( pattern='behave/csv/*csv',outname="behave/all.csv"){
   allcsvfiles <- Sys.glob(pattern);
   cat("num ", pattern ," to read: ", length(allcsvfiles), "\n")
   big <- adply(allcsvfiles,1,readBehave )
   big <- big[,-1] # remove "X1" from adply

   #WF20150112 -- this exists in matlab exported csv already!
   # define if this trial is a new miniblock
   # ie. this trial is a switch
   #difftt <- c(0,diff(big$tt))!=0 
   #diffblk<- c(0,diff(as.numeric(big$sttime)) ) !=0 
   #big$is_switch <- 0
   #big$is_switch[ difftt & !diffblk ] <- 1

   write.table(big,file=outname,sep=",",row.names=F)
}


genStats <- function(csvf="behave/all.csv") {
  # get all the data, but ignore noresp
  bigall <- read.table(csvf,sep=",",header=T)
  big <- subset(bigall,response.type!='noresp')

  big$is_switch   <- factor( big$is_switch, levels=c("0","1"), labels=c("consecutive","switch"))
  # graph
  p <- ggplot(big,aes(y=seqRT,x=trial.type,color=subj)) +
        geom_boxplot() +
        facet_grid(block~is_switch+response.type) +
        theme_bw() + 
        ggtitle('RT per trialtype, colored by subj')

  # stats of the bar plot
  s <- ddply( bigall, .(trial.type, block, response.type, subj,is_switch), function(x) {
    c(RT=mean(x$seqRT),
      n=nrow(x),
      sd=sd(x$seqRT)
    )
  })

  s.switch <- reshape(subset(s,block==4),direction="wide",idvar=c("trial.type",'block','response.type','subj'),timevar='is_switch')

  print(s)
  print(p)
  return(list(plot=p,s=s,s.switch=s.switch))
}

