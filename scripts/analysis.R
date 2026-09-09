## analysis.R
## Analysis presented in flood-risk.qmd.
## Tables and figures are built in code chunks in the manuscript; this script
## holds the data prep and model fitting they depend on. Run from the project
## root (or source with the working directory set there).

## Data, recodes, and scale reliabilities (scBondA, scBridgeA, commRelA, infraA)
source("scripts/recodes.R")

## ---------------------------------------------------------------------------
## DV 1: Support for a property buyout program (all respondents), 1-7 scale
## H1a-c (flooding), H2a-d (community factors), H3a-d (individual factors)
## ---------------------------------------------------------------------------
supportPreModel <- lm(
  buyoutSupportPre ~ concernFlood + floodEx + floodF +
    commRel + infraScale + scBridge + scBond + coastalCount + ownHome +
    currentAdd + ideology + age + male + white + edu + inc,
  data = scFloodData2
)

## ---------------------------------------------------------------------------
## DV 2: Homeowners' willingness to accept a buyout, 1-5 scale
## H4: randomized number of hypothetical disruptive flood days (7-200)
## buyoutSupportOwn is only asked of homeowners, so the estimation sample is
## implicitly homeowners; ownHome is dropped from the RHS.
## ---------------------------------------------------------------------------
supportPostModelOwn <- lm(
  buyoutSupportOwn ~ floodDays + concernFlood + floodEx + floodF +
    commRel + infraScale + scBridge + scBond + coastalCount +
    currentAdd + ideology + age + male + white + edu + inc,
  data = scFloodData2
)

## Quick look when run interactively
if (sys.nframe() == 0) {
  print(summary(supportPreModel))
  print(summary(supportPostModelOwn))
}
