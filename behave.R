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
library(data.table)

main <-function(){
 #l <- genStats('behave/all_beares.csv')

 # update all behave
 # writeBigCSV()
 big <- read.table('behave/all_beares.csv')
 dosomestats_sm(big,header=T,sep=",")
 switchdiff(big)
}

readBehave <- function(csvfile) {
   # read in from output of behave.m matlab script to parse *.mat
   # ... should be the csv file dumped out after a successful run

   # seqCrct,seqRT,pushed,crctKey,tt,is_switch,is_probe,sequence
   tryCatch({
    bhd<-read.table(csvfile,header=T,sep=",")
   },error=function(e){
    cat(csvfile,'is probably corrupt!',e$message,'\n')
    return(NULL)
   })


   # add subj block and start time to dataframe
   splits <- strsplit(gsub('.csv','',basename(csvfile)), '_' )
   bhd$subj  <- sapply(splits,'[',1)
   bhd$block <- sapply(splits,'[',2)
   bhd$sttime <- sapply(splits,'[',3)

   # Behave, MR, or MEG?
   bhd$visittype <- gsub('/','',regmatches(csvfile,regexpr('/(Behave|MEG|MR)/',csvfile)))

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
writeBigCSV <-function( pattern='/mnt/B/bea_res/Data/Tasks/Switch_MMY4/*/*/*/1*_[^-]*_[0-9]*.csv',outname="behave/all_beares.csv"){
   allcsvfiles <- Sys.glob(pattern);
   cat("num ", pattern ," to read: ", length(allcsvfiles), "\n")
   # with ddplyr
   big <- adply(allcsvfiles,1,readBehave )
   big <- big[,-1] # remove "X1" from adply

   # with dplyr (20170307)
   #bigl <- lapply(allcsvfiles,FUN=readBehave)
   

   #WF20150112 -- this exists in matlab exported csv already!
   # define if this trial is a new miniblock
   # ie. this trial is a switch
   #difftt <- c(0,diff(big$tt))!=0 
   #diffblk<- c(0,diff(as.numeric(big$sttime)) ) !=0 
   #big$is_switch <- 0
   #big$is_switch[ difftt & !diffblk ] <- 1
   big <- getDBinfo(big)
   big$age <- as.numeric( difftime( lubridate::ymd( substr(big$sttime,0,8) ) ,as.Date(big$dob) ) )/365.25
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
 d %>% group_by(id,block) %>% mutate(sinceswitch=countseq0(is_switch)) %>%
       mutate(prev=lag(trial.type))
   
}

plotRTbyblock <-function(d) {
  
  # get switch block labels, since switch counts
  # and remove incorrect and probe trials
  d<-RTbyblock(d)  %>%
     dplyr::filter(seqCrct==1,is_probe != 1 || is.na(is_probe) )

  # get mean rt for each trial.type in pure
  d.pure <- d %>% 
     dplyr::filter(blocktype=='pure') %>%
     #group_by(id,trial.type) %>% 
     #summarise(RT=mean(seqRT) ) %>%
     #group_by(trial.type) %>% 
     #summarise(RT.sd=sd(RT),RT.m=mean(RT))
     group_by(trial.type) %>% 
     summarise(RT.sd=sd(seqRT),RT.m=mean(seqRT))

  # get mean rt for each n-since switch in each trial.type during switch
  d.switch <- d %>% 
     dplyr::filter(sinceswitch<=6,blocktype=='switch') %>%
     group_by(id,sinceswitch,trial.type) %>% 
     summarise(RT=mean(seqRT) )

  p<-ggplot( d.switch ) +
    aes(x=as.factor(sinceswitch),y=RT) +   #,color=blocktype)+
    geom_boxplot(position='dodge',alpha=.5) +
    geom_smooth(aes(x=sinceswitch+1))+       #,method='lm') +
    #geom_rect(data=d.pure,aes(ymin=RT.m-RT.sd, ymax=RT.m+RT.sd,xmin=-Inf,xmax=+Inf,x=NULL,y=NULL),alpha=.2) +
    geom_hline(data=d.pure,aes(yintercept=RT.m),linetype='dotted',color='red')+ 
    facet_wrap(~trial.type) + theme_bw() +
    xlab('Trials since a switch')
  p
}

# merge data with dob, missing 8 subjects
getDBinfo <- function(d) {
  lunaids <- unique(d$subj)
  con <- DBI::dbConnect(RPostgreSQL::PostgreSQL(),host='arnold.wpic.upmc.edu', 'lncddb',user='postgres',password='')
  query <- sprintf("
   select id,sex,dob 
   from person p 
   join enroll e on e.pid=p.pid and etype like 'LunaID' 
   where id in (%s)",
   paste(sprintf("'%s'",lunaids),sep=",",collapse=","))

  dt<-DBI::dbGetQuery(con,query)
  withDB<-merge(dt,d,by.x='id',by.y='subj',all.y=T)

  return(withDB)
}


trnfrm <-function(d) {
 d %>% mutate(RTlog = log(seqRT), 
               ageC = age - mean(age),
           invAgeC = 1/age - mean(1/age))

# d.so <- big %>% dplyr::filter(is_switch==1) %>% trnfrm
}

pureSwitchInfo <- function(d) {
  # and remove incorrect and probe trials
  d<-RTbyblock(d)  %>%
     dplyr::filter(seqCrct==1,is_probe != 1 || is.na(is_probe) )

  # get mean rt for each trial.type in pure
  d.pure <- d %>% 
     dplyr::filter(blocktype=='pure') %>%
     #group_by(id,trial.type) %>% 
     #summarise(RT=mean(seqRT) ) %>%
     #group_by(trial.type) %>% 
     #summarise(RT.sd=sd(RT),RT.m=mean(RT))
     group_by(trial.type) %>% 
     summarise(RT.sd=sd(seqRT),RT.m=mean(seqRT))

  # get mean rt for each n-since switch in each trial.type during switch
  d.switch <- d %>% 
     dplyr::filter(sinceswitch<=6,blocktype=='switch') %>%
     group_by(id,sinceswitch,trial.type) %>% 
     summarise(RT=mean(seqRT) )

 browser()
}

dosomestats_sm <- function(big) {
 # intf variance on correct switch trials predicts logRT
 d.so <- big %>% dplyr::filter(is_switch==1) %>% trnfrm
 d.so.acc <- d.so %>% 
             group_by(id,invAgeC,age,ageC,trial.type)%>%
             summarise(acc=length(which(seqCrct==1))/n()*100) #%>%
             #dplyr::filter(acc>33 ) # , !(acc<40&age>20) ) 

 # inv age p .0138
 accintf <- d.so.acc%>% dplyr::filter(trial.type=='intf')
 m.acc <- lm(data=accintf, acc ~ invAgeC )
 summary(m.acc)
 accintf$pred = predict(m.acc,accintf) 
 p<-ggplot(accintf ) + aes(x=age,y=acc) + 
   geom_point() + 
   geom_line(aes(y=pred),color='red') + 
   theme_bw() 
 ggsave(LNCDR::lunaize(p), file="MMY4_acc_p.0318.png")


 d.so.var <- d.so %>% 
             dplyr::filter(seqCrct==1)%>%
             group_by(id,ageC,age,invAgeC,trial.type) %>%
             summarise(RTlogvar =var(RTlog), mRTlog = mean(RTlog), mRT=mean(seqRT)  )

 # invAge almost sig, age is not close
 m.lin <- lm(data=d.so.var %>% dplyr::filter(trial.type=='intf'), mRTlog ~ invAgeC )
 summary(m.lin)

 ## look at cngr as baseline (sub motor comp)
 d.m <- d.so.var %>% select(-RTlogvar,-mRTlog) %>%  spread(trial.type,mRT) %>% 
        mutate(m.diff = intf - cngr)

 m.diffm <- lm(data=d.m, m.diff ~ invAgeC)
 summary(m.diffm)


}



dosomestats <- function(big) {

  d.switch <-  big %>% trnfrm %>% RTbyblock %>% filter(seqCrct==1)
  d.switch$invSwitch <- 1/(1+d.switch$sinceswitch)

  m1<-lmer( RTlog~trial.type*sinceswitch+(1|id) , data= d.switch )
  m2<-lmer( RTlog~trial.type*invSwitch  +(1|id) , data= d.switch )
  car::Anova(m1)
  car::Anova(m2)
  est2<-lsmeans::lstrends(m2,~trial_type,var="invSwitch")
  pairs(est2,joint=TRUE,adjust="mvt")
  AIC(m2)

}


undolink <- function(b,x) { 1/(1+exp(-(b*x) )) }

statsnotrunyet <- function(d.so) {
  m <- glmer(data= d.so %>% dplyr::filter(seqCrct>=0) ,seqCrct ~ age + (1|id), family='binomial')
  # undo link function coeffs
  # 1/(1+exp(-(B*X) ))
  summary(m)
  car::Anova(m)
  plot(m)
  
}

### nonswitch - switch for switch cost
# big is output of writeBigCSV  (or read in)
switchdiff <- function(big) {
 # label pure/switch, transform age and RT
 # add labels to is_switch and make score out of seqCrct
 d <- big %>% 
      trnfrm %>% 
      RTbyblock %>%
      mutate(is_switch = ifelse(is_switch==1,'switch','repeat'),
             score     = cut(seqCrct, breaks=c(-Inf,-1,0,1),labels=c('drop','wrong','correct'))  ) 

 s <- d %>% 
      # we want only switch blocks, maybe we want to limit the mid range (1..2) sinceswitch too?
      filter(blocktype=='switch',sinceswitch==0|sinceswitch>=2,
      # only want to look at interfirence
             trial.type=='intf'
       #maybe only want switch when nbk to intf
             ,sinceswitch>0|prev=='cngr'
       ) %>%
       group_by(id,age,sex,visittype,invAgeC,is_switch,score) %>%
      summarise(mRTl = mean(RTlog),n=n() )

 s.long <- dcast(setDT(s), id+invAgeC+age+visittype+sex~is_switch+score,value.var=c('n','mRTl') ) %>% 
           mutate(mRTl_sdiff = mRTl_switch_correct - mRTl_repeat_correct )
 

 m.sdiff <- lm(data=s.long,mRTl_sdiff~invAgeC)
 print(summary(m.sdiff))

 # get total trials per visit
 s.long$nt.switch <- apply(as.data.frame(s.long)[,grep('n_switch',names(s.long))],1,sum,na.rm=T)
 s.long$nt.repeat <- apply(as.data.frame(s.long)[,grep('n_rep',names(s.long))],1,sum,na.rm=T)
 s.long$acc.switch <-  s.long$n_switch_correct/s.long$nt.switch
 s.long$acc.repeat <-  s.long$n_repeat_correct/s.long$nt.repeat
 s.long$accdiff   <- s.long$acc.switch  - s.long$acc.repeat


 print(summary(m.accsdiff <- lm(data=s.long,accdiff~invAgeC)))
}


# WF 20170307 (SM)
# cost of switch vs dev. from pure RT  (correct only)
#  calcualte miniblock averages
# pureavg    = avg of trial 2 to 11
# switchavg  = avg of 3 out and more from switch  
#  to calculate summary stats 
# switchCost = switchavg - pureavg
# delta      = switch trial RT - switchavg

switchCost <-function(d) {
  # d might look like
  # d<-big %>% dplyr::filter(visittype == 'MEG') %>% RTbyblock %>% dplyr::filter(trial.type=='intf')

  # loose 11406 b/c no pure intf block?
  d.wPRT <- 
   d %>% 
   dplyr::filter(blocktype=='pure',seqCrct==1,trial>1,trial<=11) %>% 
   group_by(id,trial.type) %>% 
   summarise(pureAvgRT=mean(seqRT,na.rm=T)) %>% 
   merge(d,by=c('id','trial.type'))
   
 d.deltaPostSwitch <- 
   d.wPRT %>% 
   dplyr::filter(blocktype=='switch',seqCrct==1) %>% 
   mutate(miniblockpos=cut(sinceswitch,c(-Inf,0,2,Inf),c('switchRT','junk','postswitchRT'))) %>%  
   dplyr::filter(miniblockpos!='junk') %>% 
   group_by(id,trial.type,miniblockpos,pureAvgRT) %>% 
   summarise(switchAvgRT=mean(seqRT,na.rm=T)) %>% 
   spread(miniblockpos,switchAvgRT) %>% 
   mutate(switchCost = switchRT - postswitchRT, delta=postswitchRT - pureAvgRT)
 
 # outlier removeal
 d.dps <- d.deltaPostSwitch %>% dplyr::filter(delta>-.1)
 
 keepsubj <- read.table(sep=",",'/Volumes/Zeus/MEGSubjectList.csv') %>% `colnames<-`(c('id','age'))
 d.dps <- merge(d.deltaPostSwitch ,keepsubj,by='id')

 p<-
  ggplot(d.dps) +
  aes(x=switchCost,y=delta) +
  geom_point() +
  geom_smooth(method='lm')
 print(p)

 write.table(file='txt/SM_switchCostDelta_MEG44int.csv',sep=",",quote=F,row.names=F,col.names=F,
     d.dps %>% select(id,pureAvgRT,switchRT,postswitchRT,switchCost,delta,age))
}

