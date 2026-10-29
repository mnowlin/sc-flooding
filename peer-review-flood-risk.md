# Internal Peer Review — *Flood Perceptions, Social Capital, and Public Support for Property Buyout Programs*

**Date:** 2026-09-09
**Reviewer role:** internal "tough but fair" referee, pre-submission
**Materials reviewed:** `flood-risk.qmd`, `scripts/recodes.R`, `scripts/greenwood-analysis.R`, `data/SC Statewide Survey.docx`

> The code was read alongside the prose because several of the most consequential problems are not visible in the manuscript text.

---

## Summary of the submission

The paper uses an original November–December 2023 quota sample of South Carolina residents (recruited via CloudResearch) to study (a) general support for a property buyout program, modeled by OLS on flood perceptions/experience, "community factors" (perceived community resilience, infrastructure satisfaction, bridging social capital, coastal residence), and "individual factors" (bonding social capital, homeownership, tenure at address, ideology, demographics); and (b) a randomized manipulation in which homeowners are shown a uniform-random number of "disruptive flooding days" per year (7–200) and asked how likely they would be to accept a buyout. Headline findings: concern, flood experience, and coastal residence raise support; bonding social capital, conservatism, and longer tenure lower it; and — contrary to the stated hypotheses — resilience perceptions, infrastructure satisfaction, and bridging social capital *raise* support. The flood-days manipulation has no detectable effect; stated willingness to accept is uniformly high.

## Overall assessment

The topic is timely and policy-relevant, the survey is original, and the bonding/bridging distinction plus the randomized dose are genuine contributions. In its current form the recommendation is **major revisions**. Concerns fall into four buckets:

1. Construct validity of the central dependent variable and of the "community attachment" construct.
2. Measurement/coding errors and choices in the scales that likely drive several of the marginal results.
3. An under-powered, ceiling-limited second study that is not reported with enough statistical detail to interpret the null.
4. Reporting and reproducibility gaps, most importantly the absence of any regression table.

---

## Major issues

### 1. The general-support DV asks about a *federal* program; the paper is about a *state* program

The abstract and framing are about SCOR, "a state government buyout program." But Q16's second paragraph reads: "In this program **the federal government** would purchase homes and businesses in South Carolina…" The construct and the measure are misaligned. Given that conservatism is one of the key predictors and attitudes toward federal vs. state action are strongly partisan, this is not cosmetic — the ideology finding (H3d) may partly reflect attitudes toward *federal* involvement rather than buyouts per se. At minimum, acknowledge and discuss; ideally, reconcile the wording throughout, and check whether respondents who got the renter version (Q19, which drops the "federal" cue) answered differently.

### 2. The support question is loaded and double-barreled

Q16 pre-sells the policy before measuring support: it tells respondents buyouts reduce "risk to people and communities" and "reduce costs to homeowners, insurance companies, and the government," and bundles "severe storms, flooding, wildfires, and other extreme events." The descriptive claim that the mean sits "above the midpoint and indicates some support" is fragile under this framing. Either soften the descriptive interpretation substantially or justify the wording against a balanced-question standard.

### 3. "Community attachment" is the wrong construct for three of the four community-factor hypotheses

H2a–H2c treat perceived community resilience, infrastructure satisfaction, and bridging social capital as indicators of attachment that should *reduce* support. None of these is an attachment measure. Resilience perception and infrastructure satisfaction are government-performance evaluations; bridging social capital is about organizational resources. The paper predicts the wrong sign for all three, finds the opposite for all three, and then explains the reversal post hoc via trust in government competence. That post-hoc account is more defensible as an *a priori* hypothesis than the attachment framing was. Recommend re-grounding this section: separate genuine place/community attachment from government-performance evaluations, and theorize the latter through the policy-feedback / trust-in-government / government-competence literatures. As written, the "surprising" findings are surprising mainly because the hypotheses were mis-specified.

