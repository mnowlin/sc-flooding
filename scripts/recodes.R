## 
library(dplyr)

## load data
scFloodData <- read.csv("data/SC Statewide Survey NUMBER.csv")

## removes rows 2 and 3 that don't have data 
scFloodData <- scFloodData[-c(1:2), ]
names(scFloodData)

## environmental concern measures 
scFloodData$concernBio <- as.numeric(scFloodData$Q1_1)-1
scFloodData$concernCC <- as.numeric(scFloodData$Q1_2)-1
scFloodData$concernSLR <- as.numeric(scFloodData$Q1_3)-1
scFloodData$concernWaterQ <- as.numeric(scFloodData$Q1_4)-1
scFloodData$concernFlood <- as.numeric(scFloodData$Q1_5)-1

## technocracy scale 
scFloodData$tech1 <- as.numeric(scFloodData$Q1_1.1)
scFloodData$tech2 <- as.numeric(scFloodData$Q1_2.1)
scFloodData$tech3 <- as.numeric(scFloodData$Q1_3.1)

## homeowner
scFloodData$ownHome <- ifelse(scFloodData$Q5==1 | 
                              scFloodData$Q5==2,1,0) 

## insurance 
table(scFloodData$insurance)
scFloodData$homeIns <- ifelse(scFloodData$Q6==1,1,0)
scFloodData$rentIns <- ifelse(scFloodData$Q7==1,1,0)
scFloodData$insurance <- ifelse(scFloodData$homeIns==1 | 
                                  scFloodData$rentIns==1,1,0)

## buyout support pre
scFloodData$buyoutSupportPre <- as.numeric(scFloodData$Q16)
scFloodData$buyoutSupportPreLow <- ifelse(scFloodData$buyoutSupportPre<=mean(scFloodData$buyoutSupportPre, na.rm = TRUE)-
                                            sd(scFloodData$buyoutSupportPre, na.rm = TRUE),1,0)
scFloodData$buyoutSupportPreHigh <- ifelse(scFloodData$buyoutSupportPre>=mean(scFloodData$buyoutSupportPre, na.rm = TRUE)+
                                            sd(scFloodData$buyoutSupportPre, na.rm = TRUE),1,0)


## flooding 
scFloodData$floodF <- as.numeric(scFloodData$Q10)
scFloodData$floodDA <- as.numeric(scFloodData$Q12)
scFloodData$floodSAFE <- as.numeric(scFloodData$Q13)
scFloodData$Q14[scFloodData$Q14==""] <- NA
scFloodData$floodNever <- ifelse(scFloodData$Q14==1,1,0)
scFloodData$floodEx <- ifelse(scFloodData$floodNever==0,1,0)

## flood days variable 
scFloodData$floodDays <- as.numeric(scFloodData$Flooding.Days)

## move and buyout
scFloodData$move <- 6-as.numeric(scFloodData$Q50)

scFloodData$Q18rescale <- datawizard::rescale(as.numeric(scFloodData$Q18), to = c(1, 7))
scFloodData$Q19rescale <- datawizard::rescale(as.numeric(scFloodData$Q19), to = c(1, 7))
scFloodData$buyoutSupportOwnScaled <- 8-scFloodData$Q18rescale
scFloodData$buyoutSupportOwn <- 6-as.numeric(scFloodData$Q18)
scFloodData$buyoutSupportRent <- 8-scFloodData$Q19rescale

#scFloodData$buyoutSupportPost <- coalesce(scFloodData$buyoutSupportOwn,scFloodData$buyoutSupportRent)

## infrastructure
scFloodData$infraLG <- 6-as.numeric(scFloodData$Q20)
scFloodData$infraDW <- 6-as.numeric(scFloodData$Q21)
scFloodData$infraRD <- 6-as.numeric(scFloodData$Q22)

### sewer
scFloodData$sewer <- ifelse(scFloodData$Q23==2 | 
                               scFloodData$Q24==1,1,0)
scFloodData$sewerSatisfied <- 6-as.numeric(scFloodData$Q28)

### septic 
scFloodData$septic <- ifelse(scFloodData$Q23==1 | 
                             scFloodData$Q24==2,1,0)
