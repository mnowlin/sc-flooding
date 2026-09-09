## load data with recodes 
# source("~/Thesis/scripts/setup.R")

library(dplyr)
library(ggplot2)

##load data
#scFloodData <- read.csv("data/SC Statewide Survey NUMBER.csv")
#source("~/Thesis/scripts/recodes.R")

source("scripts/recodes.R") # path for Matt 
names(scFloodData) # variable names 

library(gmodels) # for cross table

table(scFloodData$Q23)
table(scFloodData$ownHome, scFloodData$Q23)
table(scFloodData$ownHome, scFloodData$Q24)

chisq.test(table(scFloodData$ownHome, scFloodData$Q23))

CrossTable(scFloodData$ownHome, scFloodData$Q23, chisq = TRUE, format = "SPSS")
CrossTable(scFloodData$ownHome, scFloodData$Q24, chisq = TRUE, format = "SPSS")
help("CrossTable")


## thesis models and tables (note: if you want to recreate the tables you need to install the stargazer package)
summary(floodFrequencyOLS <- lm(floodF ~ currentComm+coastalCount+ideology+age+male+white+edu+inc, data = scFloodData)) 
# technically since there are only 3 values for the DV an ordered logit would be the appropriate model. but the results are similar (see below). you might get this question at the defense
summary(floodFrequencyOL <- MASS::polr(as.factor(floodF) ~ currentComm+coastalCount+ideology+age+male+white+edu+inc, 
                                       data = scFloodData, Hess = TRUE)) 
CI    <- confint(floodFrequencyOL)
TSTAT <- summary(floodFrequencyOL)$coef[1:nrow(CI), "t value"]
data.frame(
  AOR   = exp(floodFrequencyOL$coefficients),
  lower = exp(CI[,1]),
  upper = exp(CI[,2]),
  p     = 2*pnorm(abs(TSTAT), lower.tail = F)
)

stargazer::stargazer(floodFrequencyOLS, type = "html", title="OLS Analysis of Perceived Frequency of Flooding", 
                     align=TRUE, dep.var.labels = c("Flood Frequency"), 
                     covariate.labels = c("Time Lived in Current Community", "Coastal County", "Ideology (more conservative)", 
                                          "Age", "Gender (Male=1)","Race (white=1)","Education", "Income"), 
                     omit.stat=c("f","rsq","ll","ser"), star.cutoffs = c(0.05, 0.01, 0.001), out = "manuscript/floodFols.html")

summary(septicRainOLS <- lm(septicRain ~ coastalCount+commRel+scBridge+scBond+ideology+age+male+white+edu+inc, 
                            data = scFloodData)) 
summary(septicTideOLS <- lm(septicTide ~ coastalCount+commRel+scBridge+scBond+ideology+age+male+white+edu+inc, 
                            data = scFloodData)) 

stargazer::stargazer(septicRainOLS, septicTideOLS, type = "html", title="OLS Analysis of Septic Issues", 
                     align=TRUE, dep.var.labels = c("When it Rains", "During High Tide"), 
                     covariate.labels = c("Coastal County","Community Resilience","Bridging Social Capital", 
                                          "Bonding Social Capital","Ideology (more conservative)", 
                                          "Age","Gender (Male=1)","Race (white=1)","Education", "Income"), 
                     omit.stat=c("f","rsq","ll","ser"), star.cutoffs = c(0.05, 0.01, 0.001), out = "manuscript/septicIssuesols.html")

summary(septicMoveOLS <- lm(septicMove ~ currentComm+coastalCount+commRel+scBridge+scBond+ideology+age+male+white+edu+inc, 
                            data = scFloodData)) 

stargazer::stargazer(septicMoveOLS, type = "html", title="OLS Analysis of Moving Because of Septic Issues", 
                     align=TRUE, dep.var.labels = c("Move Septic"), 
                     covariate.labels = c("Time Lived in Current Community","Coastal County","Community Resilience",
                                          "Bridging Social Capital", 
                                          "Bonding Social Capital","Ideology (more conservative)", 
                                          "Age","Gender (Male=1)","Race (white=1)","Education", "Income"), 
                     omit.stat=c("f","rsq","ll","ser"), star.cutoffs = c(0.05, 0.01, 0.001), out = "manuscript/septicMoveols.html")