### 4. Place attachment carries heavy theoretical weight but is barely measured

The theory section leans on place attachment repeatedly, yet the only operationalizations are homeownership and a 4-category tenure variable (`currentAdd`). The survey collected but did not use time in the community (`Q82`/`currentComm`) and willingness to move (`Q50`/`move`). There is no validated place-attachment battery. Either bring in the unused items or explicitly flag the weak measurement as a limitation — right now the paper tests a place-attachment argument mostly without a place-attachment measure.

### 5. Scale construction errors and choices that likely produce the marginal results

From `recodes.R`:

- **Infrastructure scale is divided by the wrong denominator.** `infraScale <- round((infraDW + infraLG + infraRD + infraSWSP)/5, 0)` — four items divided by 5. The manuscript describes it as "a single scale … 1 to 5"; the actual variable ranges roughly 1–4 and is not the mean of the items. This is a bug.
- **All four scales are rounded to integers**: `scBond`, `scBridge`, `commRel`, and `infraScale` are all `round(mean, 0)`. This discards within-scale variance, coarsens continuous constructs into 4–7 point lumps, and attenuates coefficients toward zero. Several key claims (bonding social capital H3a, tenure H3c) rest on *p* < 0.10; de-rounding the scales is exactly the kind of change that can move a marginal coefficient across conventional thresholds in either direction. Re-run everything on the unrounded scale means.
- The manuscript then reports these variables to three decimals (`round(mean(scFloodData2$scBond), 3)`), which will display the mean of an integer-valued variable — internally inconsistent with "a 1 to 5 scale."
- **Report the actual Cronbach's α values in the text** (currently only inline code). Given that the bonding and bridging batteries mix heterogeneous content — closeness ("friends you have"), trust ("relatives you can trust"), and resource/status items ("how many hold a professional job," "broad connections with others") — α alone is not evidence of unidimensionality. A brief EFA or a defense of combining these items is warranted, and the label "bonding" should be qualified given the resource-generator items in it.

### 6. Objective flood risk is in the data and unused

`scFloodData2` is built by merging in the FEMA National Risk Index (`NRI-short.csv`) at the county level, but NRI never appears in the models. A reviewer will ask why. Perceived vs. objective risk is the natural framing for this paper, and objective risk is the obvious control for H1a–H1c and H2d. Relatedly, `coastalCount` is a **self-report** (Q83) even though administrative county FIPS is available from the merge — use the administrative geography, and report how many respondents are actually in coastal counties, since H2d rests entirely on that subgroup.

### 7. The analytic sample is defined by inner joins, and N is not accounted for

`merge(scFloodData, scZip, by = "zip")` and then `merge(..., scNRI, by = "STCOFIPS")` are inner joins: any respondent with a missing or unmatched ZIP is silently dropped before any model runs. The manuscript reports `nrow(scFloodData2)` as "respondents obtained," conflating completed surveys with the post-merge analytic sample. Provide a CONSORT-style accounting: completed surveys → valid SC ZIP → merged → listwise-complete on the 16 covariates → N in each model. With 16 predictors, listwise deletion could be substantial and is currently invisible.

### 8. No regression table anywhere

Results are reported only through `sjPlot::plot_model` coefficient plots. The one `modelsummary` table (`tbl-olsModel`) is commented out in the appendix, and the flood-days multivariate model (`supportPostModelOwn`, defined in the `ols models` chunk) is never displayed at all. For a quantitative journal this will not pass: readers need coefficients, standard errors, confidence intervals, N, and R² for every model, plus (ideally) the nested Flood/Community/Individual/Full specifications already scaffolded in commented code. State explicitly whether the plotted estimates are raw or standardized. Also report model fit — R² is not mentioned in the text and is likely modest.

### 9. The second study cannot bear the weight placed on it

