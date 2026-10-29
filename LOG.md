# Session Log — sc-flooding Project

Paper title: **"Who Supports Managed Retreat? Flood Experience, Local Government Performance, and Public Opinion on Property Buyouts"**

This log records what has been done in each working session. Update it at the end of each session (newest entry first).

---

## Project Overview

An original statewide survey of South Carolina residents (CloudResearch,
November–December 2023, quota-matched to Census age/gender/race) on public
support for government property buyout programs. Two outcomes: (1) support
for a buyout program among all respondents (1–7), modeled by OLS on flood
perceptions/experience, community factors, and individual factors; (2)
homeowners' willingness to accept a buyout (1–5) in a survey experiment
that randomizes the number of hypothetical "disruptive flooding days" per
year (7–200).

**Key files:**
- `flood-risk.qmd` — main manuscript (renders to HTML, PDF, DOCX)
- `scripts/recodes.R` — raw data loading, all recodes/scales (incl. Cronbach's alpha), ZIP-to-county and FEMA NRI merges
- `scripts/analysis.R` — sources `recodes.R`, fits the two OLS models reported in the manuscript
- `scripts/export-cited-refs.R` — pre-render step that trims the master `.bib` to cited keys
- `renv.lock` — pinned package library (R 4.6.0); restore with `renv::restore()`
- `data/SC Statewide Survey NUMBER.csv` — numeric-coded survey responses (not in git)
- `README.md` — project structure and reproduction instructions
- `peer-review-flood-risk.md` — internal pre-submission peer review

---

## Session History

### Session 4 — 2026-10-29 (Review revisions: moderate and minor issues)

- `_output/` (rendered html/pdf/docx) now tracked in git.
- `recodes.R`: flood recency from multi-select Q14 (`floodRecent` = most
  recent flood within ~5 years, `floodOlder`), `floodMore` dummy, survey
  `duration`; documented `buyoutSupportPre` as pre-experiment and added
  `buyoutSupport` (name used in `analysis.R` and the manuscript).
- `analysis.R`: alternative-measure models (`altModels`: recency, more-frequent
  dummy, Q12/Q13 past-year exposure, excluding 13 speeders < 1/3 median time),
  2-factor EFA of the 16 social capital items (`scEFA`), substantive effects
  table (`effectTab`, 0-to-1 or +2 SD with clustered CIs), and the accept
  model with baseline support as a pre-treatment covariate (`acceptBaseModel`).
- Findings: recent flood +1.15 (p < .001), older flood ~0; Q12/Q13 and the
  more-frequent dummy ns; results hold without speeders; VIFs < 2.4; EFA
  separates bonding/bridging (r = .56) but bonding items 1-2 load weakly.
  Study 2 with baseline covariate: +0.24 per 100 days, p = .02 (vs. +0.19,
  p < .10 without).
- Manuscript: trimmed climate-migrant framing (dropped World Bank 216M);
  added trust / policy feedback / NIMBY paragraph; IRB footnote (protocol
  number placeholder) and no-preregistration statement, plus a limitation
  noting the competing hypotheses were developed partly after earlier
  analyses; completion-time check; split descriptive tables (binary as %);
  effects table in Results; alternative-measures and EFA tables in appendix;
  dropped the MPSA line; fixed the Greenwood footnote.
- New title: "Who Supports Managed Retreat? Flood Experience, Local Government
  Performance, and Public Opinion on Property Buyouts"; "local government
  performance" used consistently for H3.
- Appendix moved to `supplemental-materials.qmd` (added to `_quarto.yaml`
  render list). Shared table labels moved to `scripts/labels.R`. Supplement
  captions are hardcoded (Table S1-S7, Figure S1) because Quarto cross-refs
  can't produce S-numbering or link across documents; main-text references to
  "Table S#" are also hardcoded, so renumber both if tables are reordered.
  PDF tables pinned with `options(tinytable_latex_placement = "H")` plus
  `\needspace`/`\clearpage` before captions.
- Combined the descriptive statistics into one table (continuous/ordinal
  panel with mean/SD/min/max; binary panel with percent coded 1).
- Close out: README updated (analysis description, supplement, `labels.R`,
  model names, sample funnel); full project re-rendered; committed and pushed.

### Session 3 — 2026-10-29 (Review revisions: priority items 1-8, competing hypotheses)

- Consensus literature search on public support for buyouts; drafted
  `literature/buyout-lit-review.md` (gitignored) with Zotero citekeys.
- `recodes.R`: removed `round()` from `scBond`, `scBridge`, `commRel`,
  `infraScale`; fixed `infraScale` divisor (4 items, was /5); dropped the
  Qualtrics spam record (Status 8); ZIPs spanning counties now go to the
  county with the largest residential share (was first row); added ZIP 29342
  (Gaffney PO boxes, not in the HUD crosswalk) to Cherokee County; recoded
  `currentComm` (Q82, time in area) to the `currentAdd` 1-4 scale; added
  administrative coastal county (`coastalCount`, 8-county coastal zone;
  self-report kept as `coastalSelf`), NRI flood risk (`rfldRisk`,
  `cfldRisk`), and raked post-stratification weights (`wt`, ACS 2024
  1-year SC adults on sex, age, race, education); sample-funnel counts.
- `analysis.R`: nested Flooding/Community/Individual/Full models on a
  common sample (n = 407), county-clustered SEs; robustness (weighted,
  ordered logit, community measures entered singly, self-reported coastal);
  study 2 (`acceptModel`, flood days per 100) moved to an appendix.
- De-rounding changed results: bonding and bridging social capital are no
  longer significant in the full model; resilience and infrastructure stay
  positive. Time in area (new) is negative and significant.
- Manuscript: competing community-factor hypotheses (H2 attachment vs. H3
  government performance), coastal county moved to H1d, individual factors
  now H4; drafted revised abstract, intro, lit review, data, results,
  discussion, conclusion (Claude draft, style profile). Regression tables
  added; figure now built in-chunk (no `ggsave`). Removed the `root.dir`
  setup line; fixed duplicate chunk labels; DOCX reference doc now the local
  `custom-reference-doc.docx` (old Dropbox path no longer exists); added
  `html: default` so all three formats render. Pre-revision manuscript
  saved to `archive/flood-risk-pre-revision.qmd`.
- renv: library had been offloaded by OneDrive (missing DESCRIPTION files);
  ran `renv::restore()`, removed stub `.dSYM` files that broke Quarto, added
  `survey`, `sandwich`, `psych`; snapshotted.
- Placeholder citations `@MISSING-*` (Mah 2024, Mallette 2021, Shao 2017,
  Jones 2014, Bax 2025) need Zotero entries; Houser 2022 key
  `PublicSupportLocal` lacks author/year metadata.

### Session 2 — 2026-09-09 (renv, close out)

- Ran `renv::init()` — created a project library and `renv.lock` pinned to
  R 4.6.0, capturing the manuscript/analysis dependency tree (dplyr,
  ggplot2, modelsummary, tinytable, sjPlot, psy, datawizard, car, knitr,
  rmarkdown, ...).
- `renv::status()` reported the project out-of-sync over `gdata` (a
  transitive dependency via `gtools`/`stargazer`); installed
  `gdata` + `gtools` and re-snapshotted. Status now clean.
- Verified `Rscript -e 'source("scripts/analysis.R")'` runs under the
  project library; both models fit. Estimation Ns: `supportPreModel`
  n = 407, `supportPostModelOwn` n = 288 (homeowners) — concrete
  confirmation of the case loss flagged in the internal review (inner
  joins + listwise deletion drop ~150 of ~560 completed surveys from the
  main model).
- Updated `README.md` to lead with `renv::restore()` and note the
  estimation Ns. Committed and pushed.

### Session 1 — 2026-09-09 (Internal peer review + project setup)

- Produced `peer-review-flood-risk.md`: a tough-but-fair referee-style
  review of `flood-risk.qmd`, read alongside `scripts/recodes.R` and
  `scripts/greenwood-analysis.R`. Recommendation: major revisions. Main
  points — federal vs. state framing of the support DV, the loaded
  wording of the support question, the "community attachment" construct
  being the wrong frame for H2a–c, an `infraScale` denominator bug (÷5 for
  4 items) and all four scales rounded to integers in `recodes.R`, the
  unused FEMA NRI objective-risk data, silent case loss from the inner
  joins, no regression table in the manuscript, and a ceiling-limited
  second study whose null is reported without statistics.
- Completed the CLAUDE.md "set-up" checklist (the user had already moved
  `_quarto.yaml` and `nowlin-style-profile.md` from `project-files/` and
  renamed the manuscript to `flood-risk.qmd` with a real title):
  - Copied `scripts/export-cited-refs.R` from the template and set its
    source file to `flood-risk.qmd`.
  - Set the render target in `_quarto.yaml` to `flood-risk.qmd`.
  - Pointed the manuscript YAML `bibliography:`/`csl:` at the locally
    generated `references.bib` / `american-political-science-association.csl`
    (they had been absolute Dropbox paths, which overrode `_quarto.yaml`
    and bypassed the pre-render step).
  - Created `scripts/analysis.R` (sources `recodes.R`, fits
    `supportPreModel` and `supportPostModelOwn`).
  - Rewrote `README.md` and `LOG.md` for this project (both were still the
    cue-WTP project's files).
  - Added `.gitignore` (ignores `/data`, `/literature`,
    `nowlin-style-profile.md`, the generated bib/csl, and R/Quarto/OS
    junk).
  - Initialized git, created the public GitHub repo, and pushed. Redacted
    the `project-files` template path from `CLAUDE.md` before the first
    commit (per set-up step 11).

---

## Analysis Architecture

- `scripts/recodes.R` does all data construction: reads
  `data/SC Statewide Survey NUMBER.csv`, drops the two Qualtrics header
  rows, builds every recoded variable, averages the multi-item scales
  (bonding social capital `scBond`, bridging `scBridge`, community
  resilience `commRel`, infrastructure satisfaction `infraScale`) and
  their Cronbach's alpha objects (`scBondA`, `scBridgeA`, `commRelA`,
  `infraA`), then merges `data/SC-zip-to-county.csv` and
  `data/NRI-short.csv` to produce `scFloodData2` (the analytic frame).
- `scripts/analysis.R` sources `recodes.R` and fits the two manuscript
  models. Tables and figures are built in `flood-risk.qmd` code chunks;
  some results are reported via inline R.

## Key Analytical Decisions

- Support-for-buyout model (`supportPreModel`): OLS, `buyoutSupportPre`
  (1–7) on all 16 predictors, full sample.
- Accept-buyout model (`supportPostModelOwn`): OLS, `buyoutSupportOwn`
  (1–5) on `floodDays` plus covariates. `buyoutSupportOwn` is only asked of
  homeowners, so the estimation sample is implicitly homeowners and
  `ownHome` is dropped from the RHS.
- Bibliography workflow: master bib/csl live under
  `01-RESEARCH/Manuscript-Files/`; `scripts/export-cited-refs.R` writes a
  trimmed project-local `references.bib` and copies the CSL at pre-render.

## Open Items

- Add the five `@MISSING-*` references to Zotero and swap in their keys; fix
  author/year metadata for `PublicSupportLocal` (Houser et al. 2022).
- Fill in the IRB protocol number; describe CloudResearch screening (TODO
  comment in the Data section).
- Decide whether to keep study 2 (now suggestive with the baseline covariate).
- Review/rewrite the Claude-drafted manuscript text; the title still
  foregrounds social capital, which is no longer significant.
