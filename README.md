# Who Supports Managed Retreat? Flood Experience, Local Government Performance, and Public Opinion on Property Buyouts

Manuscript and reproducible analysis examining public opinion in South
Carolina toward government property buyout programs, a form of managed
retreat from flood-prone areas.

The data come from an original statewide survey of South Carolina residents
(CloudResearch, November–December 2023, quota-matched to Census age, gender,
and race distributions). The analysis has two parts:

- **Support for a buyout program** (all respondents, 1–7 scale; manuscript).
  Nested OLS models with county-clustered SEs on flood perceptions and
  experience (incl. administrative coastal county and FEMA NRI riverine flood
  risk), community factors tested as competing hypotheses (community
  attachment vs. local government performance: perceived community
  resilience, infrastructure satisfaction, bridging social capital), and
  individual factors (bonding social capital, homeownership, time at address
  and in the local area, political ideology, demographics). Robustness:
  post-stratification weights (raked to ACS 2024), ordered logit,
  alternative flood measures, speeder exclusion.
- **Homeowners' willingness to accept a buyout** (1–5 scale; supplemental
  materials) in a survey experiment that shows each homeowner a randomly
  drawn number of hypothetical "disruptive flooding days" per year (5–200).

## Layout

```
flood-risk.qmd                       Manuscript source (renders to HTML, PDF, DOCX)
supplemental-materials.qmd           Supplemental materials (question wording, Tables S1-S7,
                                       Figure S1; S-numbers are hardcoded)
_quarto.yaml                         Quarto project config
renv.lock, renv/, .Rprofile          Pinned package library (renv)
_output/                             Rendered HTML/PDF/DOCX (tracked in git)
custom-reference-doc.docx            Word reference template for the DOCX output
CLAUDE.md                            Project instructions / setup + close-out workflows
LOG.md                               Running session log (newest entry first)
peer-review-flood-risk.md            Internal pre-submission peer review
scripts/
  recodes.R                          Loads the raw survey CSV, builds all recoded
                                       variables and scales (bonding/bridging social
                                       capital, community resilience, infrastructure
                                       satisfaction, incl. Cronbach's alpha objects),
                                       and merges in ZIP-to-county and FEMA NRI data
  analysis.R                         Sources recodes.R; fits the nested support models,
                                       robustness/alternative-measure models, EFA,
                                       substantive effects, and the accept-buyout models
  labels.R                           Table labels shared by both .qmd files
  export-cited-refs.R                Pre-render step: trims the master .bib to cited keys
  greenwood-analysis.R,              Earlier / exploratory analysis scripts (not part
  2.9.greenwood-analysis.R,            of the manuscript build)
  setup.R
data/                                Survey and geographic data (NOT in git -- see below)
literature/                          Background literature (NOT in git -- local only)
figures/                             Generated figures
archive/, presentation/              Prior drafts, thesis, conference decks
```

## Reproducing the analysis

Package versions are pinned with [`renv`](https://rstudio.github.io/renv/)
(lockfile records R 4.6.0). Open the project in R and run
`renv::restore()` to install the recorded library, then:

- **Manuscript:** `quarto render` → outputs to `_output/` (HTML, PDF, and
  DOCX; the DOCX uses `custom-reference-doc.docx`). The pre-render step
  regenerates `references.bib` and the local `.csl` from the master
  bibliography.
- **Models only:** `Rscript scripts/analysis.R` sources `recodes.R` and
  fits `supportModel` (full model, n = 407) and `acceptModel` (n = 288,
  homeowners), plus the nested, robustness, and alternative-measure models.

## Data

The `data/` folder is **not tracked in git**. Restore it before rendering.
Key inputs used by `scripts/recodes.R`:

- `data/SC Statewide Survey NUMBER.csv` — numeric-coded survey responses
  (the statewide CloudResearch quota sample; the analytic N is computed
  inline in the manuscript as `nrow(scFloodData2)`).
- `data/SC-zip-to-county.csv` — respondent ZIP to county crosswalk.
- `data/NRI-short.csv` — county-level FEMA National Risk Index values,
  merged on `STCOFIPS`.

Note: respondents without a ZIP code matched to an SC county are dropped
before modeling; the full sample funnel is reported in Table S1
(`sampleFunnel` in `analysis.R`).

## Notes

- `references.bib` and the local `.csl` are generated at render time by the
  pre-render step (`scripts/export-cited-refs.R`) from the master
  bibliography, so they are git-ignored.
- `_output/` **is tracked in git** so the rendered manuscript is available
  without re-running R/Quarto. Re-render (`quarto render`) after any change
  to either `.qmd` file or any script in `scripts/` and
  commit the updated files in `_output/` alongside the source change.
- Quarto's freeze cache is enabled (`execute: freeze: auto` in
  `_quarto.yaml`); `_freeze/` is git-ignored.
- `nowlin-style-profile.md`, `data/`, and `literature/` are git-ignored
  (kept local only).
- `LOG.md` records what changed and why for each work session; add a new
  entry at the top.
- `peer-review-flood-risk.md` is an internal referee-style review used to
  guide revisions before submission.