summary(supportPreModel <- lm(buyoutSupportPre ~ concernFlood+floodEx+septic+infraScale+commRel+coastalCount+scBridge+scBond+
                                ownHome+currentAdd+ideology+age+male+white+edu+inc, data = scFloodData))
                                
                                

stargazer::stargazer(supportPreModel, type = "html", title="OLS Analysis of Baseline Support for Property Buyout Program", 
                     align=TRUE, dep.var.labels = c("Buyout Support"), 
                     covariate.labels = c("Flooding Concern","Flooding Experience","On Septic",
                                          "Infrastructure Scale","Community Resilience","Coastal County",
                                          "Bridging Social Capital", 
                                          "Bonding Social Capital","Own Home","Time at Current Address",
                                          "Ideology (more conservative)", 
                                          "Age","Gender (Male=1)","Race (white=1)","Education", "Income"), 
                     omit.stat=c("f","rsq","ll","ser"), star.char = c("+", "*", "**", "***"),
                     star.cutoffs = c(0.1, 0.05, 0.01, 0.001),
                     notes = c("+ p<0.1; * p<0.05; ** p<0.01; *** p<0.001"), 
                     notes.append = F, out = "manuscript/supportPreModels.html")
                     
summary(moveModel <- lm(move ~ floodDays+concernFlood+floodEx+septic+infraScale+commRel+coastalCount+scBridge+scBond+
                                ownHome+currentAdd+ideology+age+male+white+edu+inc, data = scFloodData))

stargazer::stargazer(moveModel, type = "html", title="OLS Analysis of Likelihood to Move", 
                     align=TRUE, dep.var.labels = c("Move from Community"), 
                     covariate.labels = c("Hypothetical Flood Days","Flooding Concern","Flooding Experience","On Septic",
                                          "Infrastructure Scale","Community Resilience","Coastal County",
                                          "Bridging Social Capital", 
                                          "Bonding Social Capital","Own Home","Time at Current Address",
                                          "Ideology (more conservative)", 
                                          "Age","Gender (Male=1)","Race (white=1)","Education", "Income"), 
                     omit.stat=c("f","rsq","ll","ser"), star.char = c("+", "*", "**", "***"),
                     star.cutoffs = c(0.1, 0.05, 0.01, 0.001),
                     notes = c("+ p<0.1; * p<0.05; ** p<0.01; *** p<0.001"),
                     notes.append = F, out = "manuscript/moveModel.html")

summary(supportOwnModel <- lm(buyoutSupportOwn ~ floodDays+concernFlood+floodEx+septic+infraScale+commRel+coastalCount+scBridge+scBond+
                          currentAdd+ideology+age+male+white+edu+inc+buyoutSupportPre, data = scFloodData))
summary(supportRentModel <- lm(buyoutSupportRent ~ floodDays+concernFlood+floodEx+septic+infraScale+commRel+coastalCount+scBridge+scBond+
                                currentAdd+ideology+age+male+white+edu+inc+buyoutSupportPre, data = scFloodData))

stargazer::stargazer(supportOwnModel, supportRentModel, type = "html", 
                     title="OLS Analysis of Buyout Support Post-Hypothetical Number of Flood Days", 
                     align=TRUE, dep.var.labels = c("Homeowners","Renters"), 
                     covariate.labels = c("Hypothetical Flood Days","Flooding Concern","Flooding Experience","On Septic",
                                          "Infrastructure Scale","Community Resilience","Coastal County",
                                          "Bridging Social Capital", 
                                          "Bonding Social Capital", "Time at Current Address",
                                          "Ideology (more conservative)", 
                                          "Age","Gender (Male=1)","Race (white=1)","Education", "Income", "Baseline Buyout Support"), 
                     omit.stat=c("f","rsq","ll","ser"), 
                     star.char = c("+", "*", "**", "***"),
                     star.cutoffs = c(0.1, 0.05, 0.01, 0.001),
                     notes = c("+ p<0.1; * p<0.05; ** p<0.01; *** p<0.001"),
                     notes.append = F, out = "manuscript/supportPostModels.html")


