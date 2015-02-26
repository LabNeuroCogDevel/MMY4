###Multimodal year 4 pilot data###########
library(tidyr)
library(dplyr)
library(zoo)
library(lme4)
library(ggplot2)

pilotdata<-read.csv("all-behavepilot_n7.csv",header=TRUE)

pdat <- pilotdata %>%
        # only block 4 has switches
        filter(block==4) %>%
        group_by(subj) %>%
        # want to have trials since switch 
        mutate( sinceSwitch = trial - na.locf(na.rm=F,ifelse(is.switch,1,NA) * trial) +1) %>%
        mutate(invswitch = 1/sinceSwitch ) %>%
        # discard first trials before any switch and any missed trial
        filter(!is.na(sinceSwitch) & sinceSwitch>0 & is.finite(seqRT) ) #& response.type=='correct') 


# plot accuracy
acc <- pdat %>% group_by(subj,block,tt) %>% summarise( acc=sum(seqCrct==1)/n() ) #%>% ggplot(aes(x=tt,y=acc,color=subj)) + geom <- point()
p<-ggplot(acc,aes(x=tt,y=acc,color=subj)) #+ geom_bar()

pdat.correct <- pdat %>% filter(response.type=='correct')

# exp dist mini block lengths, too few with 5 or more since switch
p5 <- pdat.correct %>% filter(sinceSwitch<5 )



m.inv <- lmer(seqRT~ invswitch   + (subj|invswitch), data=pdat.correct)
m.lin <- lmer(seqRT~ sinceSwitch + (subj|invswitch), data=pdat.correct)



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

gp <- ggplot(p5%>%filter(is.na(is_probe) || is_probe==1),aes(x=sinceSwitch,y=seqRT,fill=trial.type)) +
      geom_boxplot(aes(group=paste(trial.type,sinceSwitch)))  +
       #geom_point(aes(shape=as.factor(is_probe)),alpha=.4) +
      facet_wrap(~subj) +
      theme_bw()
print(gp)


