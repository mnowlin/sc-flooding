## load data with recodes 
source("scripts/recodes.R")

library(ggplot2)

names(scFloodData) # variable names 

supportPreModel <- lm(buyoutSupportPre ~ concernFlood+floodEx+infraScale+commRel+coastalCount+scBridge+scBond+ownHome+currentAdd+ideology+age+male+white+edu+inc, data = scFloodData)
summary(supportPreModel) 

summary(moveModel <- lm(move ~ floodDays+concernFlood+floodEx+infraScale+scBond+scBridge+commRel+coastalCount+ownHome+currentAdd+ideology+age+male+white+edu+inc, data = scFloodData))

summary(supportPostOwnModel <- lm(buyoutSupportOwn ~ floodDays+concernFlood+floodEx+infraScale+scBond+scBridge+commRel+coastalCount+currentAdd+ideology+age+male+white+edu+inc+buyoutSupportPre, data = scFloodData))

summary(supportPostRentModel <- lm(buyoutSupportRent ~ floodDays+concernFlood+floodEx+infraScale+scBond+scBridge+commRel+coastalCount+currentAdd+ideology+age+male+white+edu+inc+buyoutSupportPre, data = scFloodData))