## environmental concern measures 
scFloodData$concernBio <- as.numeric(scFloodData$Q1_1)-1
scFloodData$concernCC <- as.numeric(scFloodData$Q1_2)-1
scFloodData$concernSLR <- as.numeric(scFloodData$Q1_3)-1
scFloodData$concernWaterQ <- as.numeric(scFloodData$Q1_4)-1
scFloodData$concernFlood <- as.numeric(scFloodData$Q1_5)-1


#Lauren's Work

#Flooding
#Impact of length of residency and coastal residency on flood interruption for daily activities
floodDA<- lm(scFloodData$floodDA~ scFloodData$currentAdd+
               scFloodData$currentComm+
               scFloodData$coastalCount+scFloodData$inc+scFloodData$white+scFloodData$commRel1+scFloodData$commRel2+scFloodData$commRel3+scFloodData$commRel4)

summary(floodDA)
#Based on the summary data, length of residency(currentADD and currentComm) had a negative week correlation to flood impact on daily activities.
#However, coastal counties had a strong positive correlation with flood interrupting daily activities.
#Strong negative correlation with "white"
#positive correlation with comRel1 "this community tries to prevent disasters"


#I tried to plot some variables below, but because they are 0 and 1 values it does not work.
plot(scFloodData$coastalCount,scFloodData$floodDA)

#Impact of length of residency and coastal residency on flood safety experience
floodSAFE<-lm(scFloodData$floodSAFE~ scFloodData$currentAdd+
               scFloodData$currentComm+
               scFloodData$coastalCount+
                scFloodData$inc+scFloodData$white+
                scFloodData$commRel1+scFloodData$commRel2+scFloodData$commRel3+scFloodData$commRel4)
summary(floodSAFE)
##Similar results compared to flood daily activities. Strong positive correlation between coastal county residency and flood safety. 
#Strong negative correlation with white.

##CoastalCount/Length of Residency impact on Flood in the Home
floodNever<-lm(scFloodData$floodNever~ scFloodData$currentAdd+
                scFloodData$currentComm+
                scFloodData$coastalCount+
                 scFloodData$inc+scFloodData$white+
                 scFloodData$commRel1+scFloodData$commRel2+scFloodData$commRel3+scFloodData$commRel4)
summary(floodNever) 
#Strong positive correlation between length of time at the address and flood in the home.
#Negative correlation with white
##Does this mean that longer time in the home means greater number of times flood water in the home?



##Septic Tank Questions


##Septic Yes/No
septic.yn<-lm(scFloodData$septic~scFloodData$coastalCount+
                scFloodData$inc+scFloodData$white+
                scFloodData$commRel1+scFloodData$commRel2+scFloodData$commRel3+scFloodData$commRel4+
                scFloodData$infraLG+scFloodData$infraDW+scFloodData$infraRD)
summary(septic.yn)
##Results- 
##correlation between coastal counties (negative relationship??)
##postive correlation with white

##SepticRain
septic.rain<-lm(scFloodData$septicRain~scFloodData$coastalCount+
                  scFloodData$inc+scFloodData$white+
                  scFloodData$commRel1+scFloodData$commRel2+scFloodData$commRel3+scFloodData$commRel4+
                  scFloodData$infraLG+scFloodData$infraDW+scFloodData$infraRD)
summary(septic.rain)
#Results-positive correlation with coastal counties, negative correlation with white

##SepticTide
septic.tide<-lm(scFloodData$septicTide~scFloodData$coastalCount+
                  scFloodData$inc+scFloodData$white+
                  scFloodData$commRel1+scFloodData$commRel2+scFloodData$commRel3+scFloodData$commRel4+
                  scFloodData$infraLG+scFloodData$infraDW+scFloodData$infraRD)
summary(septic.tide)
#Results- positive correlation with coastal counties, 
#strong negative correlation with white, 
#negative correlation with commRel2 ("This community actively prepares for future disasters"),
#positive correlation with infraRD ("On average, how satisfied are you with the conditions of the roads and streets in your community")

##SepticMove

