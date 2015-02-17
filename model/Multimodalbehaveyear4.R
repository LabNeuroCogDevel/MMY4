###Multimodal year 4 pilot data###########
library(tidyr)
library(dplyr)
library(zoo)
library(lme4)

pilotdata<-read.csv("all-behavepilot_n7.csv",header=TRUE)

pdat <- pilotdata %>%
        # only block 4 has switches
        filter(block==4) %>%
        group_by(subj) %>%
        # want to have trials since switch 
        mutate( sinceSwitch = trial - na.locf(na.rm=F,ifelse(is.switch,1,NA) * trial) +1) %>%
        filter(!is.na(sinceSwitch)) %>% ungroup

m <- lmer(seqRT~trial.type + (1|subj), data=pdat)

