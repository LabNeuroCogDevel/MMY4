source('behave.R')
#install.packages('lme4')
#install.packages('zoo')
library(ggplot2)
library(magrittr)
library(dplyr)
library(tidyr)
library(zoo)
library(lme4)


# df.all <- writeBigCSV()
# load in all data and get rid of MR
df.all <- read.csv('behave/all_beares.csv') %>% 
          dplyr::filter(visittype != 'MR')

# making data frame smaller by selecting specific columns
bhv <- df.all %>% select(id,sex,age,response.type,seqRT,is_switch,is_probe,trial,block,visittype,trial.type)

bhv$switch <- as.factor(bhv$is_switch)
bhv.small <- bhv %>% dplyr::filter( id %in% c(10142,10662) )
acc=length(which(response.type=='correct'))/n()


bhv.idvstat <- bhv %>%  
  group_by(id,trial.type,switch,is_probe,age) %>%
  summarize(subjmRT=mean(seqRT[response.type=='correct']), 
            subjAcc=length(which(response.type=='correct'))/n() )

bhv.popstat <- bhv.idvstat %>%
   ungroup()%>% group_by(trial.type,switch,is_probe,age)%>%
   summarize(stderrormean=sd(subjmRT)/sqrt(n()),
            meanmean=mean(subjmRT),
            stderrorAcc=sd(subjAcc)/sqrt(n()),
            meanAcc=mean(subjAcc)
   )

# rename NA as 0 in order to plot 
bhv.popstat$is_probe[ is.na(bhv.popstat$is_probe) ] <- 0

# combine probe and switch into one variable for coloring
bhv.popstat %<>% ungroup() %>%
  mutate(switchtext=ifelse(switch==0,'no switch','switch'),
         switchProbe=paste(switchtext, ifelse(is_probe==0,'','probe')))             

# does the same thing
bhv.popstat$switchtext=ifelse(bhv.popstat$switch==0,'no switch','switch')
bhv.popstat$switchProbe=paste(bhv.popstat$switchtext, ifelse(bhv.popstat$is_probe==0,'','probe'))             




p.RTbox <- ggplot(bhv.idvstat) +
  aes(y=subjmRT,x=trial.type,fill=switch) +
  geom_boxplot() +
  theme_bw()
print(p.RTbox)

#box plot for Acc
p.AccBox <- ggplot(bhv.idvstat) +
  aes(y=subjAcc,x=trial.type,fill=switch) +
  geom_boxplot() + 
  theme_bw()
print(p.AccBox)

#bar grpah meanRT
p.mRTbar <- ggplot(bhv.popstat) +
  aes(y=meanmean,
      x=trial.type,
      fill=switchProbe,
      ymin=meanmean-stderrormean,
      ymax=meanmean+stderrormean) +
  geom_bar(stat='identity',position='dodge') +
  geom_errorbar( position=position_dodge(.9),color='black',width=.25 ) +
  theme_bw() +
  scale_color_manual(values=c("red","blue")) +
  ggtitle('Task Switching Effects') + ylab('mean RT') + xlab('trial type')
print(p.mRTbar)

p.Accbar <- ggplot(bhv.popstat) +
  aes(y=meanAcc,
      x=trial.type,
      fill=switchProbe,
      ymin=meanAcc-stderrorAcc,
      ymax=meanAcc+stderrorAcc) +
  geom_bar(stat='identity',position='dodge') +
  geom_errorbar( position=position_dodge(.9),color='black',width=.25 ) +
  theme_bw() +
  scale_color_manual(values=c("red","blue")) +
  ggtitle('Task Switching Effects') + ylab('mean Acc') + xlab('trial type')
print(p.Accbar)

ggsave(p.Accbar,'Acc_barplot.pdf')

plot(age, subjmRT)

########################################3

pdat <- bhv %>%
  # only block 4 has switches
  filter(block>=4) %>%
  group_by(id) %>%
  # want to have trials since switch 
  mutate( sinceSwitch = trial - na.locf(na.rm=F,ifelse(is_switch,1,NA) * trial) +1) %>%
  mutate(invswitch = 1/sinceSwitch ) %>%
  # discard first trials before any switch and any missed trial
  filter(!is.na(sinceSwitch) & sinceSwitch>0 & is.finite(seqRT) ) #& response.type=='correct') 


# plot accuracy
acc <- pdat %>% group_by(id,block,trial.type) %>% summarise( acc=sum(response.type=='correct')/n() ) #%>% ggplot(aes(x=tt,y=acc,color=subj)) + geom <- point()
p<-ggplot(acc,aes(x=trial.type,y=acc,color=id)) + geom_point()

pdat.correct <- pdat %>% filter(response.type=='correct')

# exp dist mini block lengths, too few with 5 or more since switch
p5 <- pdat.correct %>% filter(sinceSwitch<5 )



m.inv <- lmer(seqRT~ invswitch   + (id|invswitch), data=pdat.correct)
m.lin <- lmer(seqRT~ sinceSwitch + (id|invswitch), data=pdat.correct)



# look at response type (correct, wrong) # also have noresp, but no RT for that
# fails to converge :(
#   cpc.inv <- glmer(response.type ~ invswitch + (subj|invswitch),     family='binomial', data=pdat)
#   cpc.lin <- glmer(response.type ~ sinceSwitch + (subj|sinceSwitch), family='binomial', data=pdat)

# t for each model (3rd coef in summary)
tstat<-lapply(list(m.inv,m.lin,m5.inv,m5.lin),  function(x) summary(x)$coefficients[2,3] )
names(tstat) <- c('m.inv','m.lin','m5.inv','m5.lin')
print(unlist(tstat))


print(AIC(m.inv,m.lin,m5.lin,m5.inv) )

print(car::Anova(m.inv))
gp.filter<-p5%>%ungroup()%>%filter(is.na(is_probe) || is_probe==0 )
gp <- ggplot(gp.filter) +
  aes(x=sinceSwitch,y=seqRT,group=trial.type,fill=trial.type,color=trial.type) + #, group=paste(trial.type,sinceSwitch)) +
  geom_smooth(method='loess')  +
  #geom_point(aes(shape=as.factor(is_probe)),alpha=.4) +
  #facet_wrap(~id) +
  theme_bw()
print(gp)
