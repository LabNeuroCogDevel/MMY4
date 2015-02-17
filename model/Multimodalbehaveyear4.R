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
        filter(!is.na(sinceSwitch) & sinceSwitch>0 & is.finite(seqRT))  #& response.type=='correct') 
        
# exp dist mini block lengths, too few with 5 or more since switch
p5 <- pdat %>% filter(sinceSwitch<5 )



m.inv <- lmer(seqRT~ invswitch + (subj|invswitch), data=pdat)
m.lin <- lmer(seqRT~ sinceSwitch + (subj|invswitch), data=pdat)

m5.inv <- lmer(seqRT~ invswitch + (subj|invswitch), data=p5)
m5.lin <- lmer(seqRT~ sinceSwitch + (subj|invswitch), data=p5)

print(AIC(m.inv,m.lin,m5.lin,m5.inv) )

print(car::Anova(m))

gp <- ggplot(pdat,aes(x=sinceSwitch,y=seqRT)) +
      geom_boxplot(aes(group=sinceSwitch))  +
      geom_jitter(aes(color=subj),alpha=.4) +
      facet_wrap(~subj) +
      theme_bw()
print(gp)


