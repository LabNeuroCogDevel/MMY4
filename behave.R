# USAGE:
# source('behave.R')
# # read in all csvs in bea_res MMY4_Switch behave
# writeBigCSV(outname="behave/all-behavepilot.csv")
# # run some stats, make a pretty plot
# l<-genStats("behave/all-behavepilot.csv")
# # save the plot
# ggsave(l$plot,'behave/plot.png')
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
#writeBigCSV <-function( pattern='behave/csv/*csv',outname="behave/all.csv"){
# /mnt/B/bea_res/Data/Tasks/Switch_MMY4/Behave/11346/20150805/
writeBigCSV <-function( pattern='/mnt/B/bea_res/Data/Tasks/Switch_MMY4/Behave/*/*/1*_[^-]*_[0-9]*.csv',outname="behave/all_beares_behave.csv"){
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
   return(big)
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



countseq0 <- function(is.switch){
 count<-0; 
 unlist( lapply(is.switch,FUN=function(i){if(i==0){ count<<-count+1 }else{count<<-0} }) )
}

 # add pure/switch label, count trials since switch
RTbyblock <- function(d) {
 d$blocktype <- ifelse(d$block<4,'pure','switch') 
 d %>% group_by(subj,block) %>% mutate(sinceswitch=countseq0(is_switch))
}

plotRTbyblock <-function(d) {
  
  # get switch block labels, since switch counts
  # and remove incorrect and probe trials
  d<-RTbyblock(d)  %>%
     dplyr::filter(seqCrct==1,is_probe != 1 || is.na(is_probe) )

  # get mean rt for each trial.type in pure
  d.pure <- d %>% 
     dplyr::filter(blocktype=='pure') %>%
     #group_by(subj,trial.type) %>% 
     #summarise(RT=mean(seqRT) ) %>%
     #group_by(trial.type) %>% 
     #summarise(RT.sd=sd(RT),RT.m=mean(RT))
     group_by(trial.type) %>% 
     summarise(RT.sd=sd(seqRT),RT.m=mean(seqRT))

  # get mean rt for each n-since switch in each trial.type during switch
  d.switch <- d %>% 
     dplyr::filter(sinceswitch<=6,blocktype=='switch') %>%
     group_by(subj,sinceswitch,trial.type) %>% 
     summarise(RT=mean(seqRT) )

  p<-ggplot( d.switch ) +
    aes(x=as.factor(sinceswitch),y=RT) +   #,color=blocktype)+
    geom_boxplot(position='dodge',alpha=.5) +
    geom_smooth(aes(x=sinceswitch))+       #,method='lm') +
    geom_rect(data=d.pure,aes(ymin=RT.m-RT.sd, ymax=RT.m+RT.sd,xmin=-Inf,xmax=+Inf,x=NULL,y=NULL),alpha=.2) +
    geom_hline(data=d.pure,aes(yintercept=RT.m),linetype='dotted',color='red')+ 
    facet_wrap(~trial.type) + theme_bw()
  browser()
  p
}

# merge data with dob, missing 8 subjects
getDBinfo <- function(d) {
  lunaids <- unique(d$subj)
  con <- DBI::dbConnect(RPostgreSQL::PostgreSQL(),host='localhost', 'lncddb',user='postgres',password='')
  query <- paste0("select id,sex,dob from person p join enroll e on e.pid=p.pid and etype like 'LunaID' where id in (",
                  paste(sprintf("'%d'",lunaids),sep=",",collapse=","), ')')
  dt<-dbGetQuery(con,query)
  merge(dt,d,by.x='id',by.y='subj',all=T)
}

dosomestats <- function(d) {

  d.switch$inv <- 1/(1+d.switch$sinceswitch)
  m1<-lmer( seqRT_log~trial_type*sinceswitch+(1|subj) , data= d.switch )
  m2<-lmer( seqRT_log~trial_type*inv+(1|subj) , data= d.switch )
  car::Anova(m1)
  est2<-lstrends(m2,~trial_type,var="inv")
  pairs(est2,joint=TRUE,adjust="mvt")
  AIC(m2)



}
