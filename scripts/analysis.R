## analysis.R
## Analysis presented in flood-risk.qmd.
## Tables and figures are built in code chunks in the manuscript; this script
## holds the data prep and model fitting they depend on. Run from the project
## root (or source with the working directory set there).

## Data, recodes, scale reliabilities (scBondA, scBridgeA, commRelA, infraA),
## sample-accounting counts, and post-stratification weights (wt)
source("scripts/recodes.R")

## ---------------------------------------------------------------------------
## Model terms
## ---------------------------------------------------------------------------
floodTerms <- c("concernFlood", "floodEx", "floodF")
commTerms  <- c("commRel", "infraScale", "scBridge", "coastalCount", "rfldRisk")
indivTerms <- c("scBond", "ownHome", "currentAdd", "currentComm", "ideology")
demoTerms  <- c("age", "male", "white", "edu", "inc")
allTerms   <- c(floodTerms, commTerms, indivTerms, demoTerms)

mkForm <- function(dv, terms) reformulate(terms, response = dv)

## ---------------------------------------------------------------------------
## Sample accounting
## ---------------------------------------------------------------------------
## common estimation sample for the support models (listwise complete on the
## DV and all covariates), so the nested models are comparable
supportData <- scFloodData2[complete.cases(scFloodData2[c("buyoutSupport", allTerms)]), ]

sampleFunnel <- data.frame(
  Step = c("Survey records",
           "Excluding records flagged as spam",
           "Provided a ZIP code",
           "ZIP code matched to a South Carolina county",
           "Complete on all model variables (support models)",
           "Homeowners complete on all model variables (accept model)"),
  N = c(nRecords, nNotSpam, nZip, nMerged, nrow(supportData), NA)
)

## ---------------------------------------------------------------------------
## DV 1: Support for a property buyout program (all respondents), 1-7 scale
## H1 (flooding), H2 (community factors: attachment vs. government
## performance), H3 (individual factors). Nested models on a common sample.
## ---------------------------------------------------------------------------
supportFloodModel <- lm(mkForm("buyoutSupport", c(floodTerms, demoTerms)), data = supportData)
supportCommModel  <- lm(mkForm("buyoutSupport", c(floodTerms, commTerms, demoTerms)), data = supportData)
supportIndivModel <- lm(mkForm("buyoutSupport", c(floodTerms, indivTerms, demoTerms)), data = supportData)
supportModel   <- lm(mkForm("buyoutSupport", allTerms), data = supportData)

supportModels <- list("Flooding" = supportFloodModel, "Community" = supportCommModel,
                      "Individual" = supportIndivModel, "Full" = supportModel)

## county-clustered standard errors (respondents are nested in 46 counties and
## the model includes county-level measures)
clusterVcov <- ~STCOFIPS

## ---------------------------------------------------------------------------
## Robustness checks for the full support model
## ---------------------------------------------------------------------------
## (a) post-stratification weights (raked to ACS 2024 on sex, age, race, education)
supportWeighted <- lm(mkForm("buyoutSupport", allTerms), data = supportData, weights = wt)

## (b) ordered logit on the 7-point outcome
supportOrdered <- MASS::polr(mkForm("factor(buyoutSupport)", allTerms), data = supportData, Hess = TRUE)

## (c) community evaluations entered one at a time (collinearity check)
supportResilOnly <- lm(mkForm("buyoutSupport", setdiff(allTerms, c("infraScale", "scBridge"))), data = supportData)
supportInfraOnly <- lm(mkForm("buyoutSupport", setdiff(allTerms, c("commRel", "scBridge"))), data = supportData)
supportBridgeOnly <- lm(mkForm("buyoutSupport", setdiff(allTerms, c("commRel", "infraScale"))), data = supportData)

## (d) self-reported rather than administrative coastal county
supportSelfCoastal <- lm(mkForm("buyoutSupport", c(setdiff(allTerms, "coastalCount"), "coastalSelf")),
                         data = supportData)