- **Ceiling effect.** With a uniform 7–200 draw, the median respondent sees ~100 "disruptive flooding days" per year, a near-apocalyptic scenario, and stated willingness to accept is pinned near the top of the 1–5 scale for nearly everyone. There is almost no outcome variance left for `floodDays` to explain. This is a design failure, not a substantive null: the low, *realistic* end of the dose-response curve is barely sampled.
- **The null is reported without statistics.** The manuscript tests H4 with a jittered scatterplot and the sentence "the relationship … is not significant." No coefficient, SE, CI, or N. For a null result the estimate must be shown to be *precisely* zero, not merely underpowered — report the multivariate model already fit, with a confidence interval, and ideally an equivalence test.
- **Framing vs. Bendz.** The paper claims the design is "similar to" Bendz (2025), but Bendz varied return periods (once a year / decade / 50 years), whereas this varies raw disruptive-days counts on an undefined 7–200 range with no citation grounding that range. These are different stimuli; the comparison should be qualified.
- **Recommendation:** reframe study 2 as exploratory, report it fully, and either re-run with a realistic low-end distribution / discrete conditions in future work or foreground the ceiling as the finding ("homeowners' threshold for accepting a buyout appears to sit well below 7 disruptive days/year").

### 10. Sample and generalization

This is a non-probability opt-in panel quota-matched on age, gender, and race only. The paper makes population-level claims ("the public is, on average, supportive"). Recommendations: (a) add a table comparing the sample to SC benchmarks on party/ideology, education, income, urban/rural, and coastal/inland; (b) consider post-stratification weights (the `cue-WTP` project uses a weighted `svydesign` — the same discipline would help here) or at least show unweighted/weighted robustness; and (c) soften the generalization language accordingly. Note also that CloudResearch/quota panels have known data-quality issues; describe the attention-check / screening procedure.

---

## Moderate issues

- **Multicollinearity / suppression.** Perceived resilience and infrastructure satisfaction are likely strongly correlated, as are bonding and bridging social capital. Counterintuitive signs (issue 3) can arise from collinearity. Report a correlation matrix and VIFs, and show the community-evaluation variables entered separately vs. jointly.
- **Functional form of the DV.** OLS on a bounded 7-point (and 5-point) ordinal outcome is conventional but, given the ceiling on DV2 and the surprising DV1 results, include an ordered-logit robustness check and OLS with robust SEs in an appendix.
- **`p < 0.10` reporting.** The Results prose asserts H3a and H3c as confirmed ("as expected, an increase in bonding social capital is associated with a decrease…") with "(at *p*<0.10)" tucked in. With 16 predictors and no multiple-comparison adjustment, these should be described as marginal/suggestive, consistent with the reporting convention adopted in the `cue-WTP` project.
- **Flood-experience measure.** `floodEx` collapses Q14's time bands (from "within the last year" to "more than 20 years ago") into a single binary, discarding the recency signal that the theory says matters most. Consider a recency-graded measure. Similarly, `floodF` is entered as linear 1/2/3 with a near-empty "less frequent" category — a "more frequent vs. not" dummy is cleaner for H1b.
- **Unused exposure measures.** Q12 (`floodDA`, days flooding disrupted daily activities in the last year) and Q13 (`floodSAFE`) are recoded but unused. These are arguably better exposure measures than the lifetime binary and — usefully — are on the same "disruptive days" metric as the manipulation, so they could validate the vignette.
- **No substantive effect sizes.** Everything is "associated with increased/decreased support." Provide predicted values / marginal effects for meaningful contrasts (e.g., a 2-SD shift in bonding social capital, coastal vs. inland). The `cue-WTP` `predict_*` helpers are a good model for this.
- **Framing overreach.** The intro and conclusion lean heavily on "climate migrants" and the World Bank's 216-million figure, but the buyout question never mentions climate change and the study measures policy opinion, not migration. Tighten the framing to public opinion on buyout / managed-retreat policy.
- **Contribution positioning.** "Little research has examined public support for buyout programs" is immediately followed by two studies that did (Raikes 2023; Bendz 2025). State the actual contribution crisply — a US state-program case, the bonding/bridging distinction, the randomized dose — and engage adjacent literatures currently missing: public opinion on climate adaptation, NIMBY / place-based policy conflict, policy feedback, trust in government and risk policy, and risk perception.
- **IRB and preregistration.** The consent form shows College of Charleston HRPP review — add an explicit approval statement (and protocol number) to the manuscript, and note the affiliation change to UT Arlington. State whether H1–H4 and the manipulation were preregistered; if not, say so and label the tests confirmatory-in-intent but not preregistered.
- **"Pre" in `buyoutSupportPre`.** The variable name (and the "Buyout Baseline" block) implies a pre/post design that isn't described. Either explain it or rename for the manuscript.
- **Baseline as covariate.** `greenwood-analysis.R` includes `+ buyoutSupportPre` in the accept-buyout models; the manuscript version drops it. Decide, justify, and be consistent.