septic.move<-lm(scFloodData$septicMove~scFloodData$coastalCount+
                  scFloodData$inc+scFloodData$white+
                  scFloodData$commRel1+scFloodData$commRel2+scFloodData$commRel3+scFloodData$commRel4+
                  scFloodData$infraLG+scFloodData$infraDW+scFloodData$infraRD+
                  scFloodData$scBond+scFloodData$scBridge)
summary(septic.move)
##Results- positive correlation with coastal counties,
#strong negative correlation with white, 
#positive correlation with infraLG ("On average, how satisfied are you with the overall job of local government in providing services in your community?")
#positive correlation with infraRD ("On average, how satisfied are you with the conditions of the roads and streets in your community")
#no strong correlation with SCBond or SCbridge

##Local Environmental Concern

#Local Biodiversity Concern
concernBio<-lm(scFloodData$concernBio~scFloodData$septicTide+scFloodData$septic+scFloodData$septicRain+scFloodData$septicMove+
                 scFloodData$floodDA+scFloodData$floodSAFE+scFloodData$floodNever+
               scFloodData$currentAdd+scFloodData$currentComm+scFloodData$coastalCount+
                 scFloodData$climateRisk+scFloodData$climateHarm+
                 scFloodData$white+scFloodData$male+scFloodData$inc+scFloodData$edu+scFloodData$age)
summary(concernBio)

##Notable Results
#Negative correlation between flood in the home and biodiversity concern
#positive correlation between length at current address and biodiversity concern
#strong positive correlation between climate risk and biodiversity concern
#positive correlation between income and biodiversity concern
#no strong correlation between septic and biodiversity concern


#Water Quality Concern
concernWaterQ<-lm(scFloodData$concernWaterQ~scFloodData$septicTide+scFloodData$septic+scFloodData$septicRain+scFloodData$septicMove+
                    scFloodData$floodDA+scFloodData$floodSAFE+ scFloodData$floodNever+
                  scFloodData$currentAdd+scFloodData$currentComm+scFloodData$coastalCount+
                    scFloodData$climateRisk+scFloodData$climateHarm+
                    scFloodData$white+scFloodData$male+scFloodData$inc+scFloodData$edu+scFloodData$age)
summary(concernWaterQ)
#Notable Results
#negative correlation between flooding in the home and water qual concern
#strong positive correlation between climate risk and water qual concern
#no correlation with demographics, climate harm, coastalcount, current com, floodDA/safety, or septic experience

##Local Flood Concern
concernFlood<-lm(scFloodData$concernFlood~scFloodData$septicTide+scFloodData$septic+scFloodData$septicRain+scFloodData$septicMove+
                   scFloodData$floodDA+scFloodData$floodSAFE+ scFloodData$floodNever+
                 scFloodData$currentAdd+scFloodData$currentComm+scFloodData$coastalCount+
                 scFloodData$climateRisk+scFloodData$climateHarm+
                  scFloodData$white+scFloodData$male+scFloodData$inc+scFloodData$edu+scFloodData$age)

summary(concernFlood)
##Notable Results
#strong psotive correlation with flood concern and floodDA. positive correlation with FloodSAFE.
#positive correlation with currentAdd (length of residency)
#positive correlation with Climate Risk
#negative correlation with male

#Within the environmental concern section, no correlations between septic experiences and environmental cocnerns. 
#This section does not include ideology or policy analysis. This is something I may want to add in.

##Climate Change
climateRisk<-lm(scFloodData$climateRisk~scFloodData$septicTide+scFloodData$septic+scFloodData$septicRain+scFloodData$septicMove+
                  scFloodData$floodDA+scFloodData$floodSAFE+scFloodData$floodNever+
                  scFloodData$currentAdd+scFloodData$currentComm+scFloodData$coastalCount+
                  scFloodData$white+scFloodData$male+scFloodData$inc+scFloodData$edu+scFloodData$age+
                  scFloodData$ideology+scFloodData$rep+scFloodData$dem)

summary(climateRisk)
##Notable Results
#Positive correlation between septicMOVE, floodDA, white, time at currentAdd & perception of climateRisk
#Negative correlation between floodNEVER, and a strong negative correlation between ideology and climateRisk