robustModels <- list("Weighted" = supportWeighted, "Ordered logit" = supportOrdered,
                     "Resilience only" = supportResilOnly, "Infrastructure only" = supportInfraOnly,
                     "Bridging only" = supportBridgeOnly, "Self-reported coastal" = supportSelfCoastal)

## ---------------------------------------------------------------------------
## Alternative measures and data-quality check for the full support model
## ---------------------------------------------------------------------------
## (e) flood experience split by recency (most recent flood within ~5 years vs. longer ago)
supportRecency <- lm(mkForm("buyoutSupport", c(setdiff(allTerms, "floodEx"), "floodRecent", "floodOlder")), data = supportData)

## (f) flooding more frequent as a dummy (vs. same/less frequent) instead of the 1-3 item
supportFloodMore <- lm(mkForm("buyoutSupport", c(setdiff(allTerms, "floodF"), "floodMore")), data = supportData)

## (g) past-year flood exposure on the "disruptive days" metric (Q12) and safety (Q13), 1-6
supportExposure <- lm(mkForm("buyoutSupport", c(allTerms, "floodDA", "floodSAFE")), data = supportData)

## (h) excluding speeders (completion time under one-third of the median)
speedCut <- median(supportData$duration, na.rm = TRUE)/3
nSpeeders <- sum(supportData$duration < speedCut, na.rm = TRUE)
supportNoSpeed <- lm(mkForm("buyoutSupport", allTerms), data = supportData[supportData$duration >= speedCut, ])

altModels <- list("Flood recency" = supportRecency, "More frequent flooding" = supportFloodMore,
                  "Past-year exposure" = supportExposure, "Excluding speeders" = supportNoSpeed)

## exploratory factor analysis of the 16 social capital items (2 factors, oblimin)
scItems <- supportData[c(paste0("scBond", 1:8), paste0("scBridge", 1:8))]
scEFA <- psych::fa(scItems, nfactors = 2, rotate = "oblimin", fm = "ml")

## ---------------------------------------------------------------------------
## Substantive effects: change in predicted support (1-7) for a binary 0 to 1
## change or a two-standard-deviation increase, with 95% CIs (county-clustered)
## ---------------------------------------------------------------------------
supportVcovCL <- sandwich::vcovCL(supportModel, cluster = clusterVcov)
effectTerms <- c("floodEx", "coastalCount", "concernFlood", "commRel", "infraScale", "currentComm", "ideology")
effectTab <- do.call(rbind, lapply(effectTerms, function(v) {
  binary <- all(supportData[[v]] %in% c(0, 1))
  shift  <- if (binary) 1 else 2*sd(supportData[[v]])
  est <- coef(supportModel)[v]*shift
  se  <- sqrt(supportVcovCL[v, v])*shift
  data.frame(term = v, change = if (binary) "0 to 1" else sprintf("+2 SD (%.1f units)", shift),
             effect = est, lower = est - 1.96*se, upper = est + 1.96*se)
}))
recentB <- coef(supportRecency)["floodRecent"]

## correlations among the community and social capital measures
commCor <- cor(supportData[c("commRel", "infraScale", "scBridge", "scBond", "currentAdd", "currentComm")])
supportVIF <- car::vif(supportModel)

## weighted vs. unweighted mean support
supportMeanUnwt <- mean(scFloodData2$buyoutSupport, na.rm = TRUE)
wtOK <- !is.na(scFloodData2$wt) & !is.na(scFloodData2$buyoutSupport)
supportMeanWt <- weighted.mean(scFloodData2$buyoutSupport[wtOK], scFloodData2$wt[wtOK])

## full-model coefficients with county-clustered SEs, for inline reporting
supportCT <- lmtest::coeftest(supportModel, vcov. = sandwich::vcovCL(supportModel, cluster = clusterVcov))

