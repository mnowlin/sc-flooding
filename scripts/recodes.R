## 
library(dplyr)

## load data
scFloodData <- read.csv("data/SC Statewide Survey NUMBER.csv")

## removes rows 2 and 3 that don't have data 
scFloodData <- scFloodData[-c(1:2), ]
names(scFloodData)

## sample accounting: total records, then drop Qualtrics-flagged spam (Status 8)
nRecords <- nrow(scFloodData)
scFloodData <- scFloodData[scFloodData$Status != "8", ]
nNotSpam <- nrow(scFloodData)

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
## buyout support (Q16). Asked of all respondents before the flood-days experiment;
## the "Pre" suffix means pre-experiment. buyoutSupport is the name used in the manuscript.
scFloodData$buyoutSupportPre <- as.numeric(scFloodData$Q16)
scFloodData$buyoutSupport <- scFloodData$buyoutSupportPre
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

## flood recency (Q14 is multi-select: 1 = no, 2 = last year, 3 = 2-5 years, 4 = 6-10,
## 5 = 10-20, 6 = 20+ years ago). Most recent flood: within ~5 years vs. longer ago
floodMostRecent <- sapply(strsplit(scFloodData$Q14, ","), function(x) {
  x <- suppressWarnings(as.numeric(x)); x <- x[!is.na(x) & x > 1]
  if (length(x)) min(x) else NA })
scFloodData$floodRecent <- ifelse(!is.na(floodMostRecent) & floodMostRecent <= 3,1,0)
scFloodData$floodOlder <- ifelse(!is.na(floodMostRecent) & floodMostRecent > 3,1,0)
scFloodData$floodRecent[is.na(scFloodData$floodEx)] <- NA
scFloodData$floodOlder[is.na(scFloodData$floodEx)] <- NA

## flooding more frequent (vs. same or less frequent)
scFloodData$floodMore <- ifelse(scFloodData$floodF==3,1,0)

## survey completion time (seconds), for the speeder check
scFloodData$duration <- as.numeric(scFloodData$Duration..in.seconds.)

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
scFloodData$infraScale <- (scFloodData$infraDW+scFloodData$infraLG+scFloodData$infraRD+scFloodData$infraSWSP)/4
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

scFloodData$scBond <- (scFloodData$scBond1+scFloodData$scBond2+scFloodData$scBond3+scFloodData$scBond4+
                         scFloodData$scBond5+scFloodData$scBond6+scFloodData$scBond7+scFloodData$scBond8)/8

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

scFloodData$scBridge <- (scFloodData$scBridge1+scFloodData$scBridge2+scFloodData$scBridge3+scFloodData$scBridge4+
                           scFloodData$scBridge5+scFloodData$scBridge6+scFloodData$scBridge7+scFloodData$scBridge8)/8

# Cronbachs alpha
scBridgeA <- psy::cronbach(data.frame(scFloodData$scBridge1,scFloodData$scBridge2,scFloodData$scBridge3,scFloodData$scBridge4,
                                    scFloodData$scBridge5,scFloodData$scBridge6,scFloodData$scBridge7,scFloodData$scBridge8))


## community resilience 
scFloodData$commRel1 <- as.numeric(scFloodData$Q1_1.2)
scFloodData$commRel2 <- as.numeric(scFloodData$Q1_2.2)
scFloodData$commRel3 <- as.numeric(scFloodData$Q1_3.2)
scFloodData$commRel4 <- as.numeric(scFloodData$Q1_4.1)

scFloodData$commRel <- (scFloodData$commRel1+scFloodData$commRel2+scFloodData$commRel3+scFloodData$commRel4)/4

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

## coastal county (self-report; administrative coding is added after the county merge)
scFloodData$coastalSelf <- ifelse(scFloodData$Q83==1,1,0)

## current address 
table(scFloodData$currentAdd)

scFloodData$currentAdd <- as.numeric(scFloodData$Q4.3)
## time in area (within ~25 miles): Q82 1 = same as current address, 2 = <1 year ... 5 = 11+ years
## recoded to the same 1-4 scale as currentAdd
scFloodData$currentComm <- ifelse(as.numeric(scFloodData$Q82)==1, scFloodData$currentAdd,
                                  as.numeric(scFloodData$Q82)-1)

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
## ZIPs spanning counties: assign the county with the largest share of residential addresses
scZip <- scZip %>% arrange(zip, desc(RES_RATIO)) %>% distinct(zip, .keep_all = TRUE)
## 29342 (Gaffney PO boxes) is not in the HUD crosswalk; assign Cherokee County
scZip <- bind_rows(scZip, data.frame(zip = 29342, STCOFIPS = 45021))
scNRI <- read.csv("data/NRI-short.csv")


nZip <- sum(!is.na(scFloodData$zip))
scFloodData1 <- merge(scFloodData,scZip, by = "zip")
table(scFloodData1$zip)

scFloodData2 <- merge(scFloodData1,scNRI, by = "STCOFIPS")
nMerged <- nrow(scFloodData2)

## administrative coastal county: the eight-county SC coastal zone listed in Q83
coastalFIPS <- c(45013, 45015, 45019, 45029, 45035, 45043, 45051, 45053)
scFloodData2$coastalCount <- ifelse(scFloodData2$STCOFIPS %in% coastalFIPS,1,0)

## FEMA National Risk Index (county): coastal and riverine flooding risk scores (0-100)
## coastal flooding risk is undefined for inland counties, so set to 0
scFloodData2$cfldRisk <- ifelse(is.na(scFloodData2$CFLD_RISKS),0,scFloodData2$CFLD_RISKS)
scFloodData2$rfldRisk <- scFloodData2$RFLD_RISKS
scFloodData2$floodRisk <- pmax(scFloodData2$cfldRisk, scFloodData2$rfldRisk)

## post-stratification weights: rake to ACS 2024 1-year SC adults (18+) on sex, age, race, education
## benchmarks computed from tables B01001, B01001A, B15001 (via Census Reporter)
scFloodData2$ageCat <- cut(scFloodData2$age, c(17,34,54,64,Inf), labels = c("18-34","35-54","55-64","65+"))
scFloodData2$eduCat <- cut(scFloodData2$edu, c(0,1,2,5,6,7), labels = c("<HS","HS","Some college","BA","Grad"))
scFloodData2$maleCat <- factor(scFloodData2$male)
scFloodData2$whiteCat <- factor(scFloodData2$white)

acsPop <- 4328992
margins <- list(
  data.frame(maleCat = c("0","1"), Freq = acsPop*c(0.5205, 0.4795)),
  data.frame(ageCat = c("18-34","35-54","55-64","65+"), Freq = acsPop*c(0.2753, 0.3126, 0.1620, 0.2501)),
  data.frame(whiteCat = c("0","1"), Freq = acsPop*c(0.3454, 0.6546)),
  data.frame(eduCat = c("<HS","HS","Some college","BA","Grad"), Freq = acsPop*c(0.0940, 0.2916, 0.3072, 0.1913, 0.1160))
)
rakeData <- scFloodData2[complete.cases(scFloodData2[c("maleCat","ageCat","whiteCat","eduCat")]), ]
rakeDesign <- survey::rake(survey::svydesign(ids = ~1, data = rakeData),
                           sample.margins = list(~maleCat, ~ageCat, ~whiteCat, ~eduCat),
                           population.margins = margins)
rakeData$wt <- weights(rakeDesign)/mean(weights(rakeDesign))
scFloodData2$wt <- rakeData$wt[match(scFloodData2$ResponseId, rakeData$ResponseId)]