climateHarm<-lm(scFloodData$climateHarm~scFloodData$septicTide+scFloodData$septic+scFloodData$septicRain+scFloodData$septicMove+
                  scFloodData$floodDA+scFloodData$floodSAFE+scFloodData$floodNever+
                  scFloodData$currentAdd+scFloodData$currentComm+scFloodData$coastalCount+
                  scFloodData$white+scFloodData$male+scFloodData$inc+scFloodData$edu+scFloodData$age+
                scFloodData$ideology+scFloodData$rep+scFloodData$dem+
                  scFloodData$scBond+scFloodData$scBridge)
summary(climateHarm)
##Notable Results
#Only a negative correlation with ideology and years lived in current community
##no correlation with SCBond, SC bridge, demographics

##Relocation
randomflood.move<-lm(scFloodData$move~scFloodData$ownHome+scFloodData$infraLG+scFloodData$infraDW+scFloodData$infraRD+
                       scFloodData$commRel1+scFloodData$commRel2+scFloodData$commRel3+scFloodData$commRel4+
                       scFloodData$scBond1+scFloodData$scBond2+scFloodData$scBond3+scFloodData$scBond4+scFloodData$scBond5+scFloodData$scBond6+scFloodData$scBond7+scFloodData$scBond8+
                       scFloodData$scBridge1+scFloodData$scBridge2+scFloodData$scBridge3+scFloodData$scBridge4+scFloodData$scBridge5+scFloodData$scBridge6+scFloodData$scBridge7+scFloodData$scBridge8+
                       scFloodData$currentAdd+scFloodData$currentComm+scFloodData$coastalCount+
                       scFloodData$septicSatisfied+scFloodData$septicTide+scFloodData$septic+scFloodData$septicRain+scFloodData$septicMove+
                       scFloodData$white+scFloodData$male+scFloodData$inc+scFloodData$edu+scFloodData$age)#septic-do I need to change this to the group name?
summary(randomflood.move)
##Notable Results-not sure I used the correct dataset for the dependent variable here.
##Wanting to move after random flood days-positive correlation with infraLG and septicMove, male, and age
##Negative correlation with length of time at current address
#surprisingly no correlation with bridging/bonding using (scFloodData$scBond+scFloodData$scBridge)
##negative correlation with SCBond4, no correlation with bridging


##Buyout

##Buyout Support Owners
buyoutSupportOwn<-lm(scFloodData$buyoutSupportOwn~scFloodData$ownHome+
                        scFloodData$infraLG+scFloodData$infraDW+scFloodData$infraRD+
                        scFloodData$commRel1+scFloodData$commRel2+scFloodData$commRel3+scFloodData$commRel4+
                        scFloodData$scBond1+scFloodData$scBond2+scFloodData$scBond3+scFloodData$scBond4+scFloodData$scBond5+scFloodData$scBond6+scFloodData$scBond7+scFloodData$scBond8+
                        scFloodData$scBridge1+scFloodData$scBridge2+scFloodData$scBridge3+scFloodData$scBridge4+scFloodData$scBridge5+scFloodData$scBridge6+scFloodData$scBridge7+scFloodData$scBridge8+
                        scFloodData$currentAdd+scFloodData$currentComm+scFloodData$coastalCount+
                        scFloodData$septicSatisfied+scFloodData$septicTide+scFloodData$septic+scFloodData$septicRain+scFloodData$septicMove+
                        scFloodData$white+scFloodData$male+scFloodData$inc+scFloodData$edu+scFloodData$age)
summary(buyoutSupportOwn)
##Notable Results
##Buyout Support Own had a positive corrleation with CommRel2,scBridge4,septicMove
##Buyout Support Own had negative correlation with scBridge7
##no correlation between demographics
##insurance was not included in this analysis but could be an interesting thing to look at.