## sample vs. ACS 2024 benchmarks (unweighted and weighted sample shares, %)
compVars <- list("Male" = scFloodData2$male == 1,
                 "Age 18-34" = scFloodData2$ageCat == "18-34", "Age 35-54" = scFloodData2$ageCat == "35-54",
                 "Age 55-64" = scFloodData2$ageCat == "55-64", "Age 65+" = scFloodData2$ageCat == "65+",
                 "White" = scFloodData2$white == 1,
                 "Less than high school" = scFloodData2$eduCat == "<HS", "High school/GED" = scFloodData2$eduCat == "HS",
                 "Some college/associate's" = scFloodData2$eduCat == "Some college",
                 "Bachelor's degree" = scFloodData2$eduCat == "BA", "Graduate degree" = scFloodData2$eduCat == "Grad")
acsShares <- c(47.95, 27.53, 31.26, 16.20, 25.01, 65.46, 9.40, 29.16, 30.72, 19.13, 11.60)
sampleComp <- data.frame(
  Characteristic = names(compVars),
  Sample = sapply(compVars, function(x) 100*mean(x, na.rm = TRUE)),
  Weighted = sapply(compVars, function(x) {ok <- !is.na(x) & !is.na(scFloodData2$wt); 100*weighted.mean(x[ok], scFloodData2$wt[ok])}),
  ACS = acsShares
)

## ---------------------------------------------------------------------------
## Supplementary (appendix): homeowners' willingness to accept a buyout, 1-5
## Randomized hypothetical disruptive flood days (5-200), rescaled to
## 100-day units. buyoutSupportOwn is only asked of homeowners.
## ---------------------------------------------------------------------------
scFloodData2$floodDays100 <- scFloodData2$floodDays/100
acceptData <- scFloodData2[complete.cases(scFloodData2[c("buyoutSupportOwn", "floodDays100", setdiff(allTerms, "ownHome"))]), ]
sampleFunnel$N[6] <- nrow(acceptData)

acceptBivModel <- lm(buyoutSupportOwn ~ floodDays100, data = acceptData)
acceptModel    <- lm(mkForm("buyoutSupportOwn", c("floodDays100", setdiff(allTerms, "ownHome"))), data = acceptData)
## baseline (pre-experiment) support as a pre-treatment precision covariate
acceptBaseModel <- update(acceptModel, . ~ . + buyoutSupport)
acceptModels   <- list("Bivariate" = acceptBivModel, "Full" = acceptModel, "Full + baseline support" = acceptBaseModel)

## flood-days estimate and 95% CI (per 100 days, county-clustered)
acceptCI <- lmtest::coefci(acceptModel, vcov. = sandwich::vcovCL(acceptModel, cluster = clusterVcov))["floodDays100", ]
acceptB  <- coef(acceptModel)["floodDays100"]
acceptBaseCT <- lmtest::coeftest(acceptBaseModel, vcov. = sandwich::vcovCL(acceptBaseModel, cluster = clusterVcov))["floodDays100", ]
acceptBaseCI <- lmtest::coefci(acceptBaseModel, vcov. = sandwich::vcovCL(acceptBaseModel, cluster = clusterVcov))["floodDays100", ]

## share of homeowners somewhat/very likely to accept, by lowest vs. highest
## quartile of assigned flood days
acceptData$daysQ <- cut(acceptData$floodDays, quantile(acceptData$floodDays, 0:4/4), include.lowest = TRUE,
                        labels = c("Q1", "Q2", "Q3", "Q4"))
acceptByQ <- tapply(acceptData$buyoutSupportOwn >= 4, acceptData$daysQ, mean)

## Quick look when run interactively
if (sys.nframe() == 0) {
  print(sampleFunnel)
  modelsummary::modelsummary(supportModels, vcov = clusterVcov, stars = TRUE, output = "markdown")
  print(summary(acceptModel))
}