---

## Minor / editorial

- Figure axis labels: "Likey to Accept Buyout" (twice).
- Table and code label: "Time at Current **Addres**."
- Data section: community resilience described as "1 (strongly disagree) to 7 (strongly **disagree**)" — should be "strongly agree."
- "we group into **a three elements**."
- Descriptive table (`tbl-descript`) shows binary variables with Mean/SD/Min/Max; report those as percentages, or split the table into categorical vs. continuous.
- Strip the MPSA conference line and "Paper prepared for the Annual Meeting…" before journal submission; fix the trailing space / missing period in the Greenwood author footnote.
- Histogram prose: "most respondents saw a large number of hypothetical flood days" simply restates that the draw is uniform — the informative point is that few respondents saw a realistic low number.

---

## Reproducibility notes

- `ggsave("manuscript/ols-model.png", …)` writes to a `manuscript/` subdirectory, but the chunk that displays it references `ols-model.png` and `knitr::opts_knit$set(root.dir = normalizePath(".."))` sets the working directory up one level. This path arrangement is fragile and the rendered figure could be stale relative to the model. Consider letting the chunk produce the figure directly rather than round-tripping through `ggsave`.
- Two chunks share the label `plot network for pre and post sample` (copied from another project); duplicate chunk labels break knitr and should be made unique and descriptive.
- Because the four rounded scales feed both the descriptive statistics and every model, fixing issue 5 will change essentially every number in the paper. Plan the revision around a single clean pass through `recodes.R`.
- The repository is not under git and `LOG.md` is still the log from the `cue-WTP` project — worth resolving before submission so the analysis history for *this* paper is captured.

---

## What is working

- Original, well-timed data on a policy question with little existing public-opinion evidence, tied to a real, funded state program (SCOR) with documented local cases.
- The bonding vs. bridging social capital distinction is a real analytic contribution and the divergent findings, if they survive de-rounding, are interesting.
- Randomizing the flood-days figure is a good instinct; the execution (range, distribution, ceiling) is what needs work, not the idea.
- Question wording is provided in an appendix, and the analysis is script-based and largely inline — the bones of a reproducible workflow are here.
- Prose is clear, well-organized around the hypothesis groupings, and appropriately hedged in most places.

---

## Suggested revision priority

1. Fix the `infraScale` denominator bug and remove `round(..., 0)` from all four scales; re-run the full analysis (issue 5).
2. Add regression tables for every model, including the flood-days model (issue 8).
3. Reconcile the federal/state framing of the DV (issue 1).
4. Re-ground the "community factors" theory away from "attachment" (issue 3).
5. Report the sample-accounting funnel and model Ns (issue 7).
6. Reframe study 2 around the ceiling effect and report the null with full statistics (issue 9).
7. Bring in NRI objective risk and administrative coastal-county coding (issue 6).
8. Add weighting / sample-representativeness table and soften generalization (issue 10).