scFloodData$septicSatisfied <- 6-as.numeric(scFloodData$Q51)
scFloodData$septicRain <- 5-as.numeric(scFloodData$Q25)
scFloodData$septicTide <- 5-as.numeric(scFloodData$Q26)
scFloodData$septicMove <- 6-as.numeric(scFloodData$Q27)

scFloodData$infraSWSP <- replace(scFloodData$sewerSatisfied, is.na(scFloodData$sewerSatisfied), 
                                 scFloodData$septicSatisfied[is.na(scFloodData$sewerSatisfied)])

### principle components of infrastructure variables - combine into to a scale 
infrastructureData <- data.frame(scFloodData$infraDW,scFloodData$infraLG,scFloodData$infraRD,scFloodData$infraSWSP)
prcomp(na.omit(infrastructureData), center = TRUE, scale = TRUE)
scFloodData$infraScale <- round(((scFloodData$infraDW+scFloodData$infraLG+scFloodData$infraRD+scFloodData$infraSWSP)/5),0)
# Cronbachs alpha for infrastructure scale 
infraA <- psy::cronbach(data.frame(scFloodData$infraDW,scFloodData$infraLG,scFloodData$infraRD,scFloodData$infraSWSP))

## climate change 
scFloodData$climateRisk <- as.numeric(scFloodData$Q32)-1
scFloodData$climateHarm <- 7-as.numeric(scFloodData$Q33)

## social capital: bonding 
scFloodData$scBond1 <- as.numeric(scFloodData$Q2)
scFloodData$scBond2 <- as.numeric(scFloodData$Q3)
scFloodData$scBond3 <- as.numeric(scFloodData$Q4)
scFloodData$scBond4 <- as.numeric(scFloodData$Q5.1)
scFloodData$scBond5 <- as.numeric(scFloodData$Q6.1)
scFloodData$scBond6 <- as.numeric(scFloodData$Q7.1)
scFloodData$scBond7 <- as.numeric(scFloodData$Q8)
scFloodData$scBond8 <- as.numeric(scFloodData$Q9)

scFloodData$scBond <- round(((scFloodData$scBond1+scFloodData$scBond2+scFloodData$scBond3+scFloodData$scBond4+
                                scFloodData$scBond5+scFloodData$scBond6+scFloodData$scBond7+scFloodData$scBond8)/8),0)

# Cronbachs alpha
scBondA <- psy::cronbach(data.frame(scFloodData$scBond1,scFloodData$scBond2,scFloodData$scBond3,scFloodData$scBond4,
                                      scFloodData$scBond5,scFloodData$scBond6,scFloodData$scBond7,scFloodData$scBond8))

## social capital: bridging
scFloodData$scBridge1 <- as.numeric(scFloodData$Q2.1)
scFloodData$scBridge2 <- as.numeric(scFloodData$Q3.1)
scFloodData$scBridge3 <- as.numeric(scFloodData$Q4.1)
scFloodData$scBridge4 <- as.numeric(scFloodData$Q5.2)
scFloodData$scBridge5 <- as.numeric(scFloodData$Q6.2)
scFloodData$scBridge6 <- as.numeric(scFloodData$Q7.2)
scFloodData$scBridge7 <- as.numeric(scFloodData$Q8.1)
scFloodData$scBridge8 <- as.numeric(scFloodData$Q9.1)

scFloodData$scBridge <- round(((scFloodData$scBridge1+scFloodData$scBridge2+scFloodData$scBridge3+scFloodData$scBridge4+
                                scFloodData$scBridge5+scFloodData$scBridge6+scFloodData$scBridge7+scFloodData$scBridge8)/8),0)

# Cronbachs alpha
scBridgeA <- psy::cronbach(data.frame(scFloodData$scBridge1,scFloodData$scBridge2,scFloodData$scBridge3,scFloodData$scBridge4,
                                    scFloodData$scBridge5,scFloodData$scBridge6,scFloodData$scBridge7,scFloodData$scBridge8))


## community resilience 
scFloodData$commRel1 <- as.numeric(scFloodData$Q1_1.2)
scFloodData$commRel2 <- as.numeric(scFloodData$Q1_2.2)
scFloodData$commRel3 <- as.numeric(scFloodData$Q1_3.2)
scFloodData$commRel4 <- as.numeric(scFloodData$Q1_4.1)