##Buyout Support Renters
buyoutSupportRent<-lm(scFloodData$buyoutSupportRent~scFloodData$ownHome+scFloodData$infraLG+scFloodData$infraDW+scFloodData$infraRD+
                        scFloodData$commRel1+scFloodData$commRel2+scFloodData$commRel3+scFloodData$commRel4+
                        scFloodData$scBond1+scFloodData$scBond2+scFloodData$scBond3+scFloodData$scBond4+scFloodData$scBond5+scFloodData$scBond6+scFloodData$scBond7+scFloodData$scBond8+
                        scFloodData$scBridge1+scFloodData$scBridge2+scFloodData$scBridge3+scFloodData$scBridge4+scFloodData$scBridge5+scFloodData$scBridge6+scFloodData$scBridge7+scFloodData$scBridge8+
                        scFloodData$currentAdd+scFloodData$currentComm+scFloodData$coastalCount+
                        scFloodData$septicSatisfied+scFloodData$septicTide+scFloodData$septic+scFloodData$septicRain+scFloodData$septicMove+
                        scFloodData$white+scFloodData$male+scFloodData$inc+scFloodData$edu+scFloodData$age)
summary(buyoutSupportRent)
##Notable Results
##Buyout support (renters) had a positive correlation with commRel4,scBond2,scBond3, SCBridge3, SCBridge5,septic rain, septicmove, income
##Buyout support (renters) had a negative correlation with commRel3, scBond1,scBond5,scBridge6, scBridge7,coastalcounty,septicTide, white, male,
##Overall mixed results among social capital questions and no correlation with length of residency, age, education, and infrastructure responses.


##Buyout Support Pre
buyoutSupportPre<-lm(scFloodData$buyoutSupportPre~scFloodData$ownHome+scFloodData$infraLG+scFloodData$infraDW+scFloodData$infraRD+
                     scFloodData$commRel1+scFloodData$commRel2+scFloodData$commRel3+scFloodData$commRel4+
                     scFloodData$scBond1+scFloodData$scBond2+scFloodData$scBond3+scFloodData$scBond4+scFloodData$scBond5+scFloodData$scBond6+scFloodData$scBond7+scFloodData$scBond8+
                     scFloodData$scBridge1+scFloodData$scBridge2+scFloodData$scBridge3+scFloodData$scBridge4+scFloodData$scBridge5+scFloodData$scBridge6+scFloodData$scBridge7+scFloodData$scBridge8+
                     scFloodData$currentAdd+scFloodData$currentComm+scFloodData$coastalCount+
                     scFloodData$septicSatisfied+scFloodData$septicTide+scFloodData$septic+scFloodData$septicRain+scFloodData$septicMove+
                     scFloodData$white+scFloodData$male+scFloodData$inc+scFloodData$edu+scFloodData$age)
summary(buyoutSupportPre)
##Notable Results
##buyout Support Pre had a positive correlation with:CommRel2,Coastalcount,septicmove
##buyout Support Pre had a negative correlation with:SCBond4
##Overall, no strong demographic correlations only one social captial correlation.


##BuyoutSupportPost
buyoutSupportPost<-lm(scFloodData$buyoutSupportPost~scFloodData$ownHome+scFloodData$infraLG+scFloodData$infraDW+scFloodData$infraRD+
                        scFloodData$commRel1+scFloodData$commRel2+scFloodData$commRel3+scFloodData$commRel4+
                        scFloodData$scBond1+scFloodData$scBond2+scFloodData$scBond3+scFloodData$scBond4+scFloodData$scBond5+scFloodData$scBond6+scFloodData$scBond7+scFloodData$scBond8+
                        scFloodData$scBridge1+scFloodData$scBridge2+scFloodData$scBridge3+scFloodData$scBridge4+scFloodData$scBridge5+scFloodData$scBridge6+scFloodData$scBridge7+scFloodData$scBridge8+
                        scFloodData$currentAdd+scFloodData$currentComm+scFloodData$coastalCount+
                        scFloodData$septicSatisfied+scFloodData$septicTide+scFloodData$septic+scFloodData$septicRain+scFloodData$septicMove+
                        scFloodData$white+scFloodData$male+scFloodData$inc+scFloodData$edu+scFloodData$age)
summary(buyoutSupportPost)
##Notable Results
##buyout Support Post had a positive correlation with:ComRel2,scBridge4,coastalcount,septicmove
##buyout Support Post had a negative correlation with:CommRel4,scBridge7
##Overall, buyout suport post had no correlation with demographics, few mixed(+/-)correlations for social capital. A correlation with coastalcount, but not with length of residency.



