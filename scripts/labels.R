## labels.R
## Table/figure labels shared by flood-risk.qmd and supplemental-materials.qmd

gm <- tibble::tribble(
  ~raw,        ~clean,          ~fmt,
  "nobs",      "N",             0,
  "r.squared", "R2", 2)

cm <- c("concernFlood" = "Flooding Concern",
        "floodEx" = "Flood Experience",
        "floodF" = "Flooding Increase",
        "coastalCount" = "Coastal County",
        "coastalSelf" = "Coastal County (self-reported)",
        "rfldRisk" = "County Riverine Flood Risk",
        "commRel" = "Perceived Community Resilience",
        "infraScale" = "Infrastructure Satisfaction",
        "scBridge" = "Bridging Social Capital",
        "scBond" = "Bonding Social Capital",
        "ownHome" = "Own Home",
        "currentAdd" = "Time at Current Address",
        "currentComm" = "Time in Local Area",
        "ideology" = "Ideology (more conservative)",
        "age" = "Age",
        "male" = "Gender (male=1)",
        "white" = "Race (white=1)",
        "edu" = "Education",
        "inc" = "Income",
        "(Intercept)" = "Constant")

starsSet <- c("+" = 0.1, "*" = 0.05, "**" = 0.01, "***" = 0.001)