scFloodData$commRel <- round(((scFloodData$commRel1+scFloodData$commRel2+scFloodData$commRel3+scFloodData$commRel4)/4),0)

# Cronbachs alpha
commRelA <- psy::cronbach(data.frame(scFloodData$commRel1,scFloodData$commRel2,scFloodData$commRel3,scFloodData$commRel4))

## cultural theory 
scFloodData$egal1 <- as.numeric(scFloodData$Q1_1.3)
scFloodData$indiv1 <- as.numeric(scFloodData$Q1_2.3)
scFloodData$hier1 <- as.numeric(scFloodData$Q1_3.3)
scFloodData$fatal1 <- as.numeric(scFloodData$Q1_4.2)
scFloodData$egal2 <- as.numeric(scFloodData$Q1_5.1)
scFloodData$indiv2 <- as.numeric(scFloodData$Q1_6)
scFloodData$hier2 <- as.numeric(scFloodData$Q1_7)
scFloodData$fatal2 <- as.numeric(scFloodData$Q1_8)
scFloodData$egal3 <- as.numeric(scFloodData$Q1_9)
scFloodData$indiv3 <- as.numeric(scFloodData$Q1_10)
scFloodData$hier3 <- as.numeric(scFloodData$Q1_11)
scFloodData$fatal3 <- as.numeric(scFloodData$Q1_12)

scFloodData$egal <- round(((scFloodData$egal1+scFloodData$egal2+scFloodData$egal3)/3),0)
scFloodData$indiv <- round(((scFloodData$indiv1+scFloodData$indiv2+scFloodData$indiv3)/3),0)
scFloodData$hier <- round(((scFloodData$hier1+scFloodData$hier2+scFloodData$hier3)/3),0)
scFloodData$fatal <- round(((scFloodData$fatal1+scFloodData$fatal2+scFloodData$fatal3)/3),0)

## political beliefs 
scFloodData$ideology <- as.numeric(scFloodData$Q1.1) # more conservative 
scFloodData$rep <- ifelse(scFloodData$Q2.2==2,1,0)
scFloodData$dem <- ifelse(scFloodData$Q2.2==1,1,0)

## demographics
scFloodData$age <- as.numeric(scFloodData$Q1.2)
scFloodData$age[scFloodData$age < 18] <- NA
scFloodData$male <- ifelse(scFloodData$Q2.3==1,1,0)
scFloodData$white <- ifelse(scFloodData$Q3.2==1,1,0)
scFloodData$edu <- as.numeric(scFloodData$Q4.2)
scFloodData$inc <- as.numeric(scFloodData$Q6.3)

## coastal county 
scFloodData$coastalCount <- ifelse(scFloodData$Q83==1,1,0)

## current address 
table(scFloodData$currentAdd)

scFloodData$currentAdd <- as.numeric(scFloodData$Q4.3)
scFloodData$currentComm <- as.numeric(scFloodData$Q82)

## zipcode 
table(scFloodData$Q2.4)
scFloodData$Q2.4 <- car::recode(scFloodData$Q2.4, "'2902@'=29020; '29475 K9'=29475")

table(scFloodData$zip)
scFloodData$zip <- as.numeric(scFloodData$Q2.4)
scFloodData$zip <- car::recode(scFloodData$zip, "19325=29325;21923=29123;28369=29369;30301=29301")

## charleston harbor data https://www.weather.gov/chs/coastalflood 
## high tides over 7 feet MLLW 2010-2019: 42.4; 2020-2022: 61.3. <= 50 high number 
# scFloodData$floodDaysH <- ifelse(scFloodData$floodDays >= 50,1,0)

# merge dataset 
scZip <- read.csv("data/SC-zip-to-county.csv")
scZip <- distinct(scZip, zip, .keep_all = TRUE)
scNRI <- read.csv("data/NRI-short.csv")


scFloodData1 <- merge(scFloodData,scZip, by = "zip")
table(scFloodData1$zip)

scFloodData2 <- merge(scFloodData1,scNRI, by = "STCOFIPS")