##How does number of flood days influence original response to buyout support??
##Not sure if these models even make sense since we are comparing different randomly generated numbers.

#General
prepostGen<-lm(scFloodData$buyoutSupportPost~scFloodData$buyoutSupportPre)
summary(prepostGen)

##results
##strong positive correlation between these two variables. 
##Does this mean that people's responses to buyout did not change signficantly when presented with a specific random number of flood days?

##Pre and Post (renters)
prepostRent<-lm(scFloodData$buyoutSupportRent~scFloodData$buyoutSupportPre)
summary(prepostRent)
##Results
##renters pre response had a strong positive correlation to post response?



##Pre and Post (owners)
prepostOwn<-lm(scFloodData$buyoutSupportOwn~scFloodData$buyoutSupportPre)
summary(prepostOwn)

##Results
##homeowners pre response had a strong positive correlation to post response?




##Nowlin Pre Post Models

supportPreModel <- lm(buyoutSupportPre ~ concernFlood+floodEx+infraScale+commRel+
coastalCount+scBridge+scBond+ownHome+currentAdd+ideology+
  age+male+white+edu+inc, data = scFloodData)

summary(supportPreModel) 
##Results for supportPreModel
##Responses to concernFlood,floodex,infrascale,commRel,coastalCount,scBridge, and male all had a positive correlation with BuyoutsupportPre
##Responses to scBond,currentAdd, and ideology had a negative correlation with BuyoutsupportPre

#MoveModel
summary(moveModel <- lm(move ~ floodDays+concernFlood+floodEx+infraScale+
                          scBond+scBridge+commRel+coastalCount+
                          ownHome+currentAdd+ideology+age+
                          male+white+edu+inc, data = scFloodData))
##Results for MoveModel
##Responses to floodDays,infraScale, and education were positively correlated to move responses.
##This means that a greater number of flood days means greater liklihood of moving outside the community.
#more education, more likly to move with a given number of flood days?


##Responses to currentAdd and income were negatively corelated to move responses.
##this means that longer time at current address correlates to lower likelihood of moving.
##higher income means less likelihood of moving.

#PostOwnModel
summary(supportPostOwnModel <- lm(buyoutSupportOwn ~ floodDays+concernFlood+floodEx+infraScale+scBond+scBridge+commRel+coastalCount+currentAdd+ideology+age+male+white+edu+inc+buyoutSupportPre, data = scFloodData))

##Results for support PostOwnModel

##Responses to floodDays was positively correlated to buyout support for homeowners.
##This means that a higher number of flood days meant greater support for buyout programs from homeowners?
##Buyoutsupport Pre responses had a strong positive correlation with buyout support from homeowners, 
##meaning their response before a given number of flood days was highly indicative of responses given a random specific number of flood days. 
##no other significant correlations.

#PostRentModel
summary(supportPostRentModel <- lm(buyoutSupportRent ~ floodDays+concernFlood+floodEx+infraScale+scBond+scBridge+commRel+coastalCount+currentAdd+ideology+age+male+white+edu+inc+buyoutSupportPre, data = scFloodData))
##Results for PostRentModel
##Responses to infrascale and buyoutsupportPre had a positive correlation with responses to buyout support for renters post a given number of random flood days.
##This means that support for buyouts from the original question had a strong influence on responses to buyout support given a particular number of flood days per year.
##I do not know the meaning of infrascale correlation. Does it mean that respondents who reported worse local infrastructure were more or less in support of a buyout? 
##Responses to commRel had a negative correlation to buyout support for Renters post given number of flood days.
##Does this mean that respondents(specifically renters) who believe that they have more resilient communities are less likely to support a buyout
##no demographic correlations for renters, no correlation with number of flood days.







##Notes to self:
#flooding experience was not included in septic analysis- should it be?
#local environmental concern does not include ideology as an independent variable- go back and add this in??
##insurance question for buyers and renters has not been incorporated into analysis so far. Where might this be useful to incorporate? (buyout,relocating, randomfloodmove)